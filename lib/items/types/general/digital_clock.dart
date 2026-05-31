import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

class DigitalClockWidgetType extends WidgetTypeDefinition {
  DigitalClockWidgetType()
      : super(
          typeId: WidgetIds.digitalClock,
          nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameDigitalClock,
          defaultSize: const Size(150, 80),
        );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
        ViewConfigProperty(
          key: PropertyIdsDigitalClock.show24Hours,
          type: ViewConfigPropertyType.bool,
          boolValue: true,
        ),
      ];

  @override
  Widget buildChild(ViewConfigItem item) {
    final show24Hours = item.properties
            .firstWhere(
              (p) => p.key == PropertyIdsDigitalClock.show24Hours,
              orElse: () => ViewConfigProperty(
                key: -1,
                type: ViewConfigPropertyType.bool,
                boolValue: true,
              ),
            )
            .boolValue ??
        true;

    final timeStr = show24Hours ? "12:34" : "12:34 PM";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, color: Colors.white54, size: 28),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    final existing24h = initial
            ?.firstWhere(
              (p) => p.key == PropertyIdsDigitalClock.show24Hours,
              orElse: () => createDefaultProperties()[0],
            )
            .boolValue ??
        true;

    final loc = AppLocalizations.of(context)!;

    return showConfigDialog<List<ViewConfigProperty>>(
      context: context,
      title: loc.digitalClockSettingsTitle,
      onDelete: onDelete,
      initialValues: {
        'k${PropertyIdsDigitalClock.show24Hours}': existing24h,
      },
      buildForm: (ctx, formKey) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderSwitch(
              name: 'k${PropertyIdsDigitalClock.show24Hours}',
              title: Text(loc.digitalClock24hLabel),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ],
        );
      },
      onSubmit: (values) {
        final show24Hours = values['k${PropertyIdsDigitalClock.show24Hours}'] as bool? ?? true;

        return [
          ViewConfigProperty(
            key: PropertyIdsDigitalClock.show24Hours,
            type: ViewConfigPropertyType.bool,
            boolValue: show24Hours,
          ),
        ];
      },
    );
  }
}
