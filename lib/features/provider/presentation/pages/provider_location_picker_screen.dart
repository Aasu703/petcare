import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ProviderLocationPickResult {
  final double latitude;
  final double longitude;
  final String locationNote;

  const ProviderLocationPickResult({
    required this.latitude,
    required this.longitude,
    this.locationNote = '',
  });
}

class ProviderLocationPickerScreen extends StatefulWidget {
  final String title;
  final double? initialLatitude;
  final double? initialLongitude;
  final String initialNote;

  const ProviderLocationPickerScreen({
    super.key,
    required this.title,
    this.initialLatitude,
    this.initialLongitude,
    this.initialNote = '',
  });

  @override
  State<ProviderLocationPickerScreen> createState() =>
      _ProviderLocationPickerScreenState();
}

class _ProviderLocationPickerScreenState
    extends State<ProviderLocationPickerScreen> {
  static const LatLng _defaultCenter = LatLng(27.7172, 85.3240);
  final MapController _mapController = MapController();
  late final TextEditingController _noteController;
  LatLng? _selectedPin;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPin = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage(
          'Location service is off. Please enable GPS/location and try again.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('Location permission denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _selectedPin = latLng);
      _mapController.move(latLng, 16);
    } catch (_) {
      _showMessage('Unable to fetch current location right now.');
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _savePin() {
    final selectedPin = _selectedPin;
    if (selectedPin == null) {
      _showMessage('Please tap on map to pin your location.');
      return;
    }

    Navigator.of(context).pop(
      ProviderLocationPickResult(
        latitude: selectedPin.latitude,
        longitude: selectedPin.longitude,
        locationNote: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _selectedPin ?? _defaultCenter;
    final pin = _selectedPin;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(onPressed: _savePin, child: const Text('Save Pin')),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap on map to place your business pin.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (pin == null)
                  const Text(
                    'No pin selected yet.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                else
                  Text(
                    'Pinned: ${pin.latitude.toStringAsFixed(6)}, ${pin.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F4F57),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: pin == null ? 12 : 16,
                onTap: (_, latLng) {
                  setState(() => _selectedPin = latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.petcare.app',
                  maxNativeZoom: 19,
                ),
                if (pin != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pin,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFFE03131),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Location Note (Optional)',
                    hintText: 'Landmark, floor, nearby reference',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLocating ? null : _useCurrentLocation,
                        icon: Icon(
                          Icons.my_location_rounded,
                          color: _isLocating
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          _isLocating ? 'Locating...' : 'Use Current',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _savePin,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Save Pin'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
