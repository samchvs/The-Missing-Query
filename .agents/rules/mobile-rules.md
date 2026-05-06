---
trigger: always_on
---

```md
# Agent Rules — Graphics Project

This file defines mandatory architectural rules for all AI-assisted code generation in this Flutter project.
All code written by the agent MUST comply with the Clean Architecture principles defined below.

---

## 🏛️ Architecture: Clean Architecture (Flutter)

### Layer Structure

```

lib/
├── core/           → constants, theme, utils, errors (no business logic)
├── domain/         → entities, use cases, repository interfaces (pure Dart)
├── data/           → models, data sources, repository implementations
└── presentation/   → screens, widgets, controllers (Flutter UI only)

````

### Strict Dependency Rule

- `presentation/` may depend on `domain/` and `core/`
- `data/` may depend on `domain/` and `core/`
- `domain/` may ONLY depend on `core/`
- `core/` has NO dependencies on other layers
- **Inner layers must NEVER import from outer layers**

---

## 📁 File Placement Rules

| What you're creating | Where it goes |
|---|---|
| Color palette, app strings, route names | `core/constants/` |
| App theme, fonts, text styles | `core/theme/` |
| Validators, extensions, helpers | `core/utils/` |
| Custom error/failure classes | `core/errors/` |
| Business entities (plain Dart objects) | `domain/entities/` |
| Abstract repository contracts | `domain/repositories/` |
| Business logic (one action per class) | `domain/usecases/` |
| JSON models with `fromJson/toJson` | `data/models/` |
| API calls, SharedPreferences access | `data/datasources/` |
| Concrete repository implementations | `data/repositories/` |
| Full-page route-level widgets | `presentation/screens/<feature>/` |
| Reusable UI components | `presentation/widgets/` |
| State holders (ChangeNotifier/Cubit) | `presentation/controllers/` |

---

## ✅ Mandatory Coding Rules

### General
- **Never** place business logic directly inside a `*_screen.dart` file
- **Never** call a data source directly from a screen; always go through a use case
- **Never** import `package:flutter` in `domain/` layer files
- **Always** create a new widget file if a widget exceeds ~80 lines or is used in more than one screen

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Screens: `<name>_screen.dart` (e.g. `login_screen.dart`)
- Use Cases: `<action>_usecase.dart` (e.g. `validate_query_usecase.dart`)
- Controllers: `<feature>_controller.dart`
- Repository interfaces: `<feature>_repository.dart` (in `domain/`)
- Repository implementations: `<feature>_repository_impl.dart` (in `data/`)

### Use Case Rules
- One class per use case
- Single public method: `call()` or `execute()`
- Must return a typed result (entity or failure)
- Example:
  ```dart
  class ValidateQueryUseCase {
    final TutorialRepository repository;
    ValidateQueryUseCase(this.repository);

    bool call(String query) => repository.validateQuery(query);
  }
````

### Widget Rules

* Prefer `StatelessWidget` — only use `StatefulWidget` for local animation state
* Extract any inline widget subtree longer than ~40 lines into its own file under `presentation/widgets/`
* Reusable widgets (used in 2+ screens) **must** go in `presentation/widgets/common/`

### Screen Rules

* Screens are thin — they only build UI and delegate all logic to a controller
* Screens must not contain raw business logic, SQL validation, or data fetching

### Constants Rules

* No hardcoded strings in screen files — use `AppStrings` from `core/constants/app_strings.dart`
* No hardcoded colors — use `AppColors` from `core/constants/app_colors.dart`
* No hardcoded route strings — use `AppRoutes` from `core/constants/app_routes.dart`

---

## 📱 Responsive UI Rules

### Layout Adaptation

* Avoid hardcoded widths and heights (e.g. `width: 300`, `height: 500`)
* Use responsive layout widgets such as:

  * `MediaQuery`
  * `LayoutBuilder`
  * `Expanded` and `Flexible`
  * `FractionallySizedBox`

### Screen Compatibility

* UI must adapt properly to:

  * small phones
  * large phones
  * tablets

### Text & Spacing

* Avoid fixed font sizes where possible; prefer scalable text
* Use spacing constants from `core/constants/` instead of hardcoded values

### Overflow Handling

* All screens must prevent overflow errors
* Use:

  * `SingleChildScrollView`
  * `ListView`
  * `Expanded`
    where appropriate

### Orientation Safety

* UI must remain functional in both portrait and landscape orientations

### Testing Requirement

* Each screen must be tested on at least:

  * one small screen device
  * one large screen or tablet layout

## 🛠️ Edit Rules

### Antigravity Precision
- **Strict Scope Adherence:** Only modify the specific lines, functions, or files explicitly requested. 
- **No Unsolicited Refactoring:** Do not perform global "cleanups," style adjustments, or "extra" optimizations unless explicitly directed.
- **Minimal Diffs:** Keep changes surgical. If the task is to fix a bug in a controller, do not touch the UI or the domain layer unless it is technically impossible to complete the task otherwise.

### Quality Control
- Ensure any edits maintain the **Clean Architecture** boundaries defined above.
- If an edit requires adding a new dependency, the agent must flag this for approval before proceeding.
- All code edits must pass existing static analysis and linting rules.
---

## 📦 Asset Usage Rules

* All assets must be declared in `pubspec.yaml` under `flutter: assets:`
* Asset paths should be referenced via a constants file (e.g. `AppAssets`) to avoid typos
* Example:

  ```dart
  // core/constants/app_assets.dart
  class AppAssets {
    static const String beanie = 'assets/Beanie.png';
    static const String beanieWalking1 = 'assets/BeanieWalking1.png';
  }
  ```
---

## Edit Rules

* **Unit tests** — cover all use cases and validators in `test/domain/`
* **Widget tests** — cover individual screens and reusable widgets in `test/presentation/`
* Tests must mirror the `lib/` folder structure inside `test/`
* No test should depend on a real data source — always mock

---
---

## 🧪 Testing Rules

* **Unit tests** — cover all use cases and validators in `test/domain/`
* **Widget tests** — cover individual screens and reusable widgets in `test/presentation/`
* Tests must mirror the `lib/` folder structure inside `test/`
* No test should depend on a real data source — always mock

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern                                         | Why It's Prohibited                           |
| ---------------------------------------------------- | --------------------------------------------- |
| 500+ line screen files                               | Violates single responsibility                |
| SQL logic inside a screen                            | Business logic belongs in `domain/usecases/`  |
| Hardcoded strings in widgets                         | Makes localization and maintenance impossible |
| Calling APIs from a widget                           | Violates layer separation                     |
| Mixing animation state with business state           | Keeps concerns tangled                        |
| Creating widgets inside `build()` as local functions | Makes reuse and testing impossible            |

```
```
