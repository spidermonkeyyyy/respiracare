-- ============================================================
-- Migration 007: alert_rules + rule_groups + rule_conditions
--               + alert_rule_patients
-- Project: RespiraCare
-- Date: 2026-08-10
-- Corrections applied (v2.1):
--   - NO circular FK. Creation order: alert_rules → rule_groups →
--     rule_conditions. rule_groups.rule_id is the sole FK.
--   - alert_rules.root_group_id is REMOVED; the root group is the
--     single row in rule_groups whose rule_id = the rule (enforced by
--     UNIQUE constraint on rule_groups.rule_id).
--   - alert_rules.created_by_nurse_id is NOT NULL, enabling RLS
--     "only own" enforcement.
--   - claim of future nested groups is REMOVED; the schema supports
--     rule → 1 root group → N flat conditions only.
-- ============================================================

-- ---------- alert_rules ----------
create table if not exists public.alert_rules (
    id                      uuid primary key default gen_random_uuid(),
    name                    text not null,
    description             text not null default '',
    is_enabled              boolean not null default true,
    action                  text not null default 'create_alert'
                            check (action in ('create_alert','flag_for_review')),
    priority                text not null default 'medium'
                            check (priority in ('high','medium','low','informational')),
    created_by_nurse_id     uuid not null,        -- NEW (v2.1 correction #7)
    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now()
);

alter table public.alert_rules
    drop constraint if exists alert_rules_created_by_nurse_id_fkey;
alter table public.alert_rules
    add constraint alert_rules_created_by_nurse_id_fkey
    foreign key (created_by_nurse_id) references public.nurse_profiles(id)
    on delete restrict;

-- ---------- rule_groups ----------
-- Sole FK direction: rule_groups.rule_id → alert_rules.id.
-- UNIQUE(rule_id) guarantees one root group per rule.
create table if not exists public.rule_groups (
    id          uuid primary key default gen_random_uuid(),
    rule_id     uuid not null,
    mode        text not null default 'all'
                check (mode in ('all','any')),         -- Dart ConditionGroupMode
    created_at  timestamptz not null default now()
);

alter table public.rule_groups
    drop constraint if exists rule_groups_rule_id_fkey;
alter table public.rule_groups
    add constraint rule_groups_rule_id_fkey
    foreign key (rule_id) references public.alert_rules(id)
    on delete cascade;

alter table public.rule_groups
    drop constraint if exists rule_groups_rule_id_unique;
alter table public.rule_groups
    add constraint rule_groups_rule_id_unique unique (rule_id);

-- ---------- rule_conditions ----------
create table if not exists public.rule_conditions (
    id                  uuid primary key default gen_random_uuid(),
    rule_group_id       uuid not null,
    metric              text not null,                -- e.g. 'spo2', 'dyspnea'
    metric_label        text not null,                -- denormalised for rendering
    operator            text not null
                        check (operator in (
                            'equals','not_equals',
                            'greater_than','less_than',
                            'greater_than_or_equal','less_than_or_equal',
                            'increased_from_baseline','decreased_from_baseline',
                            'changed'
                        )),                           -- ALL 9 Dart RuleOperator values
    value               text,                        -- free-form operand text
    unit                text not null default '',
    comparison_mode     text not null default 'absolute'
                        check (comparison_mode in ('absolute','baseline','trend')),
    created_at          timestamptz not null default now(),
    -- Invariant mirrors Dart RuleOperator.requiresValue = false for 'changed'
    constraint rule_conditions_changed_no_value
        check (operator <> 'changed' or value is null or value = '')
);

alter table public.rule_conditions
    drop constraint if exists rule_conditions_rule_group_id_fkey;
alter table public.rule_conditions
    add constraint rule_conditions_rule_group_id_fkey
    foreign key (rule_group_id) references public.rule_groups(id)
    on delete cascade;

-- ---------- alert_rule_patients (scope override) ----------
create table if not exists public.alert_rule_patients (
    alert_rule_id        uuid not null,
    patient_profile_id   uuid not null,
    created_at           timestamptz not null default now(),
    primary key (alert_rule_id, patient_profile_id)
);

alter table public.alert_rule_patients
    drop constraint if exists alert_rule_patients_alert_rule_id_fkey;
alter table public.alert_rule_patients
    add constraint alert_rule_patients_alert_rule_id_fkey
    foreign key (alert_rule_id) references public.alert_rules(id)
    on delete restrict;             -- rules never delete anyway

alter table public.alert_rule_patients
    drop constraint if exists alert_rule_patients_patient_profile_id_fkey;
alter table public.alert_rule_patients
    add constraint alert_rule_patients_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete cascade;

-- Done.
