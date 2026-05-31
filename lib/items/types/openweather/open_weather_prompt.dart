import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:latlong2/latlong.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_app/screens/admin/location_config_dialog.dart';
import 'package:smirror_app/services/location_service.dart';
import 'package:smirror_app/services/open_weather_validation_service.dart';

const _fCity = 'k_city';
const _fUnits = 'k_units';
const _fLat = 'k_lat';
const _fLon = 'k_lon';
const _fZoom = 'k_zoom';
const _fForecastHours = 'k_forecast_hours';
const unitLabels = ['metric (°C)', 'imperial (°F)', 'standard (K)'];

String _readString(List<ViewConfigProperty>? props, int key, String fallback) {
  if (props == null) return fallback;
  for (final p in props) {
    if (p.key == key) return p.stringValue ?? fallback;
  }
  return fallback;
}

int _readInt(List<ViewConfigProperty>? props, int key, int fallback) {
  if (props == null) return fallback;
  for (final p in props) {
    if (p.key == key) return p.intValue ?? fallback;
  }
  return fallback;
}

Future<List<ViewConfigProperty>?> promptOpenWeatherProperties(
  BuildContext context, {
  required int cityPropId,
  required int unitsPropId,
  required int latPropId,
  required int lonPropId,
  List<ViewConfigProperty>? initial,
  VoidCallback? onDelete,
}) async {
  final loc = AppLocalizations.of(context)!;

  // We don’t support a *local* key here; only backend or user entry in dialog.
  final existingCity = _readString(initial, cityPropId, 'Berlin');
  final existingUnits = _readInt(initial, unitsPropId, 0);

  final repo = GetIt.I<OpenWeatherTokenRepository>();
  final hasBackendKey = repo.hasToken;

  GlobalKey<FormBuilderState>? fbKey;

  final dialogTitle = loc.openWeatherSettingsTitle;

  final values = await showConfigDialog<Map<String, dynamic>>(
    context: context,
    title: dialogTitle,
    onDelete: onDelete,
    initialValues: {
      _fCity: existingCity,
      _fUnits: existingUnits,
    },
    buildForm: (ctx, formKey) {
      fbKey = formKey;
      return _OpenWeatherConfigForm(
        fbKey: fbKey!,
        hasBackendKey: hasBackendKey,
        loc: loc,
      );
    },
    onSubmit: (vals) async {
      final out = Map<String, dynamic>.from(vals);
      final typedCity = (out[_fCity] as String? ?? '').trim();
      final lat = out[_fLat] as double?;
      final lon = out[_fLon] as double?;

      if (!hasBackendKey) {
        return null;
      }

      if (lat != null && lon != null) {
        // We have coordinates, maybe validate them or just refresh city name
        final locRes = await repo.checkLocation(lat: lat, lon: lon);
        if (locRes.ok) {
          out[_fCity] = locRes.message ?? typedCity;
        }
        return out;
      }

      // Fallback to city validation if no coordinates
      final cityRes = await repo.checkCity(city: typedCity);

      if (!cityRes.ok) {
        fbKey?.currentState?.fields[_fCity]?.invalidate(
          cityRes.message ?? loc.cityNotFound,
        );
        return null;
      }

      out[_fLat] = cityRes.lat;
      out[_fLon] = cityRes.lon;

      return out;
    },
  );

  if (values == null) return null;

  final city = switch (values[_fCity]) {
    final String s => s.trim(),
    final Object o => o.toString().trim(),
    _ => '',
  };
  final units = switch (values[_fUnits]) {
    final int i => i,
    final String s => int.tryParse(s) ?? 0,
    null => 0,
    _ => 0,
  };

  final cityFinal = city.isEmpty ? 'Berlin' : city;

  return [
    ViewConfigProperty(
      key: cityPropId,
      type: ViewConfigPropertyType.string,
      stringValue: cityFinal,
    ),
    ViewConfigProperty(
      key: unitsPropId,
      type: ViewConfigPropertyType.int,
      intValue: units,
    ),
    ViewConfigProperty(
      key: latPropId,
      type: ViewConfigPropertyType.float,
      floatValue: values[_fLat],
    ),
    ViewConfigProperty(
      key: lonPropId,
      type: ViewConfigPropertyType.float,
      floatValue: values[_fLon],
    ),
  ];
}

Future<List<ViewConfigProperty>?> promptRainRadarProperties(
  BuildContext context, {
  required int latPropId,
  required int lonPropId,
  required int zoomPropId,
  required int forecastHoursPropId,
  List<ViewConfigProperty>? initial,
  VoidCallback? onDelete,
}) async {
  final loc = AppLocalizations.of(context)!;
  final repo = GetIt.I<OpenWeatherTokenRepository>();
  final hasBackendKey = repo.hasToken;

  double? existingLat;
  double? existingLon;
  int existingZoom = 9;
  int existingForecastHours = 4;

  if (initial != null) {
    for (final p in initial) {
      if (p.key == latPropId) existingLat = p.floatValue;
      if (p.key == lonPropId) existingLon = p.floatValue;
      if (p.key == zoomPropId) existingZoom = p.intValue ?? 9;
      if (p.key == forecastHoursPropId) existingForecastHours = p.intValue ?? 4;
    }
  }

  GlobalKey<FormBuilderState>? fbKey;

  final values = await showConfigDialog<Map<String, dynamic>>(
    context: context,
    title: loc.rainRadarSettingsTitle,
    onDelete: onDelete,
    initialValues: {
      _fLat: existingLat,
      _fLon: existingLon,
      _fZoom: existingZoom,
      _fForecastHours: existingForecastHours,
    },
    buildForm: (ctx, formKey) {
      fbKey = formKey;
      return _RainRadarConfigForm(
        fbKey: fbKey!,
        hasBackendKey: hasBackendKey,
        loc: loc,
      );
    },
    onSubmit: (vals) async {
      if (!hasBackendKey) {
        return null;
      }
      return vals;
    },
  );

  if (values == null) return null;

  final zoom = switch (values[_fZoom]) {
    final int i => i,
    final double d => d.round(),
    _ => 9,
  };
  final forecastHours = switch (values[_fForecastHours]) {
    final int i => i,
    final double d => d.round(),
    _ => 4,
  };

  return [
    ViewConfigProperty(
      key: latPropId,
      type: ViewConfigPropertyType.float,
      floatValue: values[_fLat],
    ),
    ViewConfigProperty(
      key: lonPropId,
      type: ViewConfigPropertyType.float,
      floatValue: values[_fLon],
    ),
    ViewConfigProperty(
      key: zoomPropId,
      type: ViewConfigPropertyType.int,
      intValue: zoom.clamp(5, 15),
    ),
    ViewConfigProperty(
      key: forecastHoursPropId,
      type: ViewConfigPropertyType.int,
      intValue: forecastHours.clamp(1, 10),
    ),
  ];
}

class _OpenWeatherConfigForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final bool hasBackendKey;
  final AppLocalizations loc;

  const _OpenWeatherConfigForm({
    required this.fbKey,
    required this.hasBackendKey,
    required this.loc,
  });

  @override
  State<_OpenWeatherConfigForm> createState() => _OpenWeatherConfigFormState();
}

class _OpenWeatherConfigFormState extends State<_OpenWeatherConfigForm> {
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFetchIfNeeded();
    });
  }

  Future<void> _autoFetchIfNeeded() async {
    final city = widget.fbKey.currentState?.fields[_fCity]?.value as String?;
    final lat = widget.fbKey.currentState?.fields[_fLat]?.value;
    final lon = widget.fbKey.currentState?.fields[_fLon]?.value;

    if ((city == null || city.isEmpty || city == 'Berlin') && lat == null && lon == null) {
      final locationService = GetIt.I<LocationService>();
      LatLng? loc = locationService.cachedLocation;
      if (loc == null) {
        setState(() => _isFetchingLocation = true);
        loc = await locationService.getCurrentLocation();
        setState(() => _isFetchingLocation = false);
      }

      if (loc != null && mounted) {
        _updateLocation(loc);
      }
    }
  }

  void _updateLocation(LatLng loc) async {
    widget.fbKey.currentState?.fields[_fLat]?.didChange(loc.latitude);
    widget.fbKey.currentState?.fields[_fLon]?.didChange(loc.longitude);

    // Try to reverse geocode to get a nice city name
    final repo = GetIt.I<OpenWeatherTokenRepository>();
    final res = await repo.checkLocation(lat: loc.latitude, lon: loc.longitude);
    if (res.ok && mounted) {
      widget.fbKey.currentState?.fields[_fCity]?.didChange(res.message);
    }
  }

  Future<void> _pickOnMap() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const LocationConfigDialog(),
    );

    if (result == true && mounted) {
      final loc = GetIt.I<LocationService>().cachedLocation;
      if (loc != null) {
        _updateLocation(loc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.hasBackendKey) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.loc.adminTokenMissingWarning("OpenWeather"),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        FormBuilderTextField(
          name: _fCity,
          decoration: InputDecoration(
            labelText: widget.loc.cityLabel,
            suffixIcon: _isFetchingLocation
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.map_outlined),
                    onPressed: _pickOnMap,
                    tooltip: "Change Location",
                  ),
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderDropdown<int>(
          name: _fUnits,
          decoration: InputDecoration(labelText: widget.loc.unitsLabel),
          items: [
            DropdownMenuItem(value: 0, child: Text(widget.loc.unitsMetricCelsius)),
            DropdownMenuItem(
              value: 1,
              child: Text(widget.loc.unitsImperialFahrenheit),
            ),
            DropdownMenuItem(value: 2, child: Text(widget.loc.unitsStandardKelvin)),
          ],
        ),
        // Hidden fields to store lat/lon
        FormBuilderField<double>(name: _fLat, builder: (field) => const SizedBox.shrink()),
        FormBuilderField<double>(name: _fLon, builder: (field) => const SizedBox.shrink()),
      ],
    );
  }
}

class _RainRadarConfigForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final bool hasBackendKey;
  final AppLocalizations loc;

  const _RainRadarConfigForm({
    required this.fbKey,
    required this.hasBackendKey,
    required this.loc,
  });

  @override
  State<_RainRadarConfigForm> createState() => _RainRadarConfigFormState();
}

// Helper to safely read an int from the form (handles int or double from sliders).
int _intFromField(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is double) return value.round();
  return fallback;
}

class _RainRadarConfigFormState extends State<_RainRadarConfigForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFetchIfNeeded();
    });
  }

  Future<void> _autoFetchIfNeeded() async {
    final lat = widget.fbKey.currentState?.fields[_fLat]?.value;
    final lon = widget.fbKey.currentState?.fields[_fLon]?.value;

    if (lat == null && lon == null) {
      final locationService = GetIt.I<LocationService>();
      LatLng? loc = locationService.cachedLocation;
      loc ??= await locationService.getCurrentLocation();

      if (loc != null && mounted) {
        _updateLocation(loc);
      }
    }
  }

  void _updateLocation(LatLng loc) {
    widget.fbKey.currentState?.fields[_fLat]?.didChange(loc.latitude);
    widget.fbKey.currentState?.fields[_fLon]?.didChange(loc.longitude);
  }

  Future<void> _pickOnMap() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const LocationConfigDialog(),
    );

    if (result == true && mounted) {
      final loc = GetIt.I<LocationService>().cachedLocation;
      if (loc != null) {
        _updateLocation(loc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.hasBackendKey) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.loc.adminTokenMissingWarning("OpenWeather"),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ListTile(
          title: Text(widget.loc.locationConfig),
          subtitle: FormBuilderField<double>(
            name: _fLat,
            builder: (field) {
              final lat = field.value;
              final lon = widget.fbKey.currentState?.fields[_fLon]?.value;
              if (lat == null || lon == null) return Text(widget.loc.unknown);
              return Text('${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}');
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: _pickOnMap,
          ),
        ),
        // Hidden field to store lon
        FormBuilderField<double>(name: _fLon, builder: (field) => const SizedBox.shrink()),
        const SizedBox(height: 16),
        // ── Zoom slider ──────────────────────────────────────────────────
        FormBuilderField<int>(
          name: _fZoom,
          initialValue: _intFromField(
            widget.fbKey.currentState?.fields[_fZoom]?.value,
            9,
          ),
          builder: (field) {
            final val = _intFromField(field.value, 9).clamp(5, 15);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.loc.rainRadarZoomLabel}: $val',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: val.toDouble(),
                  min: 5,
                  max: 15,
                  divisions: 10,
                  label: '$val',
                  onChanged: (v) => field.didChange(v.round()),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        // ── Forecast hours slider ────────────────────────────────────────
        FormBuilderField<int>(
          name: _fForecastHours,
          initialValue: _intFromField(
            widget.fbKey.currentState?.fields[_fForecastHours]?.value,
            4,
          ),
          builder: (field) {
            final val = _intFromField(field.value, 4).clamp(1, 10);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.loc.rainRadarForecastHoursLabel}: $val h',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: val.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$val h',
                  onChanged: (v) => field.didChange(v.round()),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
