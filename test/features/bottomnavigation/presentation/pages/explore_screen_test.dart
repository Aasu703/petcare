import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/explore_screen.dart';
import 'package:petcare/features/services/di/service_providers.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';
import 'package:petcare/features/services/domain/usecases/get_services_usecase.dart';

class _FakeServiceRepository implements IServiceRepository {
  @override
  Future<Either<Failure, ServiceEntity>> getServiceById(String serviceId) async {
    return Left(ServerFailure(message: 'not implemented'));
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    return Right([
      const ServiceEntity(
        serviceId: '1',
        title: 'Vet Consultation',
        description: 'General health check',
        price: 25,
        durationMinutes: 30,
        category: 'Veterinary',
        providerId: 'p-1',
      ),
      const ServiceEntity(
        serviceId: '2',
        title: 'Full Grooming',
        description: 'Bath and grooming',
        price: 40,
        durationMinutes: 60,
        category: 'Grooming',
        providerId: 'p-2',
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProvider(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    return Left(ServerFailure(message: 'not implemented'));
  }
}

void main() {
  testWidgets('ExploreScreen renders backend-driven services', (tester) async {
    final fakeRepo = _FakeServiceRepository();
    final usecase = GetServicesUsecase(repository: fakeRepo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [getServicesUsecaseProvider.overrideWithValue(usecase)],
        child: const MaterialApp(home: ExploreScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Explore Services'), findsOneWidget);
    expect(find.text('Vet Consultation'), findsOneWidget);
    expect(find.text('Full Grooming'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Vet',
    );
    await tester.pump();

    expect(find.text('Vet Consultation'), findsOneWidget);
    expect(find.text('Full Grooming'), findsNothing);
  });
}
