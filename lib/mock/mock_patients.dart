/// Centralized mock patient identities for the RespiraCare prototype.
///
/// Per Step 4.11AA / 4.11Z, the same patient must appear identically across
/// every screen (auth, dashboard, alerts, messages, profile, ...). This file is
/// the single source of truth for patient identities so individual mock
/// repositories never hardcode divergent names for the same `id`.
///
/// Values are exposed as top-level `const String`s (not fields on a const
/// object) so they can be used directly inside `const` model constructors.
///
/// When the real backend lands, these references are replaced by the
/// authenticated user's record — nothing else in the UI should change.
library;

// Primary demo patient — used by the patient app, nurse roster, alerts and
// conversation threads. Keep this single identity everywhere.
const String kPatientP1Id = 'p1';
const String kPatientP1FullName = 'Ahmed Ben Ali';
const String kPatientP1ShortName = 'Ahmed B.';

const String kPatientP2Id = 'p2';
const String kPatientP2FullName = 'Mariem Kamel';
const String kPatientP2ShortName = 'Mariem K.';

const String kPatientP3Id = 'p3';
const String kPatientP3FullName = 'Sami Rhimi';
const String kPatientP3ShortName = 'Sami R.';

/// Demo nurse account (used by nurse-facing mocks).
const String kNurseN1Id = 'nurse-001';
const String kNurseN1FullName = 'Sarah Bennani';
const String kNurseN1ShortName = 'Sarah B.';
