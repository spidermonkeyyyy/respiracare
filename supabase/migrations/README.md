# RespiraCare — Supabase Migrations

This directory holds the SQL migrations that create the RespiraCare
PostgreSQL schema. They were derived (Step 2 → Step 3) from the
existing Flutter domain models and finalized in the Step 2 v2.1
schema document (approved 2026-08-10).

## How to apply

The preferred way is via the Supabase CLI:

```bash
supabase db push
# or, for a fresh project:
supabase migration up
```

Files are named `<YYYYMMDDHHMMSS>_<topic>.sql` and apply in
lexicographic (timestamp) order. Every statement is idempotent
(`create table if not exists`, `drop constraint if exists`, etc.),
so re-running is safe during development.

> IMPORTANT: These migrations do NOT enable Row Level Security or
> create RLS policies. That is deferred to Migration 999 / Step 15.
> Until then the schema is permissive; do NOT load production data.

## Files

| # | File | Creates |
|---|------|----------|
| 001 | 20260810000001_extensions.sql | pgcrypto, uuid-ossp, moddatetime |
| 002 | 20260810000002_profiles.sql | profiles + auth bridge triggers (NEW.id) |
| 003 | 20260810000003_patient_nurse_profiles.sql | patient_profiles, nurse_profiles |
| 004 | 20260810000004_nurse_patient_assignments.sql | nurse_patient_assignments + current_nurse_id sync |
| 005 | 20260810000005_monitoring_questions.sql | monitoring_questions (seeds 4 questions) |
| 006 | 20260810000006_monitoring_submissions.sql | monitoring_submissions, monitoring_answers + spo2 trigger |
| 007 | 20260810000007_alert_rules.sql | alert_rules, rule_groups, rule_conditions, alert_rule_patients |
| 008 | 20260810000008_alerts.sql | alerts, alert_triggered_rules, supporting_measurements + lifecycle trigger |
| 009 | 20260810000009_communication.sql | conversations, messages, internal_notes + last-message trigger |
| 010 | 20260810000010_tasks_care_requests.sql | tasks, care_requests (+ forward FKs from messages) |
| 011 | 20260810000011_treatment_adherence.sql | medications, medication_reminders, adherence_days + trigger |
| 012 | 20260810000012_education_modules.sql | education_modules |
| 013 | 20260810000013_rehabilitation.sql | rehabilitation_programs, exercises, program_exercises, exercise_sessions |
| 014 | 20260810000014_smoking_entries.sql | smoking_entries |
| 015 | 20260810000015_nurse_clinical_actions.sql | nurse_assessments, escalations, inhaler_video_reviews, video_submissions |
| 016 | 20260810000016_indexes.sql | supplementary read-path indexes |
| 017 | 20260810000017_set_updated_at_triggers.sql | moddatetime triggers for all updated_at tables |
| 018 | 20260810000018_alert_lifecycle_consolidation.sql | documentation consolidation (lifecycle already in 008) |

## Schema facts

- 32 tables total.
- All primary keys are `uuid` (default `gen_random_uuid()`).
- All timestamps are `timestamptz` (UTC).
- All enums are `text` with `CHECK` constraints (no Postgres ENUM type).
- `profiles.id` = `auth.users.id` (1:1), populated by the
  `handle_new_user` trigger using `NEW.id`.
- `patient_profiles.id` / `nurse_profiles.id` are independent domain
  UUIDs (not aliases of `profiles.id`).
- Rules are soft-disabled only — no `DELETE` policy (added in 999).
- Alerts are never deleted (indefinite no-delete policy).
- `internal_notes` is a separate table, never patient-readable.
- `alerts.status` is forward-only (unread → acknowledged →
  in_progress → resolved), enforced by trigger + CHECK.

## Not included here

- RLS policies (Migration 999, Step 15).
- Storage bucket creation (Step 13 — Supabase dashboard / CLI).
- Seed data beyond the 4 monitoring questions (clinical content,
  demo patients/nurses are authored separately).
