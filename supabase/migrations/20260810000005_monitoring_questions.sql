-- ============================================================
-- Migration 005: monitoring_questions (with seed data)
-- Project: RespiraCare
-- Date: 2026-08-10
-- Decision 3 (Step 2 v2.1 approval): id is uuid PK; question_key is
-- a separate UNIQUE text column holding the Dart identifier.
-- Seeds: 'dyspnea', 'cough', 'sputum', 'spo2' — exactly the four
-- questions returned by MockMonitoringRepository.getQuestions().
-- ============================================================

create table if not exists public.monitoring_questions (
    id              uuid primary key default gen_random_uuid(),
    question_key    text not null,
    type            text not null
                    check (type in ('single_choice','numeric_input')),
    title           text not null,
    description     text,
    options_json    jsonb,                     -- array of {id,label,description?}
    is_required     boolean not null default true,
    "order"         integer not null,           -- "order" is reserved; quoted
    unit            text,
    min_value       numeric,
    max_value       numeric,
    is_active       boolean not null default true,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

alter table public.monitoring_questions
    drop constraint if exists monitoring_questions_question_key_unique;
alter table public.monitoring_questions
    add constraint monitoring_questions_question_key_unique unique (question_key);

-- ---------- seed the four questions ----------
-- Mirrors MockMonitoringRepository.getQuestions() verbatim (French strings).

insert into public.monitoring_questions
    (question_key, type, title, description, options_json, is_required, "order", unit, min_value, max_value)
values
    (
        'dyspnea',
        'single_choice',
        'Comment évaluez-vous votre essoufflement aujourd''hui ?',
        'Échelle d''évaluation clinique mMRC',
        jsonb_build_array(
            jsonb_build_object('id','mmrc_0','label','Niveau 0','description','Je suis essoufflé uniquement lors d''efforts importants (ex. courir).'),
            jsonb_build_object('id','mmrc_1','label','Niveau 1','description','Je suis essoufflé lorsque je marche rapidement à plat ou en montant une côte.'),
            jsonb_build_object('id','mmrc_2','label','Niveau 2','description','Je dois ralentir sur du plat ou m''arrêter pour respirer après 100 mètres.'),
            jsonb_build_object('id','mmrc_3','label','Niveau 3','description','Je dois m''arrêter pour reprendre mon souffle après quelques minutes de marche.'),
            jsonb_build_object('id','mmrc_4','label','Niveau 4','description','Je suis trop essoufflé pour quitter la maison ou lors de l''habillage.')
        ),
        true, 1, null, null, null
    ),
    (
        'cough',
        'single_choice',
        'Avez-vous davantage toussé aujourd''hui ?',
        'Comparaison par rapport à votre niveau habituel',
        jsonb_build_array(
            jsonb_build_object('id','cough_normal','label','Pas plus que d''habitude','description','La quinte de toux reste identique.'),
            jsonb_build_object('id','cough_mild','label','Un peu plus que d''habitude','description','Augmentation légère de la fréquence des toux.'),
            jsonb_build_object('id','cough_severe','label','Beaucoup plus que d''habitude','description','Toux persistante ou invalidante au cours de la journée.')
        ),
        true, 2, null, null, null
    ),
    (
        'sputum',
        'single_choice',
        'Avez-vous remarqué un changement dans vos expectorations ?',
        'Quantité et aspect des crachats',
        jsonb_build_array(
            jsonb_build_object('id','sputum_normal','label','Pas de changement','description','Aspect et volume habituels.'),
            jsonb_build_object('id','sputum_amount','label','Quantité augmentée','description','Volume des sécrétions plus important.'),
            jsonb_build_object('id','sputum_color','label','Aspect ou couleur modifiée','description','Secrétions devenues purulentes (jaunâtres / verdâtres).')
        ),
        true, 3, null, null, null
    ),
    (
        'spo2',
        'numeric_input',
        'Votre saturation en oxygène (SpO₂)',
        'Indiquez la valeur mesurée avec votre oxymètre de pouls.',
        null,
        true, 4, '%', 70, 100
    )
on conflict (question_key) do nothing;

-- Done.
