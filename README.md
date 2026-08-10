# RespiraCare — Mobile Telemonitoring Platform for COPD

**RespiraCare** is a digital health telemonitoring mobile platform designed for patients living with Chronic Obstructive Pulmonary Disease (COPD / BPCO) and chronic respiratory failure. It facilitates structured home nursing follow-up, therapeutic education, inhaler technique verification, and clinical triage.

> **Important Clinical Scope:**  
> RespiraCare is a healthcare-support application. It is **NOT** an autonomous diagnostic system. All medical decisions remain the responsibility of qualified healthcare professionals.

---

## 🛠️ Technology Stack

- **Framework:** Flutter (Dart 3.x)
- **UI Architecture:** Material 3 Design System + Custom Tokens
- **State Management:** Flutter Riverpod (`flutter_riverpod`)
- **Navigation:** Declarative Guarded Routing (`go_router`)
- **Environment Management:** `flutter_dotenv`
- **Backend Services:** Supabase (PostgreSQL, Supabase Auth, Storage, Realtime)

---

## 📁 Feature-Based Folder Architecture

```
respiracare/
├── android/                        # Android Native Configuration
├── ios/                            # iOS Native Configuration
├── assets/                         # Static Assets (Images, Icons, Animations, Videos)
├── lib/
│   ├── main.dart                   # Entry point with Riverpod ProviderScope
│   ├── app/                        # App Configuration
│   │   ├── app.dart                # MaterialApp.router root widget
│   │   ├── router/                 # GoRouter guarded routing
│   │   ├── theme/                  # Design Tokens & Material 3 Theme
│   │   └── constants/              # Global constants & non-diagnostic disclaimers
│   ├── core/                       # Shared Cross-Cutting Utilities
│   │   ├── widgets/                # Reusable UI Primitives (AppCard, AppButton)
│   │   ├── services/               # Infrastructure Services (Supabase, FCM)
│   │   ├── errors/                 # Exception & Failure handlers
│   │   └── utils/                  # Formatters & Validators
│   ├── features/                   # Business Domain Features
│   │   ├── authentication/         # Login, PIN, & Biometrics
│   │   ├── patient/                # Patient Dashboard, Monitoring, Treatments, Videos
│   │   └── nurse/                  # Nurse Triage Queue, Roster, Alert Review
│   └── data/                       # Data Access Layer
│       ├── models/                 # Data Transfer Objects (DTOs)
│       ├── repositories/           # Repository Interfaces & Impls
│       └── sources/                # Supabase Remote APIs & Hive Cache
├── test/                           # Unit & Widget Test Suites
└── pubspec.yaml                    # Dependency Configuration
```

---

## 📜 Development & Coding Guidelines

1. **Single Responsibility Files:** Keep files small and focused; avoid monolithic files.
2. **Reusable Primitive Components:** Build reusable Design System components (`AppCard`, `AppButton`, `AppInput`) rather than ad-hoc widgets.
3. **Clean Layer Separation:** Keep business logic outside UI widgets. UI delegates to Riverpod Controllers, which delegate to Repositories.
4. **Configurable Clinical Rules:** Never hardcode medical thresholds directly in UI conditional checks. All clinical rules pass through a configurable monitoring engine (*TO BE VALIDATED WITH CLINICAL SUPERVISOR*).

---

## 🚀 Current Status

- **Phase:** Phase 4 — Frontend Implementation
- **Completed Step:** Step 4.1 — Project Foundation Initialization
- **Next Step:** Step 4.2 — Design System Component Building (AppCard, AppButton, AppInput)
