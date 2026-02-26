// lib/features/home/presentation/view_model/home_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare/features/bottomnavigation/presentation/state/home_state.dart';
import 'package:petcare/core/services/storage/recent_activity_service.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  String greetingLabel([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> init() async {
    await loadRecentActivities();
  }

  Future<void> loadRecentActivities() async {
    final userId = ref.read(userSessionServiceProvider).getUserId();
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        recentActivities: const [],
        isLoadingRecentActivity: false,
      );
      return;
    }

    state = state.copyWith(isLoadingRecentActivity: true, clearError: true);
    final items = ref
        .read(recentActivityServiceProvider)
        .getActivities(userId, limit: 4);
    state = state.copyWith(
      recentActivities: items,
      isLoadingRecentActivity: false,
    );
  }

  Future<void> trackRecentActivity({
    required String title,
    required String subtitle,
    String kind = 'page',
  }) async {
    final userId = ref.read(userSessionServiceProvider).getUserId();
    if (userId == null || userId.isEmpty) return;

    await ref
        .read(recentActivityServiceProvider)
        .pushActivity(
          userId: userId,
          title: title,
          subtitle: subtitle,
          kind: kind,
        );

    await loadRecentActivities();
  }

  Future<String?> enableMapPreview() async {
    if (state.isRequestingLocation) return null;

    state = state.copyWith(isRequestingLocation: true, clearError: true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled)
        return 'Location services are off. Please enable GPS to open nearby map.';

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Location permission is required to show nearby vets and pet places.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      state = state.copyWith(
        mapPreviewCenter: LatLng(position.latitude, position.longitude),
      );

      await trackRecentActivity(
        title: 'Nearby Map',
        subtitle: 'Enabled location preview',
        kind: 'page',
      );

      return 'Nearby map enabled on home. Tap Open Full Map for details.';
    } catch (_) {
      return 'Unable to open map right now. Please try again.';
    } finally {
      state = state.copyWith(isRequestingLocation: false);
    }
  }

  void clearMapPreview() {
    state = state.copyWith(mapPreviewCenterToNull: true);
  }
}
