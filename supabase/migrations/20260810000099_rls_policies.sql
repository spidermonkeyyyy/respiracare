-- ============================================================
-- Migration 999: Row Level Security Policies
-- Project: RespiraCare
-- Date: 2026-08-10
-- ------------------------------------------------------------
-- DEFINED BUT NOT EXECUTED. This migration is the security model
-- for the entire schema. It is intentionally deferred so that the
-- schema (Step 3) can exist without RLS during development, but the
-- access model is authored before any application code depends on it.
--
-- Guiding principles (from Step 2 v2.1):
--   * Patients: own data only. Never another patient's.
--   * Nurses: only assigned/authorized patients' data.
--   * internal_notes: NEVER readable by patients.
--   * Rules: soft-disable only, never delete; "own" enforced by
--     created_by_nurse_id.
--   * Alerts: indefinite no-delete; lifecycle enforced by trigger.
--   * Admin: broad read; no delete of clinical/audit history.
--
-- Conventions:
--   * All policies are idempotent (CREATE POLICY IF NOT EXISTS).
--   * Helper functions are SECURITY DEFINER, search_path pinned.
--   * When this migration is applied, call supabase db push / run in
--     the SQL editor; then the app's anon key will be governed by these.
-- ============================================================

-- ============================================================
-- SECTION A: HELPER FUNCTIONS
-- ============================================================

-- Current authenticated user's role.
create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
    select role from public.profiles where id = auth.uid();
$$;

-- Current user's patient_profiles.id (NULL if not a patient).
create or replace function public.current_patient_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
    select id from public.patient_profiles where profile_id = auth.uid();
$$;

-- Current user's nurse_profiles.id (NULL if not a nurse/pneumologist).
create or replace function public.current_nurse_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
    select id from public.nurse_profiles where profile_id = auth.uid();
$$;

-- Is the current user a nurse (or pneumologist)?
create or replace function public.is_nurse()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1 from public.nurse_profiles where profile_id = auth.uid()
    );
$$;

-- Is the current user the assigned nurse (or historically assigned) for a patient?
create or replace function public.is_assigned_to(p_patient uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1
        from public.nurse_patient_assignments
        where nurse_profile_id = public.current_nurse_id()
          and patient_profile_id = p_patient
          and unassigned_at is null
    );
$$;

-- Is the current user an admin?
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1 from public.profiles
        where id = auth.uid() and role = 'admin'
    );
$$;

-- Restrict helper functions: revoke PUBLIC, grant to authenticated only.
revoke execute on function public.current_user_role() from public;
revoke execute on function public.current_patient_id() from public;
revoke execute on function public.current_nurse_id() from public;
revoke execute on function public.is_nurse() from public;
revoke execute on function public.is_assigned_to(uuid) from public;
revoke execute on function public.is_admin() from public;
grant  execute on function public.current_user_role() to authenticated;
grant  execute on function public.current_patient_id() to authenticated;
grant  execute on function public.current_nurse_id() to authenticated;
grant  execute on function public.is_nurse() to authenticated;
grant  execute on function public.is_assigned_to(uuid) to authenticated;
grant  execute on function public.is_admin() to authenticated;

-- ============================================================
-- SECTION B: ENABLE RLS ON ALL 32 TABLES
-- ============================================================
alter table if exists public.profiles enable row level security;
alter table if exists public.patient_profiles enable row level security;
alter table if exists public.nurse_profiles enable row level security;
alter table if exists public.nurse_patient_assignments enable row level security;
alter table if exists public.monitoring_questions enable row level security;
alter table if exists public.monitoring_submissions enable row level security;
alter table if exists public.monitoring_answers enable row level security;
alter table if exists public.tasks enable row level security;
alter table if exists public.alert_rules enable row level security;
alter table if exists public.rule_groups enable row level security;
alter table if exists public.rule_conditions enable row level security;
alter table if exists public.alert_rule_patients enable row level security;
alter table if exists public.alerts enable row level security;
alter table if exists public.alert_triggered_rules enable row level security;
alter table if exists public.supporting_measurements enable row level security;
alter table if exists public.conversations enable row level security;
alter table if exists public.messages enable row level security;
alter table if exists public.internal_notes enable row level security;
alter table if exists public.care_requests enable row level security;
alter table if exists public.medications enable row level security;
alter table if exists public.medication_reminders enable row level security;
alter table if exists public.adherence_days enable row level security;
alter table if exists public.education_modules enable row level security;
alter table if exists public.rehabilitation_programs enable row level security;
alter table if exists public.exercises enable row level security;
alter table if exists public.program_exercises enable row level security;
alter table if exists public.exercise_sessions enable row level security;
alter table if exists public.smoking_entries enable row level security;
alter table if exists public.nurse_assessments enable row level security;
alter table if exists public.escalations enable row level security;
alter table if exists public.inhaler_video_reviews enable row level security;
alter table if exists public.video_submissions enable row level security;

-- ============================================================
-- SECTION C: PROFILES & IDENTITY
-- ============================================================

-- profiles: patient sees own; nurse sees own + assigned patients' profiles;
--           admin sees all. No delete for anyone except via cascade from auth.users.
drop policy if exists profiles_select_own_or_assigned on public.profiles;
create policy profiles_select_own_or_assigned on public.profiles
    for select using (
        id = auth.uid()
        or public.is_admin()
        or (
            public.is_nurse()
            and id in (
                select pp.profile_id
                from public.patient_profiles pp
                where public.is_assigned_to(pp.id)
            )
        )
    );

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
    for update using (id = auth.uid()) with check (id = auth.uid());

-- patient_profiles: patient own; nurse assigned; admin all. No delete (cascade only).
drop policy if exists patient_profiles_select on public.patient_profiles;
create policy patient_profiles_select on public.patient_profiles
    for select using (
        profile_id = auth.uid()
        or public.is_admin()
        or public.is_assigned_to(id)
    );

-- nurse_profiles: nurse own; admin all. Patients cannot read nurse profiles.
drop policy if exists nurse_profiles_select on public.nurse_profiles;
create policy nurse_profiles_select on public.nurse_profiles
    for select using (
        profile_id = auth.uid()
        or public.is_admin()
    );

-- nurse_patient_assignments: patients see own; nurses who are assigned
--   (or admins) see; INSERT requires assigned_by = auth.uid() and role in
--   (admin, nurse, pneumologist) — RLS-only authorization invariant
--   (Step 2 v2.1 decision 2 = A, no trigger).
drop policy if exists npa_select on public.nurse_patient_assignments;
create policy npa_select on public.nurse_patient_assignments
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or (public.is_nurse() and nurse_profile_id = public.current_nurse_id() and unassigned_at is null)
    );

drop policy if exists npa_insert on public.nurse_patient_assignments;
create policy npa_insert on public.nurse_patient_assignments
    for insert with check (
        assigned_by = auth.uid()
        and public.current_user_role() in ('admin','nurse','pneumologist')
    );

-- No UPDATE/DELETE policy: assignments are immutable once created; only the
-- unassigned_at transition is permitted via a dedicated policy.
drop policy if exists npa_unassign on public.nurse_patient_assignments;
create policy npa_unassign on public.nurse_patient_assignments
    for update using (
        public.is_admin()
        or (public.is_nurse() and nurse_profile_id = public.current_nurse_id())
    ) with check (
        public.is_admin()
        or (public.is_nurse() and nurse_profile_id = public.current_nurse_id())
    );

-- ============================================================
-- SECTION D: MONITORING
-- ============================================================

-- monitoring_questions: all authenticated roles may read active questions;
-- only admins (and the rule engine service) may modify. Patients cannot edit.
drop policy if exists mq_select on public.monitoring_questions;
create policy mq_select on public.monitoring_questions
    for select using (auth.uid() is not null);

-- monitoring_questions is config data: admins insert/update only (no delete,
-- so answered questions keep their meaning). Patients read via mq_select.
drop policy if exists mq_admin_write on public.monitoring_questions;
create policy mq_admin_write on public.monitoring_questions
    for update using (public.is_admin()) with check (public.is_admin());
create policy mq_admin_insert on public.monitoring_questions
    for insert with check (public.is_admin());

-- monitoring_submissions: patient owns; nurse assigned; admin all.
-- Immutable after evaluation: no UPDATE policy for anyone (handled by trigger;
-- only INSERT by owner, SELECT by owner/assigned/admin).
drop policy if exists ms_select on public.monitoring_submissions;
create policy ms_select on public.monitoring_submissions
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );

drop policy if exists ms_insert on public.monitoring_submissions;
create policy ms_insert on public.monitoring_submissions
    for insert with check (patient_profile_id = public.current_patient_id());

-- monitoring_answers: inherit from parent submission. Patient owns; nurse
-- assigned; admin all. No UPDATE/DELETE (insert-only).
drop policy if exists ma_select on public.monitoring_answers;
create policy ma_select on public.monitoring_answers
    for select using (
        exists (
            select 1 from public.monitoring_submissions ms
            where ms.id = submission_id
              and (
                ms.patient_profile_id = public.current_patient_id()
                or public.is_admin()
                or public.is_assigned_to(ms.patient_profile_id)
              )
        )
    );

drop policy if exists ma_insert on public.monitoring_answers;
create policy ma_insert on public.monitoring_answers
    for insert with check (
        exists (
            select 1 from public.monitoring_submissions ms
            where ms.id = submission_id
              and ms.patient_profile_id = public.current_patient_id()
        )
    );

-- ============================================================
-- SECTION E: TASKS & CARE REQUESTS
-- ============================================================

-- tasks: patient owns; nurse assigned (or creator) may manage; admin all.
drop policy if exists tasks_select on public.tasks;
create policy tasks_select on public.tasks
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );

drop policy if exists tasks_insert on public.tasks;
create policy tasks_insert on public.tasks
    for insert with check (
        patient_profile_id = public.current_patient_id()
        and (conversation_id is null
             or exists (select 1 from public.conversations c
                        where c.id = conversation_id
                          and c.patient_profile_id = public.current_patient_id()))
    );

drop policy if exists tasks_update on public.tasks;
create policy tasks_update on public.tasks
    for update using (
        public.is_admin()
        or public.is_assigned_to(patient_profile_id)
        or patient_profile_id = public.current_patient_id()
    ) with check (
        -- admin / assigned nurse may change anything within their gating.
        public.is_admin()
        or public.is_assigned_to(patient_profile_id)
        -- patient: may ONLY flip status to 'done' on their own task and must not
        -- alter any other column (immutability enforced column-by-column).
        or (
            patient_profile_id = public.current_patient_id()
            and (status = 'done')
            and old.patient_profile_id         is not distinct from new.patient_profile_id
            and old.conversation_id            is not distinct from new.conversation_id
            and old.task_type                  is not distinct from new.task_type
            and old.title                      is not distinct from new.title
            and old.description                is not distinct from new.description
            and old.action_route               is not distinct from new.action_route
            and old.due_date                   is not distinct from new.due_date
            and old.linked_care_request_id     is not distinct from new.linked_care_request_id
            and old.completed_at               is not distinct from new.completed_at
        )
    );

-- care_requests: nurse-created; patient can read own; nurse assigned can
-- manage; admin all. Patient cannot create (nurse-only workflow).
drop policy if exists cr_select on public.care_requests;
create policy cr_select on public.care_requests
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );

drop policy if exists cr_insert on public.care_requests;
create policy cr_insert on public.care_requests
    for insert with check (
        public.is_admin()
        or (public.is_nurse()
            and created_by_nurse_id = public.current_nurse_id()
            and public.is_assigned_to(patient_profile_id))
    );

drop policy if exists cr_update on public.care_requests;
create policy cr_update on public.care_requests
    for update using (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );

-- ============================================================
-- SECTION F: COMMUNICATION  (security-critical boundary)
-- ============================================================

-- conversations: patient owns own conversation; nurse assigned (or admin) may
-- read. No delete. Patients may start a conversation for their own profile;
-- nurses and admins may create conversations for patients they manage.
drop policy if exists conv_select on public.conversations;
create policy conv_select on public.conversations
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );

drop policy if exists conv_insert on public.conversations;
create policy conv_insert on public.conversations
    for insert with check (
        public.is_admin()
        or public.is_nurse()
        or patient_profile_id = public.current_patient_id()
    );

-- messages: participants (patient or their assigned nurse) can read; each
-- participant may insert their own. Patients insert with sender_role='patient';
-- nurses insert with sender_role in ('care_team','system').
drop policy if exists msg_select on public.messages;
create policy msg_select on public.messages
    for select using (
        exists (
            select 1 from public.conversations c
            where c.id = conversation_id
              and (
                c.patient_profile_id = public.current_patient_id()
                or public.is_admin()
                or public.is_assigned_to(c.patient_profile_id)
              )
        )
    );

drop policy if exists msg_insert_patient on public.messages;
create policy msg_insert_patient on public.messages
    for insert with check (
        sender_role = 'patient'
        and sender_profile_id = auth.uid()
        and exists (
            select 1 from public.conversations c
            where c.id = conversation_id
              and c.patient_profile_id = public.current_patient_id()
        )
    );

drop policy if exists msg_insert_careteam on public.messages;
create policy msg_insert_careteam on public.messages
    for insert with check (
        sender_role in ('care_team','system')
        and (public.is_admin() or public.is_nurse())
        and exists (
            select 1 from public.conversations c
            where c.id = conversation_id
              and (public.is_admin() or public.is_assigned_to(c.patient_profile_id))
        )
    );

-- messages UPDATE only to flip delivery_status read (recipient acknowledging).
-- Patients cannot alter care-team messages; nurses cannot alter patient messages.
drop policy if exists msg_update on public.messages;
create policy msg_update on public.messages
    for update using (
        -- Recipient acknowledges: patient acknowledging care_team messages
        (public.current_user_role() = 'patient' and sender_role <> 'patient')
        or
        -- Nurse acknowledging patient messages
        (public.is_nurse() and sender_role = 'patient')
        or public.is_admin()
    ) with check (
        -- Only the read-state transition is permitted; the message body and
        -- metadata are immutable once inserted (no sender may rewrite them).
        delivery_status = 'read'
        and old.text                    is not distinct from new.text
        and old.sender_role             is not distinct from new.sender_role
        and old.sender_profile_id       is not distinct from new.sender_profile_id
        and old.message_type            is not distinct from new.message_type
        and old.action_label            is not distinct from new.action_label
        and old.action_route            is not distinct from new.action_route
        and old.linked_care_request_id  is not distinct from new.linked_care_request_id
        and old.linked_task_id          is not distinct from new.linked_task_id
        and old.created_at              is not distinct from new.created_at
    );

-- internal_notes: STRICT — never readable by patients. Only nurses/pneumologists
-- (assigned) and admins may read or write. This is the architectural separation
-- enforced at the database layer (Step 2 v2.1 / correction #1).
drop policy if exists in_select on public.internal_notes;
create policy in_select on public.internal_notes
    for select using (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );

drop policy if exists in_insert on public.internal_notes;
create policy in_insert on public.internal_notes
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );

-- NO UPDATE/DELETE on internal_notes: append-only nurse notes.

-- ============================================================
-- SECTION G: ALERTS & RULES  (audit-critical)
-- ============================================================

-- alert_rules: nurses can read all enabled rules (for selection) and manage
-- their own (created_by_nurse_id). NO DELETE for any role (soft-disable only).
drop policy if exists ar_select on public.alert_rules;
create policy ar_select on public.alert_rules
    for select using (public.is_admin() or public.is_nurse());

drop policy if exists ar_insert on public.alert_rules;
create policy ar_insert on public.alert_rules
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and created_by_nurse_id = public.current_nurse_id())
    );

drop policy if exists ar_update on public.alert_rules;
create policy ar_update on public.alert_rules
    for update using (
        public.is_admin()
        or (public.is_nurse() and created_by_nurse_id = public.current_nurse_id())
    ) with check (
        -- never allows changing ownership
        (public.is_admin() or (public.is_nurse() and created_by_nurse_id = public.current_nurse_id()))
        and (created_by_nurse_id = (select created_by_nurse_id from public.alert_rules where id = alert_rules.id))
    );

-- No DELETE policy on alert_rules (soft-disable only). Admin uses is_enabled=false.

-- rule_groups / rule_conditions: inherit from parent rule ownership.
drop policy if exists rg_select on public.rule_groups;
create policy rg_select on public.rule_groups
    for select using (public.is_admin() or public.is_nurse());

drop policy if exists rg_write on public.rule_groups;
create policy rg_insert on public.rule_groups
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.alert_rules ar
            where ar.id = rule_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    );
create policy rg_update on public.rule_groups
    for update using (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.alert_rules ar
            where ar.id = rule_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.alert_rules ar
            where ar.id = rule_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    );
-- Rule child tables are NEVER deleted (soft-disable only); explicit denial.
drop policy if exists rg_no_delete on public.rule_groups;
create policy rg_no_delete on public.rule_groups for delete using (false);

drop policy if exists rc_select on public.rule_conditions;
create policy rc_select on public.rule_conditions
    for select using (public.is_admin() or public.is_nurse());

drop policy if exists rc_write on public.rule_conditions;
create policy rc_insert on public.rule_conditions
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.rule_groups rg
            join public.alert_rules ar on ar.id = rg.rule_id
            where rg.id = rule_group_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    );
create policy rc_update on public.rule_conditions
    for update using (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.rule_groups rg
            join public.alert_rules ar on ar.id = rg.rule_id
            where rg.id = rule_group_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.rule_groups rg
            join public.alert_rules ar on ar.id = rg.rule_id
            where rg.id = rule_group_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    );
drop policy if exists rc_no_delete on public.rule_conditions;
create policy rc_no_delete on public.rule_conditions for delete using (false);

drop policy if exists arp_select on public.alert_rule_patients;
create policy arp_select on public.alert_rule_patients
    for select using (public.is_admin() or public.is_nurse());

drop policy if exists arp_write on public.alert_rule_patients;
create policy arp_insert on public.alert_rule_patients
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.alert_rules ar
            where ar.id = alert_rule_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    );
create policy arp_update on public.alert_rule_patients
    for update using (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.alert_rules ar
            where ar.id = alert_rule_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and exists (
            select 1 from public.alert_rules ar
            where ar.id = alert_rule_id and ar.created_by_nurse_id = public.current_nurse_id()
        ))
    );
drop policy if exists arp_no_delete on public.alert_rule_patients;
create policy arp_no_delete on public.alert_rule_patients for delete using (false);

-- alerts: patient reads own (read-only); nurse assigned may read + advance
-- lifecycle; admin all. NO DELETE for any role (indefinite no-delete).
-- INSERT of alerts is performed ONLY by the alert-rule engine using the
-- Supabase service_role key (which bypasses RLS). There is intentionally NO
-- INSERT policy here so that no authenticated client JWT can create alerts
-- directly. If client-side alert creation is ever required, an alerts_insert
-- policy (service-role-only or tightly scoped) must be added before enabling.
drop policy if exists alerts_select on public.alerts;
create policy alerts_select on public.alerts
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );

drop policy if exists alerts_update on public.alerts;
create policy alerts_update on public.alerts
    for update using (
        public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    ) with check (
        -- Immutable origin/audit fields: locked for everyone, including admin,
        -- so the alert record can never be retrospectively rewritten.
        old.reason                is not distinct from new.reason
        and old.priority          is not distinct from new.priority
        and old.submission_id     is not distinct from new.submission_id
        and old.assigned_nurse_id is not distinct from new.assigned_nurse_id
        and old.patient_profile_id is not distinct from new.patient_profile_id
        and old.created_at        is not distinct from new.created_at
        and old.id                is not distinct from new.id
        -- status lifecycle still enforced by the DB forward-only trigger (008).
        and (public.is_admin() or public.is_assigned_to(patient_profile_id))
    );

-- alert_triggered_rules: immutable. Select by participants; no write/delete.
drop policy if exists atr_select on public.alert_triggered_rules;
create policy atr_select on public.alert_triggered_rules
    for select using (
        public.is_admin()
        or exists (
            select 1 from public.alerts a
            where a.id = alert_id
              and (a.patient_profile_id = public.current_patient_id()
                   or public.is_assigned_to(a.patient_profile_id))
        )
    );

-- supporting_measurements: immutable. Select by participants; no write/delete.
drop policy if exists sm_select on public.supporting_measurements;
create policy sm_select on public.supporting_measurements
    for select using (
        public.is_admin()
        or exists (
            select 1 from public.alerts a
            where a.id = alert_id
              and (a.patient_profile_id = public.current_patient_id()
                   or public.is_assigned_to(a.patient_profile_id))
        )
    );

-- ============================================================
-- SECTION H: TREATMENT, EDUCATION, REHAB, SMOKING, NURSE ACTIONS, VIDEO
-- ============================================================

-- medications: patient owns; nurse assigned; admin all.
drop policy if exists med_select on public.medications;
create policy med_select on public.medications
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
drop policy if exists med_admin_write on public.medications;
create policy med_insert on public.medications
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );
create policy med_update on public.medications
    for update using (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );

-- medication_reminders: patient owns; nurse assigned; admin all.
drop policy if exists mr_select on public.medication_reminders;
create policy mr_select on public.medication_reminders
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
drop policy if exists mr_insert on public.medication_reminders;
create policy mr_insert on public.medication_reminders
    for insert with check (patient_profile_id = public.current_patient_id());
drop policy if exists mr_update on public.medication_reminders;
create policy mr_update on public.medication_reminders
    for update using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    ) with check (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );

-- adherence_days: read by owner/assigned/admin only (derived; never written via app).
drop policy if exists ad_select on public.adherence_days;
create policy ad_select on public.adherence_days
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
-- No INSERT/UPDATE/DELETE policy: maintained by trigger only.

-- education_modules: patients see only validated (is_placeholder=false) + active;
-- nurses see all active; admins all.
-- NOTE: current_user_role() returns NULL when the profiles row is missing, so the
-- patient branch evaluates to NULL -> denied (fail-closed). This is intended.
drop policy if exists em_select on public.education_modules;
create policy em_select on public.education_modules
    for select using (
        public.is_admin()
        or (public.is_nurse() and is_active)
        or (public.current_user_role() = 'patient' and is_active and not is_placeholder)
    );

-- rehabilitation_programs: patient owns; nurse assigned; admin all.
drop policy if exists rp_select on public.rehabilitation_programs;
create policy rp_select on public.rehabilitation_programs
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
drop policy if exists rp_admin_write on public.rehabilitation_programs;
create policy rp_insert on public.rehabilitation_programs
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );
create policy rp_update on public.rehabilitation_programs
    for update using (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );

-- exercises: all authenticated may read; only admins may write.
drop policy if exists ex_select on public.exercises;
create policy ex_select on public.exercises
    for select using (auth.uid() is not null);
-- exercises is a shared catalogue: only admins may write (nurses read via
-- ex_select). Removing nurse write prevents one nurse editing another's library.
drop policy if exists ex_admin_write on public.exercises;
create policy ex_admin_write on public.exercises
    for all using (public.is_admin()) with check (public.is_admin());

-- program_exercises: inherit from parent program.
drop policy if exists pe_select on public.program_exercises;
create policy pe_select on public.program_exercises
    for select using (
        public.is_admin()
        or exists (
            select 1 from public.rehabilitation_programs rp
            where rp.id = program_id
              and (rp.patient_profile_id = public.current_patient_id()
                   or public.is_assigned_to(rp.patient_profile_id))
        )
    );

-- exercise_sessions: patient owns (insert own); nurse assigned read; admin all.
-- Immutable: no UPDATE/DELETE.
drop policy if exists es_select on public.exercise_sessions;
create policy es_select on public.exercise_sessions
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
drop policy if exists es_insert on public.exercise_sessions;
create policy es_insert on public.exercise_sessions
    for insert with check (patient_profile_id = public.current_patient_id());

-- smoking_entries: patient owns (CRUD own); nurse assigned read; admin all.
drop policy if exists se_select on public.smoking_entries;
create policy se_select on public.smoking_entries
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
drop policy if exists se_insert on public.smoking_entries;
create policy se_insert on public.smoking_entries
    for insert with check (patient_profile_id = public.current_patient_id());
drop policy if exists se_update on public.smoking_entries;
create policy se_update on public.smoking_entries
    for update using (patient_profile_id = public.current_patient_id())
    with check (patient_profile_id = public.current_patient_id());
drop policy if exists se_delete on public.smoking_entries;
create policy se_delete on public.smoking_entries
    for delete using (patient_profile_id = public.current_patient_id());

-- nurse_assessments: immutable audit trail. INSERT-ONLY.
-- WRITTEN ONLY by the privileged rule-engine / assessment service using the
-- Supabase service_role key (which bypasses RLS). There is intentionally NO
-- INSERT/UPDATE/DELETE policy here so that no authenticated client (patient,
-- nurse, or pneumologist JWT) can ever write or alter an assessment row.
-- If the Flutter app ever needs to insert assessments via a user JWT, a
-- na_insert policy gated on (is_nurse() and is_assigned_to(patient_profile_id))
-- must be added first. SELECT is scoped to assigned/own nurse + admin.
drop policy if exists na_select on public.nurse_assessments;
create policy na_select on public.nurse_assessments
    for select using (
        public.is_admin()
        or public.is_assigned_to(patient_profile_id)
        or nurse_id = public.current_nurse_id()
    );

-- escalations: nurse owns (created by current nurse); patient reads own;
-- pneumologist assigned reads; admin all. Lifecycle update permitted.
drop policy if exists esc_select on public.escalations;
create policy esc_select on public.escalations
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
        or (pneumologist_id = auth.uid() and public.current_user_role() = 'pneumologist')
        or nurse_id = public.current_nurse_id()
    );
drop policy if exists esc_insert on public.escalations;
create policy esc_insert on public.escalations
    for insert with check (
        public.is_admin()
        or (public.is_nurse()
            and nurse_id = public.current_nurse_id()
            and public.is_assigned_to(patient_profile_id))
    );
drop policy if exists esc_update on public.escalations;
create policy esc_update on public.escalations
    for update using (
        public.is_admin()
        or public.is_assigned_to(patient_profile_id)
        or (pneumologist_id = auth.uid() and public.current_user_role() = 'pneumologist')
        or nurse_id = public.current_nurse_id()
    ) with check (
        -- Immutable origin fields; only the lifecycle/status and supporting
        -- info may change. authorized roles verified above.
        old.nurse_id               is not distinct from new.nurse_id
        and old.reason             is not distinct from new.reason
        and old.patient_profile_id is not distinct from new.patient_profile_id
        and old.created_at         is not distinct from new.created_at
        and (
            public.is_admin()
            or public.is_assigned_to(patient_profile_id)
            or (pneumologist_id = auth.uid() and public.current_user_role() = 'pneumologist')
            or nurse_id = public.current_nurse_id()
        )
    );

-- inhaler_video_reviews: nurse writes (assigned); patient sees only status via
-- video_submissions; admin all.
drop policy if exists ivr_select on public.inhaler_video_reviews;
create policy ivr_select on public.inhaler_video_reviews
    for select using (
        public.is_admin()
        or public.is_assigned_to(patient_profile_id)
        or patient_profile_id = public.current_patient_id()
    );
drop policy if exists ivr_write on public.inhaler_video_reviews;
create policy ivr_insert on public.inhaler_video_reviews
    for insert with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );
create policy ivr_update on public.inhaler_video_reviews
    for update using (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    ) with check (
        public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );
-- Review records are clinical findings; explicit no-delete.
drop policy if exists ivr_no_delete on public.inhaler_video_reviews;
create policy ivr_no_delete on public.inhaler_video_reviews for delete using (false);

-- video_submissions: patient owns (upload own); nurse assigned read; admin all.
drop policy if exists vs_select on public.video_submissions;
create policy vs_select on public.video_submissions
    for select using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or public.is_assigned_to(patient_profile_id)
    );
drop policy if exists vs_insert on public.video_submissions;
create policy vs_insert on public.video_submissions
    for insert with check (patient_profile_id = public.current_patient_id());
drop policy if exists vs_update on public.video_submissions;
create policy vs_update on public.video_submissions
    for update using (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    ) with check (
        patient_profile_id = public.current_patient_id()
        or public.is_admin()
        or (public.is_nurse() and public.is_assigned_to(patient_profile_id))
    );

-- ============================================================
-- SECTION I: STORAGE (policy note, not created here)
-- ============================================================
-- Storage buckets (avatars, inhaler-videos, education-media) are created via
-- Supabase dashboard / CLI. Corresponding storage.object policies are defined
-- in a separate Step 13 migration. The table-level RLS above already restricts
-- which rows reference which storage paths. Recommendation: storage policies
-- mirror the table policies (patient may upload to inhaler-videos/{own_id}/*;
-- assigned nurse read-only; education-media public read, admin write).

-- ============================================================
-- END OF MIGRATION 999
-- ============================================================
select 'Migration 999 (RLS) defined — not executed. Review before applying.' as note;
