import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';
import 'package:petcare/features/services/domain/usecases/get_services_usecase.dart';
import 'package:petcare/features/services/presentation/view_model/service_view_model.dart';
import 'package:petcare/features/services/service_providers.dart';

class _ConfigurableServiceRepository implements IServiceRepository {
  _ConfigurableServiceRepository({
    this.pageResults = const {},
    this.pageFailures = const {},
    this.delay = Duration.zero,
    this.onGetServices,
  });

  final Map<int, List<ServiceEntity>> pageResults;
  final Map<int, Failure> pageFailures;
  final Duration delay;
  final Future<Either<Failure, List<ServiceEntity>>> Function(
    int page,
    int limit,
  )?
  onGetServices;

  int callCount = 0;
  final List<int> requestedPages = [];

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    callCount++;
    requestedPages.add(page);
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (onGetServices != null) {
      return onGetServices!(page, limit);
    }
    final failure = pageFailures[page];
    if (failure != null) {
      return Left(failure);
    }
    return Right(pageResults[page] ?? const []);
  }

  @override
  Future<Either<Failure, ServiceEntity>> getServiceById(
    String serviceId,
  ) async {
    return Left(ServerFailure(message: 'not used'));
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProvider(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    return Left(ServerFailure(message: 'not used'));
  }
}

List<ServiceEntity> _services(int count, String prefix) {
  return List.generate(
    count,
    (index) => ServiceEntity(
      serviceId: '$prefix-$index',
      title: 'Service $prefix-$index',
      price: 10,
      durationMinutes: 30,
    ),
  );
}

ProviderContainer _createContainer(_ConfigurableServiceRepository repository) {
  final usecase = GetServicesUsecase(repository: repository);
  return ProviderContainer(
    overrides: [getServicesUsecaseProvider.overrideWithValue(usecase)],
  );
}

void main() {
  group('ServiceNotifier ViewModel Tests', () {
    test('1. starts with expected initial state', () {
      final repository = _ConfigurableServiceRepository();
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      final state = container.read(serviceProvider);

      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
      expect(state.services, isEmpty);
      expect(state.error, isNull);
    });

    test('2. loadServices stores first page services on success', () async {
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: _services(3, 'p1')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();
      final state = container.read(serviceProvider);

      expect(state.services.length, 3);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('3. loadServices always resets page to 1 on success', () async {
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: _services(2, 'p1')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();

      expect(container.read(serviceProvider).page, 1);
    });

    test('4. loadServices sets hasMore true when page size is 20', () async {
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: _services(20, 'p1')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();

      expect(container.read(serviceProvider).hasMore, isTrue);
    });

    test(
      '5. loadServices sets hasMore false when fewer than 20 items',
      () async {
        final repository = _ConfigurableServiceRepository(
          pageResults: {1: _services(5, 'p1')},
        );
        final container = _createContainer(repository);
        addTearDown(container.dispose);

        await container.read(serviceProvider.notifier).loadServices();

        expect(container.read(serviceProvider).hasMore, isFalse);
      },
    );

    test('6. loadServices stores error message on failure', () async {
      final repository = _ConfigurableServiceRepository(
        pageFailures: {1: ServerFailure(message: 'first page failed')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();
      final state = container.read(serviceProvider);

      expect(state.error, 'first page failed');
      expect(state.isLoading, isFalse);
      expect(state.services, isEmpty);
    });

    test('7. loadMore appends services and increments page', () async {
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: _services(20, 'p1'), 2: _services(3, 'p2')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();
      await container.read(serviceProvider.notifier).loadMore();
      final state = container.read(serviceProvider);

      expect(state.services.length, 23);
      expect(state.page, 2);
      expect(state.isLoadingMore, isFalse);
    });

    test('8. loadMore does nothing when hasMore is false', () async {
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: _services(5, 'p1')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();
      final beforeCalls = repository.callCount;

      await container.read(serviceProvider.notifier).loadMore();

      expect(repository.callCount, beforeCalls);
      expect(container.read(serviceProvider).page, 1);
    });

    test('9. concurrent loadMore calls only trigger one fetch', () async {
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: _services(20, 'p1'), 2: _services(20, 'p2')},
        delay: const Duration(milliseconds: 80),
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();
      final notifier = container.read(serviceProvider.notifier);

      await Future.wait([notifier.loadMore(), notifier.loadMore()]);

      final page2Calls = repository.requestedPages.where((p) => p == 2).length;
      expect(page2Calls, 1);
    });

    test('10. loadMore failure keeps data and sets error', () async {
      final initialServices = _services(20, 'p1');
      final repository = _ConfigurableServiceRepository(
        pageResults: {1: initialServices},
        pageFailures: {2: ServerFailure(message: 'load more failed')},
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(serviceProvider.notifier).loadServices();
      await container.read(serviceProvider.notifier).loadMore();
      final state = container.read(serviceProvider);

      expect(state.services.length, 20);
      expect(state.page, 1);
      expect(state.error, 'load more failed');
      expect(state.isLoadingMore, isFalse);
    });
  });
}
