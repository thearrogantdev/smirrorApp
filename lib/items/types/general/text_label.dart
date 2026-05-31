import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_wire/constants/widget_ids.dart';

class TextLabelWidgetType extends WidgetTypeDefinition {
  // A curated list of fonts that look good on a mirror
  static const List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Lato',
    'Orbitron', // Great for tech/digital look
    'Raleway',
    'Roboto Mono', // Monospace for data
    'Playfair Display', // Elegant Serif
    'Caveat', // Handwriting
  ];

  TextLabelWidgetType()
    : super(
        typeId: WidgetIds.textWidget,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameTextLabel,
        defaultSize: const Size(100, 40),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsTextWidget.text,
      type: ViewConfigPropertyType.string,
      stringValue: 'Label',
    ),
    ViewConfigProperty(
      key: PropertyIdsTextWidget.fontSize,
      type: ViewConfigPropertyType.int,
      intValue: 14,
    ),
    ViewConfigProperty(
      // Default Font
      key: PropertyIdsTextWidget.fontFamily,
      type: ViewConfigPropertyType.string,
      stringValue: 'Roboto',
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    final text = item.properties[PropertyIdsTextWidget.text].stringValue ?? '';
    final fontSize =
        item.properties[PropertyIdsTextWidget.fontSize].intValue ?? 14;
    final fontFamily =
        item.properties[PropertyIdsTextWidget.fontFamily].stringValue ??
        'Roboto';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.getFont(
        fontFamily,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize.toDouble(),
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
    final existingText =
        initial
            ?.firstWhere(
              (p) => p.key == PropertyIdsTextWidget.text,
              orElse: () => createDefaultProperties()[0],
            )
            .stringValue ??
        'Label';
    final existingSize =
        initial
            ?.firstWhere(
              (p) => p.key == PropertyIdsTextWidget.fontSize,
              orElse: () => createDefaultProperties()[1],
            )
            .intValue ??
        14;
    final existingFont =
        initial
            ?.firstWhere(
              (p) => p.key == PropertyIdsTextWidget.fontFamily,
              orElse: () => createDefaultProperties()[2],
            )
            .stringValue ??
        'Roboto';
    final loc = AppLocalizations.of(context)!;

    return showConfigDialog<List<ViewConfigProperty>>(
      context: context,
      title: loc.editTextLabelTitle,
      onDelete: onDelete,
      initialValues: {
        'k${PropertyIdsTextWidget.text}': existingText,
        'k${PropertyIdsTextWidget.fontSize}': existingSize.toString(),
        'k${PropertyIdsTextWidget.fontFamily}': existingFont,
      },
      buildForm: (ctx, formKey) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderTextField(
              name: 'k${PropertyIdsTextWidget.text}',
              decoration: InputDecoration(labelText: loc.textInput),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'k${PropertyIdsTextWidget.fontSize}',
                    decoration: InputDecoration(labelText: loc.fontSize),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.integer(),
                    ]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'k${PropertyIdsTextWidget.fontFamily}',
                    decoration: InputDecoration(labelText: loc.fontFamily),
                    items: _availableFonts
                        .map(
                          (font) => DropdownMenuItem(
                            value: font,
                            child: Text(
                              font,
                              style: GoogleFonts.getFont(font, fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      onSubmit: (values) {
        final text =
            (values['k${PropertyIdsTextWidget.text}'] as String?)?.trim() ??
            'Label';
        final size =
            int.tryParse(
              values['k${PropertyIdsTextWidget.fontSize}'].toString(),
            ) ??
            14;
        final font =
            values['k${PropertyIdsTextWidget.fontFamily}'] as String? ??
            'Roboto';

        return [
          ViewConfigProperty(
            key: PropertyIdsTextWidget.text,
            type: ViewConfigPropertyType.string,
            stringValue: text,
          ),
          ViewConfigProperty(
            key: PropertyIdsTextWidget.fontSize,
            type: ViewConfigPropertyType.int,
            intValue: size,
          ),
          ViewConfigProperty(
            key: PropertyIdsTextWidget.fontFamily,
            type: ViewConfigPropertyType.string,
            stringValue: font,
          ),
        ];
      },
    );
  }
}
