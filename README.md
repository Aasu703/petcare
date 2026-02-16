# PawCare Flutter App

Flutter client for PawCare with feature-first organization and Riverpod-based state management.

## Architecture

The app follows a feature-first Clean Architecture style:

- `lib/core`: Cross-cutting concerns (`api`, `providers`, `services`, `state`, `widgets`)
- `lib/app`: App shell, theme, routes, startup bootstrap
- `lib/shared`: Reusable UI/navigation building blocks shared across features
- `lib/features/<feature>`: Feature modules with `data`, `domain`, `presentation`, and optional `di`

Feature boundaries:

- `data`: Models, local/remote data sources, repository implementations
- `domain`: Entities, repository contracts, use cases
- `presentation`: UI, state objects, view models/notifiers
- `di`: Feature-level provider wiring

## Startup Flow

App startup is centralized in `lib/app/bootstrap/app_bootstrap.dart`:

1. Initialize Hive and open boxes.
2. Initialize local notifications.
3. Resolve `SharedPreferences`.
4. Pass dependencies into `ProviderScope` overrides in `lib/main.dart`.

This keeps side effects out of widgets and makes startup behavior easier to test.

## Routing

The app uses `go_router` with a single route tree in `lib/app/routes/app_router.dart`:

- Public routes: splash, onboarding, auth
- Protected user routes: home, explore, shop, profile, bookings, pets
- Protected provider route: provider dashboard
- User shell navigation: `lib/shared/navigation/user_shell.dart`

This removes scattered manual route setup and keeps navigation structure predictable.

## Dependency Injection Rules

- Shared/core providers live in `lib/core/providers`.
- Feature providers can depend on core providers, but not the opposite.
- Avoid constructing global dependencies directly in repositories/data sources.
- Prefer injected services (for example, `TokenService` in `ApiClient`) over static/global lookups.

## Developer Workflow

Install and run:

```bash
flutter pub get
flutter run
```

Quality checks:

```bash
flutter analyze
flutter test
```

Generate code when models/adapters change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Pull Request Checklist

- `flutter analyze` passes for changed files.
- `flutter test` passes for affected features.
- New feature follows `data` / `domain` / `presentation` separation.
- DI changes are added in feature `di` and reuse core providers where applicable.
- Any startup dependency is wired through `app_bootstrap.dart` and provider overrides.
