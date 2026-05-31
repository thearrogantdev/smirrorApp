import 'package:flutter/material.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/items/types/openweather/open_weather_prompt.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

class RainRadarWidgetType extends WidgetTypeDefinition {
  RainRadarWidgetType()
    : super(
        typeId: WidgetIds.rainRadar,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameRainRadar,
        defaultSize: const Size(300, 300),
      );

  @override
  String? get requiredTokenId => 'openweather';

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsRainRadar.lat,
      type: ViewConfigPropertyType.float,
      floatValue: 52.52, // Berlin fallback
    ),
    ViewConfigProperty(
      key: PropertyIdsRainRadar.lon,
      type: ViewConfigPropertyType.float,
      floatValue: 13.40,
    ),
    ViewConfigProperty(
      key: PropertyIdsRainRadar.zoom,
      type: ViewConfigPropertyType.int,
      intValue: 9, // default zoom (5–15)
    ),
    ViewConfigProperty(
      key: PropertyIdsRainRadar.forecastHours,
      type: ViewConfigPropertyType.int,
      intValue: 4, // default forecast hours (1–10)
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    return const _RainRadarPlaceholder();
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    return promptRainRadarProperties(
      context,
      latPropId: PropertyIdsRainRadar.lat,
      lonPropId: PropertyIdsRainRadar.lon,
      zoomPropId: PropertyIdsRainRadar.zoom,
      forecastHoursPropId: PropertyIdsRainRadar.forecastHours,
      initial: initial,
      onDelete: onDelete,
    );
  }
}

class _RainRadarPlaceholder extends StatelessWidget {
  const _RainRadarPlaceholder();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D3A45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              loc.widgetNameRainRadar,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
