# HMIS

Emergency-room **marksheet** and **case register** app for duty shifts. Runs **offline-first** on device (ObjectBox), with optional **PocketBase** sync when a server URL is configured.

**Stack:** Flutter · `flutter_bloc` · ObjectBox · PocketBase · custom **Liquid** UI (no blur).

---

## Features

| Area | What it does |
|------|----------------|
| **Home** | Today’s KPIs, case mix, quick actions, recent patients |
| **New chit** | Add/edit an ER mark (case type, demographics, notes) |
| **Marksheet** | Grid tally by shift × case type for a sheet day |
| **Case register** | Browse marks by day or all cases, filter, open/edit |
| **Settings** | Theme, PocketBase URL, sync status, collection provisioning |

---

## `lib/` layout

Only these top-level areas under `lib/`:

```
lib/
├── main.dart
├── objectbox.g.dart          # generated — do not edit
├── objectbox-model.json      # ObjectBox schema
├── business/                 # cubits / blocs only
├── ui/                       # feature screens + shared reusable UI
├── domain/
│   ├── models/
│   └── repositories/
├── services/
└── utils/                    # composition root (dependencies_scope.dart)
```

### Layer roles

| Layer | Responsibility | May depend on |
|-------|----------------|---------------|
| **`services/`** | Pure helpers: dates, IDs, PocketBase client wrapper | Dart / packages only — **not** `domain`, `business`, or `ui` |
| **`domain/models/`** | Domain types, presentation helpers, hospital-time rules, ObjectBox `@Entity` rows | `services/` where needed |
| **`domain/repositories/`** | Persistence, mapping entity ↔ domain, sync outbox, local store | `models/`, `services/`, `objectbox.g.dart` |
| **`business/`** | Cubits/blocs — application state & orchestration for UI | `domain/models`, **repositories** (not widgets) |
| **`ui/`** | Feature folders (`home/`, `marksheet/`, …) + **`ui/shared/`** (reusable Liquid, widgets, theme, dialogs, shell) | `business/` cubits, `domain/models` |
| **`utils/`** | App wiring (`dependencies_scope.dart`) | All layers for DI only |

**Data flow:** UI event → cubit → repository → ObjectBox / sync → cubit state → UI.

Composition root: `utils/dependencies_scope.dart` — `MultiRepositoryProvider` for data-layer types, then `MultiBlocProvider` for cubits. `context.read<T>()` works for both (from `flutter_bloc`).

---

## Conventions

### Naming

- **Domain files:** `*_model.dart` (e.g. `mark_model.dart`, `hospital_time_model.dart`).
- **Persistence entities:** live in `domain/models/local_entity_models.dart` (`MarkEntity`, `OutboxEntry`, `SyncMetaEntity`) — **not** used by widgets or cubits directly.
- **Repositories:** `*_repository.dart` in `domain/repositories/`.
- **State:** one cubit per file at `business/<name>_cubit.dart`.
- **Feature UI:** `ui/<feature>/…_screen.dart` and `ui/<feature>/components/` — only widgets used by that feature.
- **Reusable UI:** `ui/shared/` — Liquid (`shared/liquid/`), `shared/widgets/`, `shared/theme/`, `shared/shell/`, `shared/dialogs/`.

### Import rules

1. **UI and cubits** import `package:hmis/domain/models/models.dart` — use **`Mark`**, not `MarkEntity`.
2. **Only repositories** touch ObjectBox entities and mappers.
3. **Liquid (reusable):** `package:hmis/ui/shared/liquid/liquid.dart`.
4. Do **not** add stray top-level folders (`features/`, `cubits/`, `data/` at root).

### Services & repositories (async / streams)

**No `ChangeNotifier`** on `services/` or `domain/repository/` types.

| Type | Reactive API | One-off API |
|------|----------------|-------------|
| **`PocketBaseService`** | `session` → connection open/closed | `readSession()`, `open()` / `close()`, prefs futures |
| **`MarksRepository`** | `revisions` → local data changed | `readRevision()`, `fetch*` / `add` / `save` / `remove` futures |
| **`SyncRepository`** | `busy` → sync in flight | `readBusy()`, `syncIfPossible()`, `pendingCount()` |

**Cubits** subscribe to streams (e.g. `revisions.listen`) and **`await`** repository futures.

### Hospital time (sheet day)

- **Sheet day** rolls at **08:00** (`Mark.date`).
- **Shifts:** 08–14 / 14–20 / 20–08 from arrival wall clock.
- **`Mark.createdAt`** = arrival; may differ from sheet calendar day.

Logic: `domain/models/hospital_time_model.dart`.

### Sync

- Local ObjectBox is **source of truth** on device.
- `SyncRepository` + optional PocketBase.

---

## UI system

- **Theme:** `ui/shared/theme/hmis_theme.dart`.
- **Liquid:** `ui/shared/liquid/` — design-system primitives. Root wrap: `LiquidCanvas` in `main.dart`.
- **Cross-feature widgets:** e.g. `sheet_arrival_banner`, `hmis_empty_state`, delete/mark dialogues under `ui/shared/`.
- **Branding:** `assets/branding/`.

---

## Development

**Targets:** Android, Windows, Web only (`ios/`, `linux/`, `macos/` are not in this repo).

```bash
flutter pub get
flutter run -d windows   # or chrome, android
dart analyze lib
```

ObjectBox entities: `domain/models/local_entity_models.dart` — regenerate with `dart run build_runner build --delete-conflicting-outputs` when schema changes.

---

## Project map (quick)

| Path | Notes |
|------|--------|
| `business/*_cubit.dart` | Feature state |
| `ui/home/` | Dashboard |
| `ui/marksheet/` | Tally grid |
| `ui/new_chit/` | Create/edit mark |
| `ui/case_register/` | Lists & filters |
| `ui/settings/` | Sync & theme |
| `domain/repositories/marks_repository.dart` | CRUD, tallies |
| `services/pocketbase.dart` | Connection + prefs |

**Version:** 0.1.11 (`pubspec.yaml`).
