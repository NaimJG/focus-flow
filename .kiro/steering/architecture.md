# Focus Flow — Architecture

## Architectural Style

Focus Flow uses **Feature-First Clean Architecture**. The codebase is organized around product features rather than technical layers. Each feature owns its data, domain logic, and UI. Shared infrastructure lives in `core/` and reusable UI components live in `shared/`.

## Directory Structure

```
lib/
├── app/                    # Application bootstrap and configuration
│   ├── app.dart            # Root widget (MaterialApp setup)
│   ├── router.dart         # Centralized route definitions
│   └── theme/              # Material 3 theme tokens
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── core/                   # Shared infrastructure (not feature-specific)
│   ├── database/           # Isar initialization and global DB instance
│   ├── services/           # App-wide services (e.g., notification service)
│   └── utils/              # Pure utility functions and extensions
│
├── features/               # One sub-folder per product feature
│   ├── home/
│   ├── todo/
│   ├── pomodoro/
│   └── statistics/
│   └── settings/
│
├── shared/                 # Cross-feature UI primitives
│   ├── widgets/            # Reusable widgets (buttons, cards, dialogs)
│   ├── models/             # Value objects shared across features
│   └── enums/              # Shared enumerations
│
└── main.dart               # Entry point
```

## Feature Internal Structure

Every feature follows the same internal layout:

```
features/<feature_name>/
├── data/
│   ├── models/             # Isar schema objects (@collection annotated)
│   └── repositories/       # Concrete repository implementations
├── domain/
│   ├── entities/           # Pure domain objects (no Isar annotations)
│   ├── repositories/       # Abstract repository interfaces
│   └── use_cases/          # Single-responsibility business logic units
├── presentation/
│   ├── screens/            # Full-page widgets (one per route)
│   ├── widgets/            # Feature-scoped UI components
│   └── controllers/        # State management (e.g., ChangeNotifier, Riverpod)
└── <feature_name>_module.dart  # Optional: exports for cross-feature access
```

## Dependency Rules

- `presentation/` depends on `domain/` only — never on `data/` directly.
- `data/` implements interfaces defined in `domain/`.
- Features must not import from other features' `data/` or `domain/` layers.
- Features may use `shared/` widgets and `core/` services freely.
- `core/` and `shared/` must never import from `features/`.

## State Management

State management is not prescribed at the project level. Each feature chooses the simplest approach that fits its complexity. Acceptable options:

- `StatefulWidget` + `setState` for purely local UI state
- `ChangeNotifier` + `ListenableBuilder` / `Provider` for feature-scoped state
- `Riverpod` if a feature needs reactive dependency injection

Do not introduce a state management library unless the feature's complexity justifies it.

## Navigation

Navigation is centralized in `app/router.dart`. Features do not hold references to other features' routes directly. Named routes or a typed router (e.g., `go_router`) are acceptable; the choice is made once and applied consistently.

## Persistence

- **Database**: Isar (embedded, offline-only, no remote sync in v1.0).
- Isar collections are defined in `data/models/` inside each feature.
- A single Isar instance is initialized in `core/database/` and injected into repositories.
- No raw SQL or platform channels for persistence.

## Design System

- Material 3 is the design system.
- Color, typography, and spacing tokens are defined once in `app/theme/`.
- Widgets use `Theme.of(context)` to consume tokens — no hardcoded colors or font sizes in widget files.
