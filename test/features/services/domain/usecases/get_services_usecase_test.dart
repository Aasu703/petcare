import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';
import 'package:petcare/features/services/domain/usecases/get_services_usecase.dart';

class _RecordingServiceRepository implements IServiceRepository {
  _RecordingServiceRepository({required this.result});

  final Either<Failure, List<ServiceEntity>> result;
  int callCount = 0;
  int? lastPage;
  int? lastLimit;

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    callCount++;
    lastPage = page;
    lastLimit = limit;
    return result;
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

void main() {
  group('GetServicesUsecase Tests', () {
    final sampleServices = [
      const ServiceEntity(
        serviceId: 's1',
        title: 'Vet Check',
        price: 10,
        durationMinutes: 30,
      ),
    ];

    test('1. uses default params when none are provided', () async {
      final repo = _RecordingServiceRepository(result: Right(sampleServices));
      final usecase = GetServicesUsecase(repository: repo);

      await usecase(const GetServicesParams());

      expect(repo.lastPage, 1);
      expect(repo.lastLimit, 20);
    });

    test('2. forwards custom page and limit to repository', () async {
      final repo = _RecordingServiceRepository(result: Right(sampleServices));
      final usecase = GetServicesUsecase(repository: repo);

      await usecase(const GetServicesParams(page: 3, limit: 7));

      expect(repo.lastPage, 3);
      expect(repo.lastLimit, 7);
    });

    test('3. returns Right with services from repository', () async {
      final repo = _RecordingServiceRepository(result: Right(sampleServices));
      final usecase = GetServicesUsecase(repository: repo);

      final result = await usecase(const GetServicesParams(page: 1, limit: 5));

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right result'),
        (services) => expect(services.length, 1),
      );
    });

    test('4. returns Left failure from repository', () async {
      final repo = _RecordingServiceRepository(
        result: Left(ServerFailure(message: 'network error')),
      );
      final usecase = GetServicesUsecase(repository: repo);

      final result = await usecase(const GetServicesParams(page: 2, limit: 2));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'network error'),
        (_) => fail('Expected Left result'),
      );
    });

    test('5. calls repository exactly once per invocation', () async {
      final repo = _RecordingServiceRepository(result: Right(sampleServices));
      final usecase = GetServicesUsecase(repository: repo);

      await usecase(const GetServicesParams());

      expect(repo.callCount, 1);
    });

    test('6. increments call count across multiple invocations', () async {
      final repo = _RecordingServiceRepository(result: Right(sampleServices));
      final usecase = GetServicesUsecase(repository: repo);

      await usecase(const GetServicesParams(page: 1, limit: 20));
      await usecase(const GetServicesParams(page: 2, limit: 20));

      expect(repo.callCount, 2);
    });

    test('7. GetServicesParams supports value equality for same values', () {
      const a = GetServicesParams(page: 4, limit: 15);
      const b = GetServicesParams(page: 4, limit: 15);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('8. GetServicesParams are not equal when page differs', () {
      const a = GetServicesParams(page: 1, limit: 20);
      const b = GetServicesParams(page: 2, limit: 20);

      expect(a == b, isFalse);
    });

    test('9. GetServicesParams are not equal when limit differs', () {
      const a = GetServicesParams(page: 1, limit: 10);
      const b = GetServicesParams(page: 1, limit: 20);

      expect(a == b, isFalse);
    });

    test(
      '10. returns empty service list when repository returns empty',
      () async {
        final repo = _RecordingServiceRepository(result: const Right([]));
        final usecase = GetServicesUsecase(repository: repo);

        final result = await usecase(
          const GetServicesParams(page: 1, limit: 20),
        );

        result.fold(
          (_) => fail('Expected Right with empty list'),
          (services) => expect(services, isEmpty),
        );
      },
    );
  });
}
