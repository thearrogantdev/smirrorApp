import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/items/types/openweather/open_weather_prompt.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_app/services/open_weather_validation_service.dart';
import 'package:smirror_app/services/token_provider.dart';

class OpenWeatherForecast extends WidgetTypeDefinition {
  OpenWeatherForecast()
    : super(
        typeId: WidgetIds.weatherForecast,
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNameOpenWeatherForecast,
        defaultSize: const Size(220, 90),
      );

  @override
  String? get requiredTokenId => 'openweather';

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsOpenWeatherWidget.city,
      type: ViewConfigPropertyType.string,
      stringValue: 'Berlin',
    ),
    ViewConfigProperty(
      key: PropertyIdsOpenWeatherWidget.units,
      type: ViewConfigPropertyType.int,
      intValue: 0,
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    String s(int k, String d) =>
        item.properties
            .firstWhere(
              (p) => p.key == k,
              orElse: () => ViewConfigProperty(
                key: -1,
                type: ViewConfigPropertyType.string,
              ),
            )
            .stringValue ??
        d;
    int i(int k, int d) =>
        item.properties
            .firstWhere(
              (p) => p.key == k,
              orElse: () =>
                  ViewConfigProperty(key: -1, type: ViewConfigPropertyType.int),
            )
            .intValue ??
        d;

    double? f(int k) =>
        item.properties
            .firstWhere(
              (p) => p.key == k,
              orElse: () => ViewConfigProperty(
                key: -1,
                type: ViewConfigPropertyType.float,
              ),
            )
            .floatValue;

    final city = s(PropertyIdsOpenWeatherWidget.city, 'Berlin');
    final units = i(PropertyIdsOpenWeatherWidget.units, 0);
    final lat = f(PropertyIdsOpenWeatherWidget.lat);
    final lon = f(PropertyIdsOpenWeatherWidget.lon);

    return _OpenWeatherPanel(city: city, units: units, lat: lat, lon: lon);
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    return promptOpenWeatherProperties(
      context,
      latPropId: PropertyIdsOpenWeatherWidget.lat,
      lonPropId: PropertyIdsOpenWeatherWidget.lon,
      cityPropId: PropertyIdsOpenWeatherWidget.city,
      unitsPropId: PropertyIdsOpenWeatherWidget.units,
      initial: initial,
      onDelete: onDelete,
    );
  }
}

final class _OpenWeatherPanel extends StatefulWidget {
  const _OpenWeatherPanel({
    required this.city,
    required this.units,
    this.lat,
    this.lon,
  });

  final String apiKey = "";
  final String city;
  final int units;
  final double? lat;
  final double? lon;

  @override
  State<_OpenWeatherPanel> createState() => _OpenWeatherPanelState();
}

final class _OpenWeatherPanelState extends State<_OpenWeatherPanel> {
  final repo = GetIt.I<OpenWeatherTokenRepository>();
  @override
  void initState() {
    super.initState();

    // Fire-and-forget warmup if no local key and repo is cold.
    final shouldWarmup = switch (repo.status.value) {
      TokenStatus.unknown => true,
      _ => false,
    };

    if (shouldWarmup) {
      final appBloc = context.read<AppWebSocketBloc>();
      final backStream = context.read<BackAppWebSocketBloc>().stream;
      repo.ensureTokenPresent(appBloc: appBloc, backStream: backStream);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalKey = widget.apiKey.trim().isNotEmpty;
    final loc = AppLocalizations.of(context)!;
    final unitLabels = <String>[
      loc.unitsMetricCelsius,
      loc.unitsImperialFahrenheit,
      loc.unitsStandardKelvin,
    ];

    return ValueListenableBuilder<TokenStatus>(
      valueListenable: repo.status,
      builder: (context, status, _) {
        final hasBackendKey = status == TokenStatus.present;

        final checking = switch (status) {
          TokenStatus.unknown || TokenStatus.checking => true,
          _ => false,
        };

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: switch ((hasLocalKey || hasBackendKey, checking)) {
            // Ready
            (true, _) => _panel(
              key: const ValueKey('ok'),
              text: _label(loc, unitLabels, widget.city, widget.units, widget.lat, widget.lon),
            ),

            // Loading
            (false, true) => _panel(
              key: const ValueKey('loading'),
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

            // Missing
            (false, false) => _panel(
              key: const ValueKey('missing'),
              text: loc.apiKeyMissingShort,
            ),
          },
        );
      },
    );
  }

  String _label(
    AppLocalizations loc,
    List<String> unitLabels,
    String city,
    int units,
    double? lat,
    double? lon,
  ) {
    final unitText =
        (units >= 0 && units < unitLabels.length)
            ? unitLabels[units]
            : loc.unknown; // localized fallback

    final locationText =
        (lat != null && lon != null)
            ? '$city (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})'
            : city;

    return loc.weatherPanelSummary(locationText, unitText);
  }

  Widget _panel({Key? key, String? text, Widget? child}) => Container(
    key: key,
    decoration: BoxDecoration(
      color: const Color(0xFF2D3A45),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(8),
    alignment: Alignment.center,
    child:
        child ??
        Text(
          text ?? '',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
  );
}
