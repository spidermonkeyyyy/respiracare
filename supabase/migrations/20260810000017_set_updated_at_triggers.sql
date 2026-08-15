-- ============================================================
-- Migration 017: set_updated_at triggers for all tables
-- Project: RespiraCare
-- Date: 2026-08-10
-- Uses moddatetime extension (enabled in Migration 001).
-- Pattern:
--   create trigger trg_<table>_set_updated_at
--     before update on public.<table>
--     for each row execute procedure moddatetime(updated_at);
-- ============================================================
-- Note: tables WITHOUT updated_at are excluded.

-- profiles
drop trigger if exists trg_profiles_set_updated_at on public.profiles;
create trigger trg_profiles_set_updated_at
    before update on public.profiles
    for each row execute procedure moddatetime(updated_at);

-- patient_profiles
drop trigger if exists trg_patient_profiles_set_updated_at on public.patient_profiles;
create trigger trg_patient_profiles_set_updated_at
    before update on public.patient_profiles
    for each row execute procedure moddatetime(updated_at);

-- nurse_profiles
drop trigger if exists trg_nurse_profiles_set_updated_at on public.nurse_profiles;
create trigger trg_nurse_profiles_set_updated_at
    before update on public.nurse_profiles
    for each row execute procedure moddatetime(updated_at);

-- monitoring_questions
drop trigger if exists trg_monitoring_questions_set_updated_at on public.monitoring_questions;
create trigger trg_monitoring_questions_set_updated_at
    before update on public.monitoring_questions
    for each row execute procedure moddatetime(updated_at);

-- alert_rules
drop trigger if exists trg_alert_rules_set_updated_at on public.alert_rules;
create trigger trg_alert_rules_set_updated_at
    before update on public.alert_rules
    for each row execute procedure moddatetime(updated_at);

-- alerts
drop trigger if exists trg_alerts_set_updated_at on public.alerts;
create trigger trg_alerts_set_updated_at
    before update on public.alerts
    for each row execute procedure moddatetime(updated_at);

-- conversations
drop trigger if exists trg_conversations_set_updated_at on public.conversations;
create trigger trg_conversations_set_updated_at
    before update on public.conversations
    for each row execute procedure moddatetime(updated_at);

-- tasks
drop trigger if exists trg_tasks_set_updated_at on public.tasks;
create trigger trg_tasks_set_updated_at
    before update on public.tasks
    for each row execute procedure moddatetime(updated_at);

-- care_requests
drop trigger if exists trg_care_requests_set_updated_at on public.care_requests;
create trigger trg_care_requests_set_updated_at
    before update on public.care_requests
    for each row execute procedure moddatetime(updated_at);

-- medications
drop trigger if exists trg_medications_set_updated_at on public.medications;
create trigger trg_medications_set_updated_at
    before update on public.medications
    for each row execute procedure moddatetime(updated_at);

-- medication_reminders
drop trigger if exists trg_medication_reminders_set_updated_at on public.medication_reminders;
create trigger trg_medication_reminders_set_updated_at
    before update on public.medication_reminders
    for each row execute procedure moddatetime(updated_at);

-- adherence_days
drop trigger if exists trg_adherence_days_set_updated_at on public.adherence_days;
create trigger trg_adherence_days_set_updated_at
    before update on public.adherence_days
    for each row execute procedure moddatetime(updated_at);

-- education_modules
drop trigger if exists trg_education_modules_set_updated_at on public.education_modules;
create trigger trg_education_modules_set_updated_at
    before update on public.education_modules
    for each row execute procedure moddatetime(updated_at);

-- rehabilitation_programs
drop trigger if exists trg_rehabilitation_programs_set_updated_at on public.rehabilitation_programs;
create trigger trg_rehabilitation_programs_set_updated_at
    before update on public.rehabilitation_programs
    for each row execute procedure moddatetime(updated_at);

-- exercises
drop trigger if exists trg_exercises_set_updated_at on public.exercises;
create trigger trg_exercises_set_updated_at
    before update on public.exercises
    for each row execute procedure moddatetime(updated_at);

-- video_submissions
drop trigger if exists trg_video_submissions_set_updated_at on public.video_submissions;
create trigger trg_video_submissions_set_updated_at
    before update on public.video_submissions
    for each row execute procedure moddatetime(updated_at);

-- inhaler_video_reviews
drop trigger if exists trg_inhaler_video_reviews_set_updated_at on public.inhaler_video_reviews;
create trigger trg_inhaler_video_reviews_set_updated_at
    before update on public.inhaler_video_reviews
    for each row execute procedure moddatetime(updated_at);

-- escalations
drop trigger if exists trg_escalations_set_updated_at on public.escalations;
create trigger trg_escalations_set_updated_at
    before update on public.escalations
    for each row execute procedure moddatetime(updated_at);

-- ============================================================
-- Tables intentionally WITHOUT updated_at trigger:
--   - nurse_patient_assignments          (uses assigned_at/unassigned_at)
--   - monitoring_submissions             (immutable post-evaluation)
--   - monitoring_answers                 (insert-only)
--   - rule_groups                        (insert-only)
--   - rule_conditions                    (insert-only)
--   - alert_rule_patients                (insert-only)
--   - alert_triggered_rules              (immutable)
--   - supporting_measurements            (immutable)
--   - messages                           (insert-only + deletion only)
--   - internal_notes                     (insert-only)
--   - program_exercises                  (insert-only)
--   - exercise_sessions                  (immutable)
--   - smoking_entries                    (insert + delete only)
--   - nurse_assessments                  (immutable)
-- ============================================================

-- Done.
