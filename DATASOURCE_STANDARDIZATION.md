# Datasource Standardization Migration Guide

## Summary
Standardize all `datasource/` folders to `datasources/` (plural) across all features for consistency with Clean Architecture patterns.

## Status by Feature

### ✅ Already Correct (No Action Needed)
- `lib/features/auth/data/datasources/` ✓
- `lib/features/messages/data/datasources/` ✓

### 🔄 Need Folder Rename: datasource → datasources

#### HIGH PRIORITY (Have local + remote structure)
1. **bookings** - `datasource/` → `datasources/`
   - Current: `local/`, `remote/`, `booking_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

2. **health_records** - `datasource/` → `datasources/`
   - Current: `local/`, `remote/`, `health_record.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

3. **provider** - `datasource/` → `datasources/`
   - Current: `local/`, `remote/`, `provider_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

4. **services** - `datasource/` → `datasources/`
   - Current: `local/`, `remote/`, `services_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

#### MEDIUM PRIORITY (Only remote structure)
5. **shop** - `datasource/` → `datasources/`
   - Current: `remote/`, `shop_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

6. **pet** - `datasource/` → `datasources/`
   - Current: `remote/`, `pet_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

7. **posts** - `datasource/` → `datasources/`
   - Current: `remote/`, `post_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

8. **provider_service** - `datasource/` → `datasources/`
   - Current: `remote/`, `provider_service_datasource.dart`
   - No file content changes needed
   - Update imports in: `repositories/`, tests, DI

## Import Update Patterns

### Pattern 1: Repository imports
**Before:**
```dart
import 'package:petcare/features/{feature}/data/datasource/{feature}_datasource.dart';
import 'package:petcare/features/{feature}/data/datasource/remote/{feature}_remote_datasource.dart';
import 'package:petcare/features/{feature}/data/datasource/local/{feature}_local_datasource.dart';
```

**After:**
```dart
import 'package:petcare/features/{feature}/data/datasources/{feature}_datasource.dart';
import 'package:petcare/features/{feature}/data/datasources/remote/{feature}_remote_datasource.dart';
import 'package:petcare/features/{feature}/data/datasources/local/{feature}_local_datasource.dart';
```

### Pattern 2: DI Provider imports
Same import path updates as above

### Pattern 3: Test imports
Same import path updates as above

## Affected Files to Update

### For Each Feature:

#### Bookings
```
lib/features/bookings/
├── data/
│   ├── repositories/booking_repository_impl.dart  (update imports)
│   └── datasources/                               (folder rename)
├── di/booking_providers.dart                      (update imports)
└── [test files if any]
```

#### Health Records
```
lib/features/health_records/
├── data/
│   ├── repositories/health_record_repository_impl.dart  (update imports)
│   └── datasources/                                     (folder rename)
├── di/[check if exists]                                (update imports)
└── [test files if any]
```

#### Provider
```
lib/features/provider/
├── data/
│   ├── repository/provider_repository.dart  (update imports)
│   └── datasource/                         (folder rename)
├── di/provider_providers.dart              (update imports)
└── [test files if any]
```

#### Services
```
lib/features/services/
├── data/
│   ├── repositories/service_repository_impl.dart  (update imports)
│   └── datasource/                               (folder rename)
├── di/service_providers.dart                     (update imports)
└── [test files if any]
```

#### Shop
```
lib/features/shop/
├── data/
│   ├── repositories/shop_repository_impl.dart  (update imports)
│   └── datasource/                            (folder rename)
├── di/shop_providers.dart                     (update imports)
└── [test files if any]
```

#### Pet
```
lib/features/pet/
├── data/
│   ├── repositories/pet_repository_impl.dart  (update imports)
│   └── datasource/                           (folder rename)
├── di/pet_providers.dart                     (update imports)
└── [test files if any]
```

#### Posts
```
lib/features/posts/
├── data/
│   ├── repositories/post_repository_impl.dart  (update imports)
│   └── datasources/                           (folder rename - NOTE: already plural!)
├── di/post_providers.dart                     (update imports)
└── [test files if any]
```

#### Provider Service
```
lib/features/provider_service/
├── data/
│   ├── repositories/provider_service_repository_impl.dart  (update imports)
│   └── datasource/                                        (folder rename)
├── di/provider_service_providers.dart                     (update imports)
└── [test files if any]
```

## Manual Steps Required

Since folder renaming requires OS-level operations:

1. For each feature listed above:
   - Right-click `databundle/datasource/` folder
   - Rename to `datasource`(singular) → `datasources` (plural)
   - OR use terminal: `mv lib/features/{feature}/data/datasource lib/features/{feature}/data/datasources`

2. Then run this command to update all imports:
   ```bash
   dart fix --apply
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   ```

## Quick Reference: Features Status

| Feature | Current | Target | Local | Remote | Status |
|---------|---------|--------|-------|--------|--------|
| auth | datasources/ | datasources/ | ✓ | ✓ | ✓ DONE |
| messages | datasources/ | datasources/ | ✓ | ✓ | ✓ DONE |
| bookings | datasource/ | datasources/ | ✓ | ✓ | ⏳ PENDING |
| health_records | datasource/ | datasources/ | ✓ | ✓ | ⏳ PENDING |
| provider | datasource/ | datasources/ | ✓ | ✓ | ⏳ PENDING |
| services | datasource/ | datasources/ | ✓ | ✓ | ⏳ PENDING |
| shop | datasource/ | datasources/ | ✗ | ✓ | ⏳ PENDING |
| pet | datasource/ | datasources/ | ✗ | ✓ | ⏳ PENDING |
| posts | datasources/ | datasources/ | ✗ | ✓ | ✓ DONE (already plural) |
| provider_service | datasource/ | datasources/ | ✗ | ✓ | ⏳ PENDING |

## Next Steps

1. **Use terminal or IDE** to rename folders in this order:
   - bookings
   - health_records
   - provider
   - services
   - shop
   - pet
   - provider_service

2. **Update imports** using find-and-replace in IDE for each feature

3. **Run code generation and analysis:**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   flutter test
   ```

4. **Verify no breaking changes** by running the app
