// lib/features/home/presentation/widgets/quick_actions.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class QuickActionsSection extends StatelessWidget {
  final bool isRequestingLocation;
  final LatLng? mapPreviewCenter;
  final VoidCallback onEnableMap;
  final VoidCallback onOpenFullMap;
  final VoidCallback onOpenMessages;

  const QuickActionsSection({
    super.key,
    required this.isRequestingLocation,
    required this.mapPreviewCenter,
    required this.onEnableMap,
    required this.onOpenFullMap,
    required this.onOpenMessages,
  });

  @override
  Widget build(BuildContext context) {
    final hasMap = mapPreviewCenter != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  title: 'Messages',
                  subtitle: 'Open chats',
                  icon: Icons.chat_rounded,
                  onTap: onOpenMessages,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickCard(
                  title: isRequestingLocation
                      ? 'Requesting...'
                      : (hasMap ? 'Nearby Map Ready' : 'Enable Map'),
                  subtitle: hasMap
                      ? 'Find vets & pet spots nearby'
                      : 'Allow location to show map here',
                  icon: Icons.map_rounded,
                  onTap: isRequestingLocation
                      ? null
                      : (hasMap ? onOpenFullMap : onEnableMap),
                  isLoading: isRequestingLocation,
                ),
              ),
            ],
          ),
          // if (hasMap) InlineMapPreview(...) // keep as separate widget too
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
