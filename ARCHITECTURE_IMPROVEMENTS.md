# Architecture Improvements - Clean Architecture Alignment

## Overview
This document outlines the architectural improvements needed to align the PetCare app with the Lost & Found reference architecture from https://github.com/kiranrana8973/lost_n_found_mobile/blob/complete_code

**Reference Architecture Pattern:**
```
UI → ViewModel (Riverpod Notifier) → UseCase → Repository Interface → Repository Impl → DataSource (Local/Remote)
```

---

## Current State vs Target State

### ✅ What's Already Correct
- Clean architecture with `data/domain/presentation` separation per feature
- Riverpod state management with feature-level DI
- Error handling with `dartz` Either pattern
- Hive local storage integration
- Dio networking client
- GoRouter navigation
- Proper service injection (SessionService, NetworkInfo, etc.)

### ❌ Issues to Fix

#### 1. **Inconsistent Folder Naming**
**Current:**
- `pet/data/datasource/` (singular)
- `shop/data/datasource/` (singular)
- `auth/data/datasources/` (plural)

**Target:** Standardize to `datasources/` (plural) across all features

```
features/{feature}/data/
├── datasources/          # ← Always plural
│   ├── local/
│   │   └── {feature}_local_datasource.dart
│   ├── remote/
│   │   └── {feature}_remote_datasource.dart
│   └── {feature}_datasource.dart    # Abstract interfaces
├── models/
├── repositories/
```

---

#### 2. **Empty/Unused Folders**
**Current:** 
- `lib/Screens/` - empty folder (left from old structure)
- `lib/common/` - only contains `mysnackbar.dart`

**Action:**
- ❌ Remove `lib/Screens/` entirely
- ✅ Move `lib/common/mysnackbar.dart` → `lib/shared/utils/snackbar_service.dart`
- Update all imports

---

#### 3. **Datasource Organization Pattern**
**Current Mixed Pattern:**
```dart
// Some features mix interface and implementation in same file
abstract interface class IAuthDataSource { ... }
class AuthLocalDatasource implements IAuthDataSource { ... }
```

**Target Pattern (Cleaner):**
```
datasources/
├── {feature}_datasource.dart        # Only interfaces
├── local/
│   └── {feature}_local_datasource.dart    # Implementation
└── remote/
    └── {feature}_remote_datasource.dart   # Implementation
```

---

## Detailed Improvements Roadmap

### Phase 1: Structural Cleanup (High Priority)
1. **Remove empty `Screens/` folder**
   - Verify no imports reference it
   - Delete the folder

2. **Migrate `common/mysnackbar.dart`**
   - Create `shared/utils/` if missing
   - Move and rename to `snackbar_service.dart`
   - Update all imports across the project

3. **Standardize datasources folder naming**
   - Rename all `datasource/` → `datasources/`
   - Verify imports don't break

### Phase 2: Datasource Pattern Alignment (Medium Priority)
Apply to features in this order:
1. **Auth** (Foundation)
2. **Bookings** (High usage)
3. **Shop** (High usage)
4. **Pet** (High usage)
5. **Provider** (Complex)
6. **Others** (remaining features)

**For each feature:**
```dart
// OLD PATTERN (Mixed):
// auth/data/datasources/auth_datasource.dart
abstract interface class IAuthDataSource { ... }
abstract interface class IAuthRemoteDataSource { ... }
class AuthLocalDatasource implements IAuthDataSource { ... }

// NEW PATTERN (Separated):
// auth/data/datasources/auth_datasource.dart
abstract interface class IAuthDataSource { ... }
abstract interface class IAuthRemoteDataSource { ... }

// auth/data/datasources/local/auth_local_datasource.dart  
class AuthLocalDatasource implements IAuthDataSource { ... }

// auth/data/datasources/remote/auth_remote_datasource.dart
class AuthRemoteDataSource implements IAuthRemoteDataSource { ... }
```

---

### Phase 3: Core Layer Enhancements (Medium Priority)

#### Extension Methods
Ensure `lib/core/extensions/` includes:
- `build_context_extensions.dart` - snackbar, theme shortcuts
- `string_extensions.dart` - validation, formatting
- `date_extensions.dart` - formatting utilities
- `future_extensions.dart` - error handling helpers

#### Error Handling
Enhance `lib/core/error/failures.dart`:
```dart
class Failure extends Equatable {
  final String message;
  final int? statusCode;      // HTTP status if applicable
  final dynamic originalError; // Original exception for debugging
}

// Domain-specific failures
class AuthenticationFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
class NotFoundFailure extends Failure { ... }
```

#### Base UseCase
Create `lib/core/usecases/usecase.dart`:
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  
  @override
  List<Object> get props => [];
}
```

---

### Phase 4: ViewModel/Notifier Standardization (Low Priority)
Ensure all feature view models follow:
```dart
// PATTERN: Use final states with freezed for consistency
@freezed
class {Feature}State with _${Feature}State {
  const factory {Feature}State.initial() = _Initial;
  const factory {Feature}State.loading() = _Loading;
  const factory {Feature}State.success(Data data) = _Success;
  const factory {Feature}State.error(String message) = _Error;
}

class {Feature}Notifier extends StateNotifier<{Feature}State> {
  {Feature}Notifier(this._usecase) : super(const {Feature}State.initial());
  
  final {Feature}UseCase _usecase;
  
  Future<void> fetch() async {
    state = const {Feature}State.loading();
    final result = await _usecase.call(params);
    state = result.fold(
      (failure) => {Feature}State.error(failure.message),
      (data) => {Feature}State.success(data),
    );
  }
}
```

---

### Phase 5: Documentation & Standards (Continuous)
- [ ] Update feature creation template
- [ ] Add architecture decision records (ADRs)
- [ ] Create code review checklist
- [ ] Document DI patterns

---

## Implementation Order

1. **Immediate (Today):**
   - Remove `Screens/` folder
   - Move snackbar utility
   - Update imports

2. **This Week:**
   - Standardize datasources naming
   - Reorganize data layer for main features (Auth, Bookings, Shop)
   - Fix imports

3. **Next Week:**
   - Enhance core layer (extensions, error handling, base usecase)
   - Standardize ViewModels
   - Comprehensive testing

---

## Benefits

✅ **Consistency** - All features follow identical pattern
✅ **Maintainability** - Data sources clearly separated
✅ **Testability** - Easier to mock and test layers
✅ **Scalability** - New features follow proven template
✅ **Onboarding** - New developers understand structure immediately
✅ **Refactoring** - Changes propagate consistently

---

## Files to Update by Phase

### Phase 1: Cleanup
- Delete: `lib/Screens/`
- Move: `lib/common/mysnackbar.dart` → `lib/shared/utils/snackbar_service.dart`
- Grep search for imports and update

### Phase 2: Datasources (Priority Order)
- `features/auth/data/datasources/` - reorganize
- `features/bookings/data/datasources/` - reorganize  
- `features/shop/data/datasource/` - rename & reorganize
- `features/pet/data/datasource/` - rename & reorganize
- `features/provider/data/datasource/` - verify/reorganize
- Others...

### Phase 3: Core Enhancements
- Enhance: `lib/core/error/failures.dart`
- Create: `lib/core/usecases/usecase.dart`
- Create/Update: `lib/core/extensions/` files

---

## Notes

- All changes maintain backward compatibility with existing code
- Migration is incremental - no breaking changes required
- Tests should cover new patterns
- Documentation should be updated for each change
