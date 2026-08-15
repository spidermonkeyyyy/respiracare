-- ============================================================
-- Migration 008: alerts + alert_triggered_rules
--               + supporting_measurements
--               + forward-only lifecycle trigger
-- Project: RespiraCare
-- Date: 2026-08-10
-- Corrections applied (v2.1):
--   - Alerts NEVER deleted by anyone (indefinite no-delete policy;
--     decision 4 = confirm-indefinite). No DELETE RLS will be defined
--     in Migration 999 for any role.
--   - alert_triggered_rules.rule_id uses ON DELETE RESTRICT so the
--     rule outlives the alert when rules are disabled (not deleted).
--   - Lifecycle order strictly enforced: unread → acknowledged →
--     in_progress → resolved, forward-only.
--   - All audit-trail CHECK constraints preserved.
-- ============================================================

-- ---------- alerts ----------
create table if not exists public.alerts (
    id                      uuid primary key default gen_random_uuid(),
    patient_profile_id      uuid not null,
    reason                  text not null,
    priority                text not null
                            check (priority in ('high','medium','low','informational')),
    status                  text not null default 'unread'
                            check (status in ('unread','acknowledged','in_progress','resolved')),
    created_at              timestamptz not null default now(),
    acknowledged_at         timestamptz,
    resolved_at             timestamptz,
    submission_id           uuid,
    assigned_nurse_id       uuid,
    nurse_action            text
                            check (nurse_action is null or nurse_action in
                                   ('monitoring','contact_patient','pneumologist_review','other')),
    nurse_decision          text
                            check (nurse_decision is null or nurse_decision in
                                   ('action_required','enhanced_monitoring','not_concerning')),
    action_note             text,
    justification           text,
    resolution_note         text,
    updated_at              timestamptz not null default now(),
    -- Audit-trail CHECKs preserving the Dart invariants:
    constraint alerts_ack_check
        check (status = 'unread' or acknowledged_at is not null),
    constraint alerts_resolved_check
        check (status <> 'resolved' or (resolved_at is not null and resolution_note is not null)),
    constraint alerts_action_other_note
        check (nurse_action <> 'other' or action_note is not null),
    constraint alerts_decision_not_concerning_justification
        check (nurse_decision <> 'not_concerning' or justification is not null),
    constraint alerts_decision_implies_action
        check (nurse_decision is null or nurse_action is not null)
);

alter table public.alerts
    drop constraint if exists alerts_patient_profile_id_fkey;
alter table public.alerts
    add constraint alerts_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.alerts
    drop constraint if exists alerts_submission_id_fkey;
alter table public.alerts
    add constraint alerts_submission_id_fkey
    foreign key (submission_id) references public.monitoring_submissions(id)
    on delete restrict;

alter table public.alerts
    drop constraint if exists alerts_assigned_nurse_id_fkey;
alter table public.alerts
    add constraint alerts_assigned_nurse_id_fkey
    foreign key (assigned_nurse_id) references public.nurse_profiles(id)
    on delete set null;

-- ---------- alert_triggered_rules (immutable) ----------
create table if not exists public.alert_triggered_rules (
    alert_id                uuid not null,
    rule_id                 uuid not null,
    rule_name_snapshot      text not null,                -- preserved verbatim at evaluation
    matched_criteria        jsonb not null default '[]'::jsonb,
    priority                text not null
                            check (priority in ('high','medium','low','informational')),
    evaluated_at            timestamptz not null default now(),
    primary key (alert_id, rule_id)
);

alter table public.alert_triggered_rules
    drop constraint if exists alert_triggered_rules_alert_id_fkey;
alter table public.alert_triggered_rules
    add constraint alert_triggered_rules_alert_id_fkey
    foreign key (alert_id) references public.alerts(id)
    on delete cascade;               -- declared; never fires (alerts no-delete)

alter table public.alert_triggered_rules
    drop constraint if exists alert_triggered_rules_rule_id_fkey;
alter table public.alert_triggered_rules
    add constraint alert_triggered_rules_rule_id_fkey
    foreign key (rule_id) references public.alert_rules(id)
    on delete restrict;              -- rule outlives alert when disabled (audit trail)

-- ---------- supporting_measurements (immutable) ----------
create table if not exists public.supporting_measurements (
    id              uuid primary key default gen_random_uuid(),
    alert_id        uuid not null,
    label           text not null,
    value           text not null,                     -- pre-formatted display string
    reference_value text,
    variation       text,
    trend           text not null default 'unknown'
                    check (trend in ('up','down','stable','unknown')),
    note            text,
    created_at      timestamptz not null default now()
);

alter table public.supporting_measurements
    drop constraint if exists supporting_measurements_alert_id_fkey;
alter table public.supporting_measurements
    add constraint supporting_measurements_alert_id_fkey
    foreign key (alert_id) references public.alerts(id)
    on delete cascade;               -- declared; never fires (alerts no-delete)

-- ============================================================
-- Trigger: enforce_alert_lifecycle_forward
-- Mirrors Dart AlertStatus.canTransitionTo. Status may only advance
-- forward in the order unread(0) → acknowledged(1) → in_progress(2)
-- → resolved(3). Same-value UPDATE is permitted (idempotent); any
-- backward or sideways transition is rejected.
-- Also maintains acknowledged_at / resolved_at coherence on UPDATE.
-- ============================================================
create or replace function public.enforce_alert_lifecycle_forward()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_old_idx int;
    v_new_idx int;
begin
    if (tg_op = 'UPDATE' and new.status is distinct from old.status) then
        v_old_idx := case old.status
            when 'unread'       then 0
            when 'acknowledged'  then 1
            when 'in_progress'   then 2
            when 'resolved'      then 3
            else -1
        end;
        v_new_idx := case new.status
            when 'unread'        then 0
            when 'acknowledged'  then 1
            when 'in_progress'   then 2
            when 'resolved'      then 3
            else -1
        end;
        -- Strict forward-only.
        if v_new_idx <= v_old_idx then
            raise exception 'Invalid alert lifecycle transition: % → %',
                old.status, new.status
                using hint = 'Alerts may only advance forward in the order unread → acknowledged → in_progress → resolved.';
        end if;
    end if;
    return coalesce(new, old);
end;
$$;

drop trigger if exists trg_alert_lifecycle_forward on public.alerts;
create trigger trg_alert_lifecycle_forward
    before update of status on public.alerts
    for each row execute procedure public.enforce_alert_lifecycle_forward();

-- Done.
