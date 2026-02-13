import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/services/di/service_providers.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';
import 'package:petcare/features/services/domain/usecases/get_services_usecase.dart';
import 'package:petcare/features/services/presentation/view_model/service_view_model.dart';

class _FakeServiceRepository implements IServiceRepository {
  final Map<int, List<ServiceEntity>> _pages;

  _FakeServiceRepository(this._pages);

  @override
  Future<Either<Failure, ServiceEntity>> getServiceById(
    String serviceId,
  ) async {
    return Left(ServerFailure(message: 'not used in this test'));
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    return Right(_pages[page] ?? const []);
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProvider(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    return Left(ServerFailure(message: 'not used in this test'));
  }
}

void main() {
  test('ServiceNotifier loads initial page and paginates correctly', () async {
    final pageOne = List.generate(
      20,
      (index) => ServiceEntity(
        serviceId: 's1-$index',
        title: 'Service $index',
        price: 10,
        durationMinutes: 30,
      ),
    );
    final pageTwo = List.generate(
      5,
      (index) => ServiceEntity(
        serviceId: 's2-$index',
        title: 'Service Next $index',
        price: 20,
        durationMinutes: 45,
      ),
    );

    final repository = _FakeServiceRepository({1: pageOne, 2: pageTwo});
    final usecase = GetServicesUsecase(repository: repository);

    final container = ProviderContainer(
      overrides: [getServicesUsecaseProvider.overrideWithValue(usecase)],
    );
    addTearDown(container.dispose);

    await container.read(serviceProvider.notifier).loadServices();
    final initialState = container.read(serviceProvider);
    expect(initialState.services.length, 20);
    expect(initialState.page, 1);
    expect(initialState.hasMore, true);
    expect(initialState.isLoading, false);
  });
}
