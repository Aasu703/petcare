import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/features/services/di/service_providers.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';
import 'package:petcare/features/services/domain/usecases/get_services_usecase.dart';
import 'package:petcare/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeServiceRepository implements IServiceRepository {
  @override
  Future<Either<Failure, ServiceEntity>> getServiceById(
    String serviceId,
  ) async {
    return Left(ServerFailure(message: 'not implemented'));
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProvider(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    return const Right([]);
  }
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createWidgetUnderTest() {
    final fakeRepo = _FakeServiceRepository();
    final usecase = GetServicesUsecase(repository: fakeRepo);

    return ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        getServicesUsecaseProvider.overrideWithValue(usecase),
      ],
      child: MaterialApp(
        home: Dashboard(firstName: 'Aayush', email: 'aayush@gmail.com'),
      ),
    );
  }

  group('Dashboard Widget Tests', () {
    testWidgets('should render Dashboard widget', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Dashboard), findsOneWidget);
    });

    testWidgets('should show Home screen by default', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should show 4 bottom navigation items', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.store_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('should navigate to Explore screen when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Explore'), findsWidgets);
    });

    testWidgets('should navigate to Shop screen when tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.store_outlined));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Shop'), findsWidgets);
    });

    testWidgets('should navigate to Profile screen when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Profile'), findsWidgets);
    });
  });
}
