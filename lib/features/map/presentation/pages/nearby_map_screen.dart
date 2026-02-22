import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare/core/api/api_endpoints.dart';

enum NearbyMapMode {
  petShop(
    title: 'Nearby Pet Shops',
    providerType: 'shop',
    overpassQueryLines: [
      '  node["shop"="pet"]',
      '  way["shop"="pet"]',
      '  relation["shop"="pet"]',
    ],
  ),
  vetHospital(
    title: 'Nearby Vet Hospitals',
    providerType: 'vet',
    overpassQueryLines: [
      '  node["amenity"="veterinary"]',
      '  way["amenity"="veterinary"]',
      '  relation["amenity"="veterinary"]',
      '  node["healthcare"="veterinary"]',
      '  way["healthcare"="veterinary"]',
      '  relation["healthcare"="veterinary"]',
    ],
  );

  final String title;
  final String providerType;
  final List<String> overpassQueryLines;

  const NearbyMapMode({
    required this.title,
    required this.providerType,
    required this.overpassQueryLines,
  });
}

class NearbyMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final NearbyMapMode initialMode;

  const NearbyMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.initialMode = NearbyMapMode.petShop,
  });

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  static const double _searchRadiusMeters = 5000;
  static const List<String> _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  final MapController _mapController = MapController();
  bool _isLoading = true;
  String? _error;
  String? _pawcareError;
  String? _osmError;
  late NearbyMapMode _mode;
  bool _showPawcare = true;
  bool _showOsm = true;
  List<_NearbyPlace> _places = const [];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _loadNearbyPlaces();
  }

  List<_NearbyPlace> get _pawcarePlaces =>
      _places.where((place) => place.source == _PlaceSource.pawcare).toList();

  List<_NearbyPlace> get _osmPlaces =>
      _places.where((place) => place.source == _PlaceSource.osm).toList();

  List<_NearbyPlace> get _visiblePlaces => _places.where((place) {
    if (place.source == _PlaceSource.pawcare) return _showPawcare;
    return _showOsm;
  }).toList();

  Future<void> _loadNearbyPlaces() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _pawcareError = null;
      _osmError = null;
    });

    String? pawcareError;
    String? osmError;

    final results = await Future.wait<List<_NearbyPlace>>([
      _fetchPawcarePlaces().catchError((_) {
        pawcareError =
            'Could not load PawCare verified ${_mode == NearbyMapMode.petShop ? 'shops' : 'vets'}.';
        return <_NearbyPlace>[];
      }),
      _fetchOsmPlaces().catchError((_) {
        osmError =
            'Could not load nearby ${_mode == NearbyMapMode.petShop ? 'pet shops' : 'vet hospitals'} from OSM.';
        return <_NearbyPlace>[];
      }),
    ]);

    final merged = <_NearbyPlace>[...results[0], ...results[1]]
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    if (!mounted) return;
    setState(() {
      _places = merged;
      _isLoading = false;
      _pawcareError = pawcareError;
      _osmError = osmError;
      if (merged.isEmpty && (pawcareError != null || osmError != null)) {
        _error = 'Could not load nearby locations. Please try again.';
      }
    });
  }

  Future<List<_NearbyPlace>> _fetchPawcarePlaces() async {
    final client = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final response = await client.get(
      ApiEndpoints.providerVerifiedLocations,
      queryParameters: {'providerType': _mode.providerType},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Invalid verified location response');
    }

    final payload = body['data'];
    final rawItems = payload is List
        ? payload
        : payload is Map && payload['data'] is List
        ? payload['data'] as List
        : const <dynamic>[];

    final places = <_NearbyPlace>[];
    final dedupe = <String>{};
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final item = raw.cast<dynamic, dynamic>();
      final location = item['location'];
      final lat = _toDouble(location is Map ? location['latitude'] : null);
      final lon = _toDouble(location is Map ? location['longitude'] : null);
      if (lat == null || lon == null) continue;

      final providerType = (item['providerType'] as String?)?.toLowerCase();
      final category = providerType == 'vet'
          ? _PlaceCategory.vet
          : _PlaceCategory.petShop;

      final name =
          (item['clinicOrShopName'] as String?)?.trim().isNotEmpty == true
          ? (item['clinicOrShopName'] as String).trim()
          : ((item['businessName'] as String?)?.trim().isNotEmpty == true
                ? (item['businessName'] as String).trim()
                : category.fallbackName);

      final address =
          (location is Map ? location['address'] : null)?.toString().trim() ??
          '';
      final fallbackAddress = item['address']?.toString().trim() ?? '';
      final subtitle = address.isNotEmpty
          ? address
          : fallbackAddress.isNotEmpty
          ? fallbackAddress
          : 'PawCare verified ${category.label.toLowerCase()}';

      final markerKey =
          'pawcare-${name.toLowerCase()}-${lat.toStringAsFixed(5)}-${lon.toStringAsFixed(5)}';
      if (!dedupe.add(markerKey)) continue;

      places.add(
        _NearbyPlace(
          name: name,
          subtitle: subtitle,
          category: category,
          source: _PlaceSource.pawcare,
          lat: lat,
          lon: lon,
          distanceMeters: _distanceInMeters(
            fromLat: widget.latitude,
            fromLon: widget.longitude,
            toLat: lat,
            toLon: lon,
          ),
        ),
      );
    }

    return places.take(40).toList(growable: false);
  }

  Future<List<_NearbyPlace>> _fetchOsmPlaces() async {
    final queryTargets = _mode.overpassQueryLines
        .map(
          (line) =>
              '$line(around:${_searchRadiusMeters.toInt()},${widget.latitude},${widget.longitude});',
        )
        .join('\n');

    final overpassQuery =
        '''
[out:json][timeout:25];
(
$queryTargets
);
out center tags;
''';

    final client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'petcare-mobile-nearby-map',
        },
        validateStatus: (status) => status != null,
      ),
    );

    Map<String, dynamic>? body;

    for (final endpoint in _overpassEndpoints) {
      try {
        final response = await client.post(
          endpoint,
          data: {'data': overpassQuery},
        );
        final status = response.statusCode ?? 500;

        if (status >= 200 && status < 300) {
          if (response.data is Map<String, dynamic>) {
            body = response.data as Map<String, dynamic>;
            break;
          }
          if (response.data is Map) {
            body = Map<String, dynamic>.from(response.data as Map);
            break;
          }
          throw const FormatException('Invalid nearby places response');
        }

        if (status != 429 && status < 500) {
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (body == null) {
      throw Exception('Could not load nearby places');
    }

    final elements = (body['elements'] as List?) ?? const [];
    final places = <_NearbyPlace>[];
    final dedupe = <String>{};

    for (final raw in elements) {
      if (raw is! Map) continue;
      final item = raw.cast<dynamic, dynamic>();
      final lat = _toDouble(item['lat']) ?? _toDouble(item['center']?['lat']);
      final lon = _toDouble(item['lon']) ?? _toDouble(item['center']?['lon']);
      if (lat == null || lon == null) continue;

      final tagsRaw = item['tags'];
      final tags = tagsRaw is Map
          ? tagsRaw.cast<String, dynamic>()
          : <String, dynamic>{};
      final category = _resolveOsmCategory(tags);
      final rawName = (tags['name'] as String?)?.trim();
      final name = (rawName != null && rawName.isNotEmpty)
          ? rawName
          : category.fallbackName;
      final subtitle = _buildOsmSubtitle(tags, category);

      final markerKey =
          'osm-${name.toLowerCase()}-${lat.toStringAsFixed(5)}-${lon.toStringAsFixed(5)}';
      if (!dedupe.add(markerKey)) continue;

      places.add(
        _NearbyPlace(
          name: name,
          subtitle: subtitle,
          category: category,
          source: _PlaceSource.osm,
          lat: lat,
          lon: lon,
          distanceMeters: _distanceInMeters(
            fromLat: widget.latitude,
            fromLon: widget.longitude,
            toLat: lat,
            toLon: lon,
          ),
        ),
      );
    }

    places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return places.take(40).toList(growable: false);
  }

  List<Marker> _buildMarkers(LatLng center, List<_NearbyPlace> visiblePlaces) {
    return <Marker>[
      Marker(
        point: center,
        width: 54,
        height: 54,
        child: _LocationMarker(
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.my_location_rounded,
        ),
      ),
      ...visiblePlaces.map((place) {
        return Marker(
          point: LatLng(place.lat, place.lon),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showPlaceDetails(place),
            child: _LocationMarker(
              color: place.source.color,
              icon: place.category.icon,
            ),
          ),
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);
    final visiblePlaces = _visiblePlaces;
    final visibleCount = visiblePlaces.length > 10 ? 10 : visiblePlaces.length;
    final markers = _buildMarkers(center, visiblePlaces);

    return Scaffold(
      appBar: AppBar(
        title: Text(_mode.title),
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
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
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
                    '${visiblePlaces.length} locations shown (PawCare ${_pawcarePlaces.length} | OSM ${_osmPlaces.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<NearbyMapMode>(
                    segments: const [
                      ButtonSegment(
                        value: NearbyMapMode.petShop,
                        icon: Icon(Icons.pets_rounded),
                        label: Text('Pet Shops'),
                      ),
                      ButtonSegment(
                        value: NearbyMapMode.vetHospital,
                        icon: Icon(Icons.local_hospital_rounded),
                        label: Text('Vets'),
                      ),
                    ],
                    selected: <NearbyMapMode>{_mode},
                    onSelectionChanged: (selection) {
                      final nextMode = selection.first;
                      if (nextMode == _mode) return;
                      setState(() => _mode = nextMode);
                      _loadNearbyPlaces();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  selected: _showPawcare,
                  onSelected: (value) => setState(() => _showPawcare = value),
                  avatar: const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: Color(0xFF2B8A3E),
                  ),
                  label: Text('PawCare verified (${_pawcarePlaces.length})'),
                ),
                FilterChip(
                  selected: _showOsm,
                  onSelected: (value) => setState(() => _showOsm = value),
                  avatar: const Icon(
                    Icons.public_rounded,
                    size: 16,
                    color: Color(0xFFE67700),
                  ),
                  label: Text('Near you OSM (${_osmPlaces.length})'),
                ),
              ],
            ),
          ),
          if (_pawcareError != null || _osmError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                children: [
                  if (_pawcareError != null)
                    _InlineErrorBanner(message: _pawcareError!),
                  if (_osmError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _InlineErrorBanner(message: _osmError!),
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
                    color: Colors.black.withValues(alpha: 0.2),
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
          if (visiblePlaces.isNotEmpty)
            SizedBox(
              height: 154,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                scrollDirection: Axis.horizontal,
                itemCount: visibleCount,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final place = visiblePlaces[index];
                  return SizedBox(
                    width: 220,
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
                            color: place.source.color.withValues(alpha: 0.25),
                          ),
                          color: place.source.color.withValues(alpha: 0.08),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  place.category.icon,
                                  color: place.source.color,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    place.source.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                    backgroundColor: place.source.color.withValues(alpha: 0.15),
                    foregroundColor: place.source.color,
                    child: Icon(place.category.icon),
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
                          '${place.source.label} | ${place.category.label}',
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

  _PlaceCategory _resolveOsmCategory(Map<String, dynamic> tags) {
    final amenity = (tags['amenity'] as String?)?.toLowerCase();
    final healthcare = (tags['healthcare'] as String?)?.toLowerCase();
    if (amenity == 'veterinary' || healthcare == 'veterinary') {
      return _PlaceCategory.vet;
    }
    return _PlaceCategory.petShop;
  }

  String _buildOsmSubtitle(Map<String, dynamic> tags, _PlaceCategory category) {
    final parts = <String>[
      if ((tags['addr:housenumber'] as String?)?.isNotEmpty == true)
        tags['addr:housenumber'] as String,
      if ((tags['addr:street'] as String?)?.isNotEmpty == true)
        tags['addr:street'] as String,
      if ((tags['addr:city'] as String?)?.isNotEmpty == true)
        tags['addr:city'] as String,
      if ((tags['opening_hours'] as String?)?.isNotEmpty == true)
        'Hours: ${tags['opening_hours']}',
    ];
    return parts.isEmpty ? category.fallbackName : parts.join(' | ');
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
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class _InlineErrorBanner extends StatelessWidget {
  final String message;

  const _InlineErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: Color(0xFFB91C1C),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
            color: Colors.black.withValues(alpha: 0.2),
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
  final _PlaceCategory category;
  final _PlaceSource source;
  final double lat;
  final double lon;
  final double distanceMeters;

  const _NearbyPlace({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.source,
    required this.lat,
    required this.lon,
    required this.distanceMeters,
  });
}

enum _PlaceCategory {
  vet(
    label: 'Veterinary',
    fallbackName: 'Veterinary Clinic',
    icon: Icons.local_hospital_rounded,
  ),
  petShop(
    label: 'Pet Shop',
    fallbackName: 'Pet Shop',
    icon: Icons.pets_rounded,
  );

  final String label;
  final String fallbackName;
  final IconData icon;

  const _PlaceCategory({
    required this.label,
    required this.fallbackName,
    required this.icon,
  });
}

enum _PlaceSource {
  pawcare(label: 'PawCare Verified', color: Color(0xFF2B8A3E)),
  osm(label: 'Near You (OSM)', color: Color(0xFFE67700));

  final String label;
  final Color color;

  const _PlaceSource({required this.label, required this.color});
}
