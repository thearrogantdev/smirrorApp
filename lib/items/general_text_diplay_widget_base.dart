import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_wire/constants/widget_ids.dart';

abstract class GeneralTextDisplayWidgetBase extends WidgetTypeDefinition {
  static const List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Lato',
    'Orbitron',
    'Roboto Mono',
  ];

  GeneralTextDisplayWidgetBase({
    required super.typeId,
    required super.nameBuilder,
    super.defaultSize = const Size(150, 60),
  });

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsGeneralTextDisplay.language,
      type: ViewConfigPropertyType.string,
      stringValue: 'en',
    ),
    ViewConfigProperty(
      key: PropertyIdsGeneralTextDisplay.fontSize,
      type: ViewConfigPropertyType.int,
      intValue: 14,
    ),
    ViewConfigProperty(
      key: PropertyIdsGeneralTextDisplay.fontFamily,
      type: ViewConfigPropertyType.string,
      stringValue: 'Roboto',
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    final fontSize =
        item.properties[PropertyIdsGeneralTextDisplay.fontSize].intValue ?? 14;
    final fontFamily =
        item.properties[PropertyIdsGeneralTextDisplay.fontFamily].stringValue ??
        'Roboto';

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Builder(
        builder: (context) {
          final String displayName =
              nameBuilder?.call(context) ?? "Placeholder";
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                fontFamily,
                fontSize: fontSize.toDouble(),
                color: Colors
                    .white70, // Slightly dimmed to indicate it's a preview
              ),
            ),
          );
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
    final loc = AppLocalizations.of(context)!;

    // Get existing values or defaults
    final propMap = {for (var p in initial ?? []) p.key: p};
    final currentLang =
        propMap[PropertyIdsGeneralTextDisplay.language]?.stringValue ?? 'en';
    final currentSize =
        propMap[PropertyIdsGeneralTextDisplay.fontSize]?.intValue ?? 14;
    final currentFont =
        propMap[PropertyIdsGeneralTextDisplay.fontFamily]?.stringValue ??
        'Roboto';

    return showConfigDialog<List<ViewConfigProperty>>(
      context: context,
      title: loc.editWidgetProperties, // Adjust to your loc key
      onDelete: onDelete,
      initialValues: {
        'lang': currentLang,
        'size': currentSize.toString(),
        'font': currentFont,
      },
      buildForm: (ctx, formKey) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderDropdown<String>(
              name: 'lang',
              decoration: InputDecoration(labelText: loc.language),
              items: [
                DropdownMenuItem(value: 'en', child: Text(loc.languageEnglish)),
                DropdownMenuItem(value: 'de', child: Text(loc.languageGerman)),
              ],
            ),
            const SizedBox(height: 8),
            FormBuilderTextField(
              name: 'size',
              decoration: InputDecoration(labelText: loc.fontSize),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.integer(),
            ),
            const SizedBox(height: 8),
            FormBuilderDropdown<String>(
              name: 'font',
              decoration: InputDecoration(labelText: loc.fontFamily),
              items: _availableFonts
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(
                        f,
                        style: GoogleFonts.getFont(f, fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
      onSubmit: (values) {
        return [
          ViewConfigProperty(
            key: PropertyIdsGeneralTextDisplay.language,
            type: ViewConfigPropertyType.string,
            stringValue: values['lang'],
          ),
          ViewConfigProperty(
            key: PropertyIdsGeneralTextDisplay.fontSize,
            type: ViewConfigPropertyType.int,
            intValue: int.tryParse(values['size'].toString()) ?? 14,
          ),
          ViewConfigProperty(
            key: PropertyIdsGeneralTextDisplay.fontFamily,
            type: ViewConfigPropertyType.string,
            stringValue: values['font'],
          ),
        ];
      },
    );
  }
}
