import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/items/types/google/google_prompt.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

final class _GoogleTasksPanel extends StatelessWidget {
  final String taskListId;
  final int fontSize;
  final String fontFamily;

  const _GoogleTasksPanel({
    required this.taskListId,
    required this.fontSize,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D3A45),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        '${loc.googleTasksReady}: $taskListId',
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(
          fontFamily,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: fontSize.toDouble(),
          ),
        ),
      ),
    );
  }
}

class GoogleTasksWidget extends WidgetTypeDefinition {
  GoogleTasksWidget()
    : super(
        typeId: WidgetIds.googleTasks,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameGoogleTasks,
        defaultSize: const Size(280, 160),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsGoogleTasksWidget.taskListId,
      type: ViewConfigPropertyType.string,
      stringValue: '@default',
    ),
    ViewConfigProperty(
      key: PropertyIdsGoogleTasksWidget.fontSize,
      type: ViewConfigPropertyType.int,
      intValue: 14,
    ),
    ViewConfigProperty(
      key: PropertyIdsGoogleTasksWidget.fontFamily,
      type: ViewConfigPropertyType.string,
      stringValue: 'Roboto',
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    return _GoogleTasksPanel(
      taskListId:
          item.properties[PropertyIdsGoogleTasksWidget.taskListId].stringValue ??
          '@default',
      fontSize:
          item.properties[PropertyIdsGoogleTasksWidget.fontSize].intValue ??
          14,
      fontFamily:
          item
              .properties[PropertyIdsGoogleTasksWidget.fontFamily]
              .stringValue ??
          'Roboto',
    );
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    return promptGoogleTasksProperties(
      context,
      taskListIdPropId: PropertyIdsGoogleTasksWidget.taskListId,
      fontSizePropId: PropertyIdsGoogleTasksWidget.fontSize,
      fontFamilyPropId: PropertyIdsGoogleTasksWidget.fontFamily,
      initial: initial,
      onDelete: onDelete,
    );
  }
}
