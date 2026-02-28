// lib/features/home/presentation/view_model/home_state.dart
import 'package:latlong2/latlong.dart';
import 'package:petcare/core/services/storage/recent_activity_service.dart';

class HomeState {
  final bool isRequestingLocation;
  final LatLng? mapPreviewCenter;

  final bool isLoadingRecentActivity;
  final List<UserRecentActivity> recentActivities;

  final String? errorMessage;

  const HomeState({
    this.isRequestingLocation = false,
    this.mapPreviewCenter,
    this.isLoadingRecentActivity = true,
    this.recentActivities = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isRequestingLocation,
    LatLng? mapPreviewCenter,
    bool mapPreviewCenterToNull = false,
    bool? isLoadingRecentActivity,
    List<UserRecentActivity>? recentActivities,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      isRequestingLocation: isRequestingLocation ?? this.isRequestingLocation,
      mapPreviewCenter: mapPreviewCenterToNull
          ? null
          : (mapPreviewCenter ?? this.mapPreviewCenter),
      isLoadingRecentActivity:
          isLoadingRecentActivity ?? this.isLoadingRecentActivity,
      recentActivities: recentActivities ?? this.recentActivities,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
