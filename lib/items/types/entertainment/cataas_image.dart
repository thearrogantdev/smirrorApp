import 'package:flutter/material.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

class CataasImageWidgetType extends WidgetTypeDefinition {
  CataasImageWidgetType()
    : super(
        typeId: WidgetIds.cataasImage,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameCataasImage,
        defaultSize: const Size(200, 200),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [];

  @override
  Widget buildChild(ViewConfigItem item) {
    // We show a placeholder/preview in the config app
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        'https://cataas.com/cat',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.pets, color: Colors.white54, size: 40),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    // Since there are no properties to configure,
    // we return the default (empty) list immediately.
    return Future.value(createDefaultProperties());
  }
}
