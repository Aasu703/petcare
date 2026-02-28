import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/core/session/session_provider.dart';
import 'package:petcare/core/session/router_notifier.dart';
import 'package:petcare/features/auth/presentation/pages/login.dart';
import 'package:petcare/features/auth/presentation/pages/provider_signup.dart';
import 'package:petcare/features/auth/presentation/pages/signup.dart';
import 'package:petcare/features/bookings/presentation/pages/book_appointment_page.dart';
import 'package:petcare/features/bookings/presentation/pages/booking_calendar_page.dart';
import 'package:petcare/features/bookings/presentation/pages/booking_history_page.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/explore_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/home_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/profile_screen.dart';
import 'package:petcare/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:petcare/features/onboarding/presentation/pages/service_onboarding_screen.dart';
import 'package:petcare/features/onboarding/presentation/pages/vet_onboarding_screen.dart';
import 'package:petcare/features/pet/presentation/pages/add_pet.dart';
import 'package:petcare/features/pet/presentation/pages/my_pet.dart';
import 'package:petcare/features/provider/presentation/pages/provider_login_screen.dart';
import 'package:petcare/features/provider/presentation/pages/provider_main_dashboard.dart';
import 'package:petcare/features/shop/presentation/pages/product_list_page.dart';
import 'package:petcare/features/splash/presentation/pages/splash_screen.dart';
import 'package:petcare/shared/navigation/user_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);
  final notifier = ref.watch(routerNotifierProvider);

  bool isAuthRoute(String location) {
    return location == RoutePaths.login ||
        location == RoutePaths.register ||
        location == RoutePaths.providerLogin ||
        location == RoutePaths.providerRegister ||
        location == RoutePaths.onboarding ||
        location == RoutePaths.onboardingVet ||
        location == RoutePaths.onboardingServices ||
        location == RoutePaths.splash;
  }

  bool isProtectedRoute(String location) {
    return location.startsWith(RoutePaths.home) ||
        location.startsWith(RoutePaths.explore) ||
        location.startsWith(RoutePaths.shop) ||
        location.startsWith(RoutePaths.profile) ||
        location.startsWith(RoutePaths.bookings) ||
        location.startsWith(RoutePaths.pets) ||
        location.startsWith(RoutePaths.providerDashboard);
  }

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthenticated = session.isLoggedIn;
      final role = (session.role ?? '').toLowerCase();

      // Unauthenticated users trying to access protected routes → login
      if (!isAuthenticated && isProtectedRoute(location)) {
        return RoutePaths.login;
      }

      // Authenticated users on auth routes → redirect to appropriate home
      if (isAuthenticated && isAuthRoute(location)) {
        return role == 'provider'
            ? RoutePaths.providerDashboard
            : RoutePaths.home;
      }

      // Non-provider users trying to access provider routes → user home
      if (isAuthenticated &&
          role != 'provider' &&
          location.startsWith(RoutePaths.providerDashboard)) {
        return RoutePaths.home;
      }

      // Provider users trying to access user-only routes → provider dashboard
      if (isAuthenticated &&
          role == 'provider' &&
          (location.startsWith(RoutePaths.home) ||
              location.startsWith(RoutePaths.explore) ||
              location.startsWith(RoutePaths.shop) ||
              location.startsWith(RoutePaths.profile))) {
        return RoutePaths.providerDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => Onbording(),
      ),
      GoRoute(
        path: RoutePaths.onboardingVet,
        builder: (context, state) => const VetOnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingServices,
        builder: (context, state) => const ServiceOnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const Signup(),
      ),
      GoRoute(
        path: RoutePaths.providerLogin,
        builder: (context, state) => ProviderLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.providerRegister,
        builder: (context, state) => const ProviderSignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.providerDashboard,
        builder: (context, state) => const ProviderDashboard(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return UserShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => HomeScreen(
                  firstName: session.firstName ?? 'User',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.shop,
                builder: (context, state) => const ProductListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.bookings,
        builder: (context, state) => const BookingHistoryPage(),
      ),
      GoRoute(
        path: RoutePaths.bookingNew,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final parsedPrice = double.tryParse(query['price'] ?? '');
          return BookAppointmentPage(
            providerId: query['providerId'],
            serviceId: query['serviceId'],
            petId: query['petId'],
            price: parsedPrice,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.bookingCalendar,
        builder: (context, state) => const BookingCalendarPage(),
      ),
      GoRoute(path: RoutePaths.pets, builder: (context, state) => MyPet()),
      GoRoute(
        path: RoutePaths.addPet,
        builder: (context, state) => const AddPet(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Text('Route not found: ${state.uri.toString()}'),
        ),
      );
    },
  );
});
