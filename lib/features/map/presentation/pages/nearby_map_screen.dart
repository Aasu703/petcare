import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NearbyMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  String? _error;
  List<_NearbyPlace> _places = const [];

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'petcare-mobile-nearby-map',
          },
        ),
      );

      final data =
          '''
[out:json][timeout:25];
(
  node["amenity"="veterinary"](around:4500,${widget.latitude},${widget.longitude});
  way["amenity"="veterinary"](around:4500,${widget.latitude},${widget.longitude});
  node["shop"="pet"](around:4500,${widget.latitude},${widget.longitude});
  way["shop"="pet"](around:4500,${widget.latitude},${widget.longitude});
  node["leisure"="dog_park"](around:4500,${widget.latitude},${widget.longitude});
  way["leisure"="dog_park"](around:4500,${widget.latitude},${widget.longitude});
);
out center;
''';

      final response = await client.post(
        'https://overpass-api.de/api/interpreter',
        data: {'data': data},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Invalid nearby places response');
      }

      final elements = (body['elements'] as List?) ?? const [];
      final places = <_NearbyPlace>[];
      final dedupe = <String>{};

      for (final raw in elements) {
        if (raw is! Map) {
          continue;
        }

        final item = raw.cast<dynamic, dynamic>();
        final lat = _toDouble(item['lat']) ?? _toDouble(item['center']?['lat']);
        final lon = _toDouble(item['lon']) ?? _toDouble(item['center']?['lon']);
        if (lat == null || lon == null) {
          continue;
        }

        final tagsRaw = item['tags'];
        final tags = tagsRaw is Map
            ? tagsRaw.cast<String, dynamic>()
            : <String, dynamic>{};
        final placeType = _resolvePlaceType(tags);
        final name = (tags['name'] as String?)?.trim();

        final markerKey =
            '${name ?? placeType.label}-${lat.toStringAsFixed(5)}-${lon.toStringAsFixed(5)}';
        if (dedupe.contains(markerKey)) {
          continue;
        }
        dedupe.add(markerKey);

        final distance = _distanceInMeters(
          fromLat: widget.latitude,
          fromLon: widget.longitude,
          toLat: lat,
          toLon: lon,
        );

        places.add(
          _NearbyPlace(
            name: (name == null || name.isEmpty)
                ? placeType.fallbackName
                : name,
            subtitle: _buildSubtitle(tags, placeType),
            type: placeType,
            lat: lat,
            lon: lon,
            distanceMeters: distance,
          ),
        );
      }

      places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _places = places.take(50).toList(growable: false);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = 'Could not load nearby vets and pet places. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);
    final markers = <Marker>[
      Marker(
        point: center,
        width: 54,
        height: 54,
        child: _LocationMarker(
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.my_location_rounded,
        ),
      ),
      ..._places.map((place) {
        return Marker(
          point: LatLng(place.lat, place.lon),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showPlaceDetails(place),
            child: _LocationMarker(
              color: place.type.color,
              icon: place.type.icon,
            ),
          ),
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Vets & Pets'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadNearbyPlaces,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.55),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_places.length} places found near your current location',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 14.0,
                    minZoom: 3.0,
                    maxZoom: 19.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.petcare.app',
                      maxNativeZoom: 19,
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                if (_error != null)
                  Center(
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _loadNearbyPlaces,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_places.isNotEmpty)
            SizedBox(
              height: 148,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                scrollDirection: Axis.horizontal,
                itemCount: _places.length.clamp(0, 10),
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final place = _places[index];
                  return SizedBox(
                    width: 210,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        _mapController.move(LatLng(place.lat, place.lon), 16);
                        _showPlaceDetails(place);
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: place.type.color.withOpacity(0.2),
                          ),
                          color: place.type.color.withOpacity(0.08),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  place.type.icon,
                                  color: place.type.color,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    place.type.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              place.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDistance(place.distanceMeters),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showPlaceDetails(_NearbyPlace place) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: place.type.color.withOpacity(0.15),
                    foregroundColor: place.type.color,
                    child: Icon(place.type.icon),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          place.type.label,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (place.subtitle != null && place.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  place.subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Distance: ${_formatDistance(place.distanceMeters)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;

  double _distanceInMeters({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
  }) {
    const earthRadius = 6371000.0;
    final latDelta = _toRadians(toLat - fromLat);
    final lonDelta = _toRadians(toLon - fromLon);
    final a =
        math.sin(latDelta / 2) * math.sin(latDelta / 2) +
        math.cos(_toRadians(fromLat)) *
            math.cos(_toRadians(toLat)) *
            math.sin(lonDelta / 2) *
            math.sin(lonDelta / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km away';
    }
    return '${meters.toStringAsFixed(0)} m away';
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  _PlaceType _resolvePlaceType(Map<String, dynamic> tags) {
    final amenity = (tags['amenity'] as String?)?.toLowerCase();
    final shop = (tags['shop'] as String?)?.toLowerCase();
    final leisure = (tags['leisure'] as String?)?.toLowerCase();

    if (amenity == 'veterinary') {
      return _PlaceType.vet;
    }
    if (shop == 'pet') {
      return _PlaceType.petShop;
    }
    if (leisure == 'dog_park') {
      return _PlaceType.petPark;
    }
    return _PlaceType.petSpot;
  }

  String? _buildSubtitle(Map<String, dynamic> tags, _PlaceType type) {
    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String?;
    final openingHours = tags['opening_hours'] as String?;
    final phone = tags['phone'] as String?;

    final parts = <String>[
      if (street != null && street.isNotEmpty) street,
      if (city != null && city.isNotEmpty) city,
      if (openingHours != null && openingHours.isNotEmpty)
        'Hours: $openingHours',
      if (phone != null && phone.isNotEmpty) 'Phone: $phone',
    ];

    if (parts.isEmpty) {
      return type.fallbackName;
    }
    return parts.join(' | ');
  }
}

class _LocationMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _LocationMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Icon(icon, color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

class _NearbyPlace {
  final String name;
  final String? subtitle;
  final _PlaceType type;
  final double lat;
  final double lon;
  final double distanceMeters;

  const _NearbyPlace({
    required this.name,
    required this.subtitle,
    required this.type,
    required this.lat,
    required this.lon,
    required this.distanceMeters,
  });
}

enum _PlaceType {
  vet(
    label: 'Veterinary',
    fallbackName: 'Veterinary Clinic',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFE03131),
  ),
  petShop(
    label: 'Pet Shop',
    fallbackName: 'Pet Shop',
    icon: Icons.pets_rounded,
    color: Color(0xFF1C7ED6),
  ),
  petPark(
    label: 'Dog Park',
    fallbackName: 'Dog Park',
    icon: Icons.park_rounded,
    color: Color(0xFF2B8A3E),
  ),
  petSpot(
    label: 'Pet Spot',
    fallbackName: 'Pet Friendly Spot',
    icon: Icons.place_rounded,
    color: Color(0xFF5F3DC4),
  );

  final String label;
  final String fallbackName;
  final IconData icon;
  final Color color;

  const _PlaceType({
    required this.label,
    required this.fallbackName,
    required this.icon,
    required this.color,
  });
}
