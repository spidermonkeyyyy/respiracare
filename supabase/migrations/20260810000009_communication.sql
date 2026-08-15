-- ============================================================
-- Migration 009: conversations + messages + internal_notes
-- Project: RespiraCare
-- Date: 2026-08-10
-- v2.1 notes:
--   - Last-message denormalisation maintained by a trigger on messages.
--   - messages.sender_role is checked against Dart MessageSender
--     (patient / care_team / system). sender_profile_id is nullable
--     only when sender_role = 'system'.
--   - messages.delivery_status CHECK is ('sent','read') only —
--     'sending' is rejected from the persisted value set (open
--     decision #7 = REJECT).
--   - internal_notes NEVER visible to patients (RLS denies it; RLS
--     itself is defined in Migration 999). Table-level separation from
--     messages is the architectural invariant.
-- ============================================================

-- ---------- conversations ----------
create table if not exists public.conversations (
    id                      uuid primary key default gen_random_uuid(),
    patient_profile_id      uuid not null,
    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now(),
    last_message_at        timestamptz,             -- denormalised
    last_message_preview   text                     -- denormalised (max ~200 chars)
);

alter table public.conversations
    drop constraint if exists conversations_patient_profile_id_fkey;
alter table public.conversations
    add constraint conversations_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- ---------- messages (patient-visible only) ----------
create table if not exists public.messages (
    id                          uuid primary key default gen_random_uuid(),
    conversation_id             uuid not null,
    sender_role                text not null
                                check (sender_role in ('patient','care_team','system')),
    sender_profile_id           uuid,                     -- NULL only for sender_role = 'system'
    message_type               text not null default 'text'
                                check (message_type in ('text','care_update','follow_up','system_notification')),
    text                        text not null,
    delivery_status            text not null default 'sent'
                                check (delivery_status in ('sent','read')),   -- 'sending' rejected
    created_at                  timestamptz not null default now(),
    action_label               text,
    action_route               text,
    linked_care_request_id     uuid,
    linked_task_id             uuid,
    -- CHECKs preserving Dart Message semantics:
    constraint messages_system_sender_null_id
        check ((sender_role = 'system') = (sender_profile_id is null)),
    constraint messages_action_label_route_coherent
        check ((action_label is null) = (action_route is null))
);

alter table public.messages
    drop constraint if exists messages_conversation_id_fkey;
alter table public.messages
    add constraint messages_conversation_id_fkey
    foreign key (conversation_id) references public.conversations(id)
    on delete cascade;

alter table public.messages
    drop constraint if exists messages_sender_profile_id_fkey;
alter table public.messages
    add constraint messages_sender_profile_id_fkey
    foreign key (sender_profile_id) references public.profiles(id)
    on delete restrict;

-- linked_care_request_id / linked_task_id FKs added in Migration 010
-- (forward references — care_requests and tasks are created there).

-- ---------- internal_notes (NEVER patient-visible) ----------
create table if not exists public.internal_notes (
    id                      uuid primary key default gen_random_uuid(),
    conversation_id         uuid not null,
    patient_profile_id      uuid not null,
    author_id               uuid not null,             -- profiles.id of the nurse/clinician
    text                    text not null,
    created_at              timestamptz not null default now()
);

alter table public.internal_notes
    drop constraint if exists internal_notes_conversation_id_fkey;
alter table public.internal_notes
    add constraint internal_notes_conversation_id_fkey
    foreign key (conversation_id) references public.conversations(id)
    on delete cascade;

alter table public.internal_notes
    drop constraint if exists internal_notes_patient_profile_id_fkey;
alter table public.internal_notes
    add constraint internal_notes_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.internal_notes
    drop constraint if exists internal_notes_author_id_fkey;
alter table public.internal_notes
    add constraint internal_notes_author_id_fkey
    foreign key (author_id) references public.profiles(id)
    on delete restrict;

-- ============================================================
-- Trigger: update_conversation_last_message
-- After INSERT on messages, set conversations.last_message_at and
-- last_message_preview (truncated to 200 chars).
-- ============================================================
create or replace function public.update_conversation_last_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if (tg_op = 'INSERT') then
        update public.conversations
        set last_message_at = new.created_at,
            last_message_preview = substring(new.text for 200),
            updated_at = now()
        where id = new.conversation_id;
    end if;
    return new;
end;
$$;

drop trigger if exists trg_conversation_last_message_ins on public.messages;
create trigger trg_conversation_last_message_ins
    after insert on public.messages
    for each row execute procedure public.update_conversation_last_message();

-- Done.
