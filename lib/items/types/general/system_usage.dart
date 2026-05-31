import 'package:flutter/material.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

class SystemUsageWidgetType extends WidgetTypeDefinition {
  SystemUsageWidgetType()
    : super(
        typeId: WidgetIds.systemUsage,
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNameSystemUsage,
        defaultSize: const Size(200, 100),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [];

  @override
  Widget buildChild(ViewConfigItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.memory, color: Colors.white54, size: 32),
            SizedBox(height: 8),
            Text(
              'System Usage',
              style: TextStyle(color: Colors.white70),
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
    return Future.value(createDefaultProperties());
  }
}
