import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
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
                  title: l10n.tr('messages'),
                  subtitle: l10n.tr('openChats'),
                  icon: Icons.chat_rounded,
                  onTap: onOpenMessages,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickCard(
                  title: isRequestingLocation
                      ? l10n.tr('requesting')
                      : (hasMap
                            ? l10n.tr('nearbyMapReady')
                            : l10n.tr('enableMap')),
                  subtitle: hasMap
                      ? l10n.tr('findVetsPetSpots')
                      : l10n.tr('allowLocationMap'),
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
