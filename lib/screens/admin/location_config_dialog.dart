import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/location_service.dart';

class LocationConfigDialog extends StatefulWidget {
  const LocationConfigDialog({super.key});

  @override
  State<LocationConfigDialog> createState() => _LocationConfigDialogState();
}

class _LocationConfigDialogState extends State<LocationConfigDialog> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = GetIt.I<LocationService>().cachedLocation;
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoading = true);
    try {
      final location = await GetIt.I<LocationService>().getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
        });
        _mapController.move(location, 15.0);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorFetchingLocation)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _saveLocation() async {
    if (_currentLocation != null) {
      await GetIt.I<LocationService>().saveLocation(_currentLocation!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initialCenter = _currentLocation ?? const LatLng(51.5, -0.09);

    return AlertDialog(
      title: Text(l10n.locationSettingsTitle),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: _currentLocation != null ? 15.0 : 3.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _currentLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smirror.app',
                    ),
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_currentLocation != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}, Lon: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _fetchLocation,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(l10n.getCurrentLocation),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _currentLocation == null ? null : _saveLocation,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
