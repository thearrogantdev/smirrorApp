import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/items/types/google/google_prompt.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_wire/generated/widget_internals_widget_internals_generated.dart';

final class _GoogleCalendarPanel extends StatelessWidget {
  final List<String> calendarIds;
  final int fontSize;
  final String fontFamily;

  const _GoogleCalendarPanel({
    required this.calendarIds,
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
        '${loc.googleCalendarReady}: ${calendarIds.join(', ')}',
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

class GoogleCalendarUpcoming extends WidgetTypeDefinition {
  GoogleCalendarUpcoming()
    : super(
        typeId: WidgetIds.googleCalendarUpcoming,
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNameGoogleCalendarUpcoming,
        defaultSize: const Size(280, 160),
      );



  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsGoogleCalendarWidget.calendarId,
      type: ViewConfigPropertyType.rawBytes,
      rawBytes: GoogleCaledarIdsObjectBuilder(ids: ['primary']).toBytes(),
    ),
    ViewConfigProperty(
      key: PropertyIdsGoogleCalendarWidget.fontSize,
      type: ViewConfigPropertyType.int,
      intValue: 14,
    ),
    ViewConfigProperty(
      key: PropertyIdsGoogleCalendarWidget.fontFamily,
      type: ViewConfigPropertyType.string,
      stringValue: 'Roboto',
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    final calProp = item.properties[PropertyIdsGoogleCalendarWidget.calendarId];
    List<String> ids = [];
    if (calProp.type == ViewConfigPropertyType.rawBytes &&
        calProp.rawBytes != null &&
        calProp.rawBytes!.isNotEmpty) {
      try {
        ids = GoogleCaledarIds(calProp.rawBytes!).ids?.toList() ?? [];
      } catch (e) {
        debugPrint('Error parsing calendar IDs: $e');
      }
    } else {
      ids = [calProp.stringValue ?? 'primary'];
    }

    return _GoogleCalendarPanel(
      calendarIds: ids,
      fontSize:
          item.properties[PropertyIdsGoogleCalendarWidget.fontSize].intValue ??
          14,
      fontFamily:
          item
              .properties[PropertyIdsGoogleCalendarWidget.fontFamily]
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
    // REUSE the helper logic
    return promptGoogleCalendarProperties(
      context,
      calendarIdPropId: PropertyIdsGoogleCalendarWidget.calendarId,
      fontSizePropId: PropertyIdsGoogleCalendarWidget.fontSize,
      fontFamilyPropId: PropertyIdsGoogleCalendarWidget.fontFamily,
      initial: initial,
      onDelete: onDelete,
    );
  }
}
