# DI Folder Removal & Provider Consolidation Plan

## Overview
Remove the `di/` folder across all features and consolidate providers into `{feature}_providers.dart` at the feature root level. This aligns with modern Riverpod best practices and cleaner architecture.

## Architecture Pattern (Modern)
```
features/{feature}/
├── {feature}_providers.dart        ← ALL providers consolidated here
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── view_model/        ← Uses providers from {feature}_providers.dart
```

## Why This Is Better

✅ **Flatter Structure** - Less directory nesting
✅ **Easier Navigation** - Find all providers in one place
✅ **Riverpod Best Practice** - Modern pattern recommended in official docs
✅ **Less Boilerplate** - No separate DI folder to maintain
✅ **Better IDE Support** - Single file import for all providers

## Features to Migrate (Priority Order)

### Phase 1: Immediate (Foundation)
1. **auth** - Base authentication, multiple screens depend on this
2. **bookings** - High usage, multiple view models

### Phase 2: Medium Priority
3. **provider** - Complex feature, multiple providers
4. **services** - Used by many features
5. **shop** - Standalone feature

### Phase 3: Remaining
6. **health_records** - Lower usage
7. **provider_service** - Smaller feature

## Migration Steps for Each Feature

### Step 1: Copy Provider Definitions
```dart
// From: lib/features/{feature}/di/{feature}_providers.dart
// To:   lib/features/{feature}/{feature}_providers.dart
// (Copy entire file content)
```

### Step 2: Update Imports in All Files
**Pattern:**
- OLD: `import 'package:petcare/features/{feature}/di/{feature}_providers.dart';`
- NEW: `import 'package:petcare/features/{feature}/{feature}_providers.dart';`

Affected files per feature:
- `presentation/pages/*.dart`
- `presentation/view_model/*.dart`
- `domain/usecases/*.dart` (if importing)
- `data/repositories/*.dart` (if importing)

### Step 3: Delete di/ Folder
- Remove `lib/features/{feature}/di/` directory entirely

### Step 4: Verify
- Run `flutter analyze`
- Run `flutter pub get`
- Run `flutter test`

## File Movement Summary

| Feature | Old Path | New Path | Status |
|---------|----------|----------|--------|
| auth | `lib/features/auth/di/auth_providers.dart` | `lib/features/auth/auth_providers.dart` | ⏳ PENDING |
| bookings | `lib/features/bookings/di/booking_providers.dart` | `lib/features/bookings/booking_providers.dart` | ⏳ PENDING |
| health_records | `lib/features/health_records/di/health_record_providers.dart` | `lib/features/health_records/health_record_providers.dart` | ⏳ PENDING |
| provider | `lib/features/provider/di/provider_providers.dart` | `lib/features/provider/provider_providers.dart` | ⏳ PENDING |
| provider_service | `lib/features/provider_service/di/provider_service_providers.dart` | `lib/features/provider_service/provider_service_providers.dart` | ⏳ PENDING |
| services | `lib/features/services/di/service_providers.dart` | `lib/features/services/service_providers.dart` | ⏳ PENDING |
| shop | `lib/features/shop/di/shop_providers.dart` | `lib/features/shop/shop_providers.dart` | ⏳ PENDING |

## Import Updates Required

### By Feature Breakdown

#### Auth Feature
Files to update:
- `lib/features/auth/presentation/view_model/login_view_model.dart`
- `lib/features/auth/presentation/view_model/profile_view_model.dart`
- `lib/features/auth/presentation/pages/signup.dart`
- `lib/features/auth/domain/usecases/upload_photo_usecase.dart`

#### Other Features
(Run grep search after first phase to identify all)

## Quick Execution Checklist

```bash
# 1. Copy provider files to feature roots
cp lib/features/auth/di/auth_providers.dart lib/features/auth/auth_providers.dart
cp lib/features/bookings/di/booking_providers.dart lib/features/bookings/booking_providers.dart
# ... (repeat for all features)

# 2. Update all imports (see next section)

# 3. Delete di folders
rm -rf lib/features/*/di/

# 4. Verify
flutter analyze
flutter pub get
flutter test
```

## Notes

- No provider definition changes needed - same code can be moved as-is
- All functionality remains identical
- Pure structural refactoring
- Zero behavioral changes
