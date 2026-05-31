import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_app/items/general_text_diplay_widget_base.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_wire/constants/widget_ids.dart';

class RandomInsultWidgetType extends GeneralTextDisplayWidgetBase {
  RandomInsultWidgetType()
    : super(
        typeId: WidgetIds.randomInsult,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameRandomInsult,
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ...super.createDefaultProperties(),
    ViewConfigProperty(
      key: PropertyIdsRandomInsult.allow18Plus,
      type: ViewConfigPropertyType.bool,
      boolValue: false,
    ),
  ];

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    final loc = AppLocalizations.of(context)!;
    final propMap = {for (final p in initial ?? createDefaultProperties()) p.key: p};
    final currentLang =
        propMap[PropertyIdsGeneralTextDisplay.language]?.stringValue ?? 'en';
    final currentSize =
        propMap[PropertyIdsGeneralTextDisplay.fontSize]?.intValue ?? 14;
    final currentFont =
        propMap[PropertyIdsGeneralTextDisplay.fontFamily]?.stringValue ??
        'Roboto';
    final allow18Plus =
        propMap[PropertyIdsRandomInsult.allow18Plus]?.boolValue ?? false;

    return showConfigDialog<List<ViewConfigProperty>>(
      context: context,
      title: loc.editWidgetProperties,
      onDelete: onDelete,
      initialValues: {
        'lang': currentLang,
        'size': currentSize.toString(),
        'font': currentFont,
        'allow18Plus': allow18Plus,
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
            ),
            const SizedBox(height: 8),
            FormBuilderDropdown<String>(
              name: 'font',
              decoration: InputDecoration(labelText: loc.fontFamily),
              items: const [
                DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                DropdownMenuItem(value: 'Open Sans', child: Text('Open Sans')),
                DropdownMenuItem(value: 'Montserrat', child: Text('Montserrat')),
                DropdownMenuItem(value: 'Lato', child: Text('Lato')),
                DropdownMenuItem(value: 'Orbitron', child: Text('Orbitron')),
                DropdownMenuItem(value: 'Roboto Mono', child: Text('Roboto Mono')),
              ],
            ),
            const SizedBox(height: 12),
            FormBuilderCheckbox(
              name: 'allow18Plus',
              title: Text(loc.randomInsultAllow18Plus),
            ),
          ],
        );
      },
      onSubmit: (values) {
        return [
          ViewConfigProperty(
            key: PropertyIdsGeneralTextDisplay.language,
            type: ViewConfigPropertyType.string,
            stringValue: values['lang'] as String?,
          ),
          ViewConfigProperty(
            key: PropertyIdsGeneralTextDisplay.fontSize,
            type: ViewConfigPropertyType.int,
            intValue: int.tryParse(values['size'].toString()) ?? 14,
          ),
          ViewConfigProperty(
            key: PropertyIdsGeneralTextDisplay.fontFamily,
            type: ViewConfigPropertyType.string,
            stringValue: values['font'] as String?,
          ),
          ViewConfigProperty(
            key: PropertyIdsRandomInsult.allow18Plus,
            type: ViewConfigPropertyType.bool,
            boolValue: values['allow18Plus'] as bool? ?? false,
          ),
        ];
      },
    );
  }
}
