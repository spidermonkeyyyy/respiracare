-- ============================================================
-- Migration 016: indexes
-- Project: RespiraCare
-- Date: 2026-08-10
-- All supplementary indexes defined here. The most essential ones
-- were defined alongside their table migrations (e.g. partial UNIQUE
-- indexes needed for invariants). This migration covers the read-path
-- indexes described in Section 6 of the Step 2 v2.1 schema.
-- ============================================================
-- Convention: all indexes use IF NOT EXISTS. Re-running is safe.

-- ---------- profiles ----------
-- (idx_profiles_role, idx_profiles_is_active created in Migration 002.)

-- ---------- patient_profiles ----------
create index if not exists idx_patient_profiles_current_nurse
    on public.patient_profiles (current_nurse_id);
-- idx_patient_profiles_profile_id implicit via UNIQUE constraint.

-- ---------- nurse_profiles ----------
-- idx_nurse_profiles_profile_id implicit via UNIQUE constraint.

-- ---------- nurse_patient_assignments ----------
create index if not exists idx_npa_nurse_active
    on public.nurse_patient_assignments (nurse_profile_id)
    where unassigned_at is null;
create index if not exists idx_npa_patient_active
    on public.nurse_patient_assignments (patient_profile_id)
    where unassigned_at is null;
create index if not exists idx_npa_assigned_by
    on public.nurse_patient_assignments (assigned_by);

-- ---------- monitoring_questions ----------
create index if not exists idx_mq_active_order
    on public.monitoring_questions (is_active, "order")
    where is_active = true;

-- ---------- monitoring_submissions ----------
create index if not exists idx_ms_patient_submitted
    on public.monitoring_submissions (patient_profile_id, submitted_at desc);
create index if not exists idx_ms_pending_eval
    on public.monitoring_submissions (evaluation_status)
    where evaluation_status = 'pending';

-- ---------- monitoring_answers ----------
create index if not exists idx_ma_submission
    on public.monitoring_answers (submission_id);
create index if not exists idx_ma_question
    on public.monitoring_answers (question_id);
-- idx_ma_submission_question_unique already created in Migration 006.

-- ---------- alert_rules ----------
create index if not exists idx_alert_rules_enabled
    on public.alert_rules (is_enabled)
    where is_enabled = true;
create index if not exists idx_alert_rules_owner
    on public.alert_rules (created_by_nurse_id);

-- ---------- rule_groups ----------
create index if not exists idx_rule_groups_rule
    on public.rule_groups (rule_id);

-- ---------- rule_conditions ----------
create index if not exists idx_rule_conditions_group
    on public.rule_conditions (rule_group_id);

-- ---------- alerts ----------
create index if not exists idx_alerts_patient_status
    on public.alerts (patient_profile_id, status);
create index if not exists idx_alerts_nurse_open
    on public.alerts (assigned_nurse_id)
    where status in ('unread','acknowledged','in_progress');

-- ---------- alert_triggered_rules ----------
-- PK covers (alert_id, rule_id). Add reverse lookup index for completeness:
create index if not exists idx_atr_rule
    on public.alert_triggered_rules (rule_id);

-- ---------- supporting_measurements ----------
create index if not exists idx_supporting_measurements_alert
    on public.supporting_measurements (alert_id);

-- ---------- conversations ----------
create index if not exists idx_conversations_patient
    on public.conversations (patient_profile_id);
create index if not exists idx_conversations_last_msg
    on public.conversations (last_message_at desc nulls last);

-- ---------- messages ----------
create index if not exists idx_messages_conversation_created
    on public.messages (conversation_id, created_at);

-- ---------- internal_notes ----------
create index if not exists idx_internal_notes_conversation
    on public.internal_notes (conversation_id);
create index if not exists idx_internal_notes_patient
    on public.internal_notes (patient_profile_id);

-- ---------- tasks ----------
create index if not exists idx_tasks_patient_status
    on public.tasks (patient_profile_id, status);
create index if not exists idx_tasks_open_due
    on public.tasks (due_date)
    where status = 'open';

-- ---------- care_requests ----------
create index if not exists idx_care_requests_patient_status
    on public.care_requests (patient_profile_id, status);

-- ---------- medications ----------
create index if not exists idx_medications_patient_active
    on public.medications (patient_profile_id)
    where is_active = true;

-- ---------- medication_reminders ----------
create index if not exists idx_reminders_patient_status
    on public.medication_reminders (patient_profile_id, status);
create index if not exists idx_reminders_patient_date
    on public.medication_reminders (patient_profile_id, scheduled_at desc);

-- ---------- adherence_days ----------
create index if not exists idx_adherence_days_patient_date
    on public.adherence_days (patient_profile_id, date desc);

-- ---------- education_modules ----------
create index if not exists idx_education_modules_category_active
    on public.education_modules (category, is_active);

-- ---------- rehabilitation_programs ----------
create index if not exists idx_rehab_programs_patient_active
    on public.rehabilitation_programs (patient_profile_id, is_active)
    where is_active = true;

-- ---------- exercises ----------
create index if not exists idx_exercises_active_order
    on public.exercises ("order", is_active)
    where is_active = true;

-- ---------- program_exercises ----------
create index if not exists idx_program_exercises_program
    on public.program_exercises (program_id, order_in_program);

-- ---------- exercise_sessions ----------
create index if not exists idx_exercise_sessions_patient_completed
    on public.exercise_sessions (patient_profile_id, completed_at desc);

-- ---------- smoking_entries ----------
create index if not exists idx_smoking_entries_patient_date
    on public.smoking_entries (patient_profile_id, entry_date desc);

-- ---------- nurse_assessments ----------
create index if not exists idx_nurse_assessments_patient_created
    on public.nurse_assessments (patient_profile_id, created_at desc);
create index if not exists idx_nurse_assessments_nurse_created
    on public.nurse_assessments (nurse_id, created_at desc);

-- ---------- escalations ----------
create index if not exists idx_escalations_patient_status
    on public.escalations (patient_profile_id, status);
create index if not exists idx_escalations_pneumologist_open
    on public.escalations (pneumologist_id)
    where status <> 'resolved';

-- ---------- video_submissions ----------
create index if not exists idx_video_submissions_patient_uploaded
    on public.video_submissions (patient_profile_id, uploaded_at desc);
create index if not exists idx_video_submissions_pending
    on public.video_submissions (review_status)
    where review_status = 'pending_review';

-- ---------- inhaler_video_reviews ----------
create index if not exists idx_inhaler_reviews_patient
    on public.inhaler_video_reviews (patient_profile_id);
create index if not exists idx_inhaler_reviews_nurse
    on public.inhaler_video_reviews (nurse_id);

-- Done.
