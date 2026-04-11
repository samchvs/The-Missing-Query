# 🎮 Graphics Project — Flutter App

> An interactive, gamified SQL learning application built with Flutter.

---

## 📐 System Architecture

This project follows **Clean Architecture** principles as defined by Robert C. Martin, adapted for Flutter. The architecture separates the codebase into distinct layers with a strict **dependency rule**: inner layers never depend on outer layers.

```
┌─────────────────────────────────────────────┐
│             Presentation Layer              │  ← UI, Screens, Widgets
├─────────────────────────────────────────────┤
│              Domain Layer                   │  ← Use Cases, Entities
├─────────────────────────────────────────────┤
│               Data Layer                    │  ← Repositories, Data Sources
├─────────────────────────────────────────────┤
│               Core / Shared                 │  ← Constants, Utils, Theme
└─────────────────────────────────────────────┘
```

### Dependency Rule

```
Presentation  →  Domain  ←  Data
                   ↑
                  Core
```

The **Domain layer** is the most independent — it has zero dependencies on Flutter or external libraries.

---

## 📁 Folder Structure

```
lib/
│
├── core/                          # Shared utilities across all layers
│   ├── constants/
│   │   ├── app_colors.dart        # Color palette
│   │   ├── app_strings.dart       # All hardcoded strings
│   │   └── app_routes.dart        # Named route constants
│   ├── errors/
│   │   └── failures.dart          # Custom failure/exception classes
│   ├── utils/
│   │   ├── validators.dart        # Input validation helpers (e.g. SQL check)
│   │   └── extensions.dart        # Dart extension methods
│   └── theme/
│       └── app_theme.dart         # Global ThemeData, fonts, styles
│
├── domain/                        # Business logic — pure Dart, no Flutter
│   ├── entities/
│   │   ├── user.dart              # User entity
│   │   └── tutorial_case.dart     # Tutorial case entity
│   ├── repositories/
│   │   ├── auth_repository.dart   # Abstract auth repo interface
│   │   └── progress_repository.dart # Abstract progress repo interface
│   └── usecases/
│       ├── login_usecase.dart      # Login logic
│       ├── signup_usecase.dart     # Signup logic
│       ├── validate_query_usecase.dart  # SQL query validation logic
│       └── get_user_progress_usecase.dart
│
├── data/                          # Concrete implementations
│   ├── models/
│   │   ├── user_model.dart        # JSON serializable User model
│   │   └── tutorial_case_model.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   └── shared_prefs_datasource.dart  # Local persistence
│   │   └── remote/
│   │       └── api_datasource.dart           # Remote API calls
│   └── repositories/
│       ├── auth_repository_impl.dart         # Implements domain/auth_repository
│       └── progress_repository_impl.dart
│
├── presentation/                  # Flutter UI layer
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   └── profile_tab.dart
│   │   └── tutorial/
│   │       ├── tutorial_screen.dart
│   │       ├── tutorial2_screen.dart
│   │       ├── tutorial3_screen.dart
│   │       ├── tutorial4_screen.dart
│   │       ├── tutorial_case_screen.dart
│   │       ├── tutorial_case2_screen.dart
│   │       ├── tutorial_case3_screen.dart
│   │       └── tutorial_case4_screen.dart
│   ├── widgets/                   # Reusable UI components
│   │   ├── common/
│   │   │   ├── keyboard_accessory_bar.dart
│   │   │   ├── animated_button.dart
│   │   │   └── custom_back_button.dart
│   │   ├── character/
│   │   │   ├── walking_character.dart     # Animated character widget
│   │   │   └── character_display.dart
│   │   └── tutorial/
│   │       ├── query_input_box.dart
│   │       ├── result_table_overlay.dart
│   │       └── mouse_pointer_hint.dart
│   └── controllers/               # State management (ChangeNotifier / Cubit)
│       ├── auth_controller.dart
│       ├── user_controller.dart
│       └── tutorial_controller.dart
│
├── assets/                        # (See Assets section below)
└── main.dart                      # App entry point + dependency injection
```

---

## 🔁 Data Flow

```
   [ Screen ]
       │
       ▼
[ Controller ]  ←──────────────────────────────────┐
       │                                            │
       ▼                                            │
  [ UseCase ]                                       │
       │                                            │
       ▼                                    (returns Result / Failure)
[ Repository Interface ]                            │
       │                                            │
       ▼                                            │
[ Repository Implementation ] ─────────────────────┘
       │
       ▼
[ DataSource (local / remote) ]
```

Each layer communicates using either **entities** (domain) or **models** (data), converting between them at the repository layer.

---

## 🧱 Layer Responsibilities

### `core/`
- App-wide constants, theme, colors, route names
- Shared utilities that don't belong to any single feature
- No business logic

### `domain/`
- **Entities**: Plain Dart objects representing core business data (e.g. `User`, `TutorialCase`)
- **Repository Interfaces**: Abstract contracts — never imports from `data/`
- **Use Cases**: One class per action (e.g. `ValidateQueryUseCase`), single `call()` method

### `data/`
- **Models**: Data Transfer Objects with `fromJson()` / `toJson()` methods
- **Data Sources**: Handles raw I/O (API calls, SharedPreferences, local DB)
- **Repository Implementations**: Converts models ↔ entities, calls data sources

### `presentation/`
- **Screens**: Route-level widgets, thin — delegate logic to controllers
- **Widgets**: All reusable, stateless where possible
- **Controllers**: Hold UI state, call use cases, expose data via `notifyListeners()` or streams

---

## 🎨 Assets

All image assets live in `assets/` and are registered in `pubspec.yaml`.

| Category | Files |
|---|---|
| **Characters** | `Beanie.png`, `BeanieWalking1/2.png`, `Tomathomas.png`, `Broccoliandro.png`, `Carrotino.png`, `sadBeanie.png`, `sadCarrotino.png` |
| **Backgrounds** | `home_screen.png`, `login_screen.png`, `signup_screen.png`, `splash_screen.png`, `tutorial*.png` |
| **UI Panels** | `caseDisplay-box.png`, `tutorialDisplay.png`, `userDisplay.png`, `tutorialTable.png`, etc. |
| **Buttons** | All `*-btn.png` files |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Core framework |
| `google_fonts` | ^6.2.1 | Custom typography (Londrina Solid, etc.) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test
```

---

## 🧪 Testing Strategy

Following clean architecture, tests are isolated per layer:

```
test/
├── domain/
│   └── usecases/
│       └── validate_query_usecase_test.dart   # Pure unit tests
├── data/
│   └── repositories/
│       └── auth_repository_impl_test.dart     # Mocked data sources
└── presentation/
    └── screens/
        └── login_screen_test.dart             # Widget tests
```

- **Unit tests** — domain use cases and data models (no Flutter dependency)
- **Widget tests** — individual screen and widget rendering
- **Integration tests** — full user flows (login → tutorial → completion)

---

## 📋 Coding Conventions

- **Naming**: `snake_case` for files, `PascalCase` for classes, `camelCase` for variables
- **Screens**: Suffix `_screen.dart`, one screen per file
- **Widgets**: Small, focused, and reusable — prefer stateless
- **Use Cases**: One public `call()` method, return `Either<Failure, T>` pattern
- **No raw strings in UI**: All user-facing text lives in `core/constants/app_strings.dart`

---

> **Version**: 1.0.0+1 · **Flutter SDK**: ^3.11.1 · **Dart SDK**: ^3.11.1
