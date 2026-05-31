import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:form_builder_validators/form_builder_validators.dart';

class ImageWidgetType extends WidgetTypeDefinition {
  ImageWidgetType()
    : super(
        typeId: WidgetIds.image,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameImage,
        defaultSize: const Size(200, 200),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: GeneralIds.binaryPath,
      type: ViewConfigPropertyType.string,
      stringValue: '',
    ),
    ViewConfigProperty(
      key: GeneralIds.binary,
      type: ViewConfigPropertyType.int,
      intValue: 0,
    ),
  ];

  @override
  Widget buildChild(ViewConfigItem item) {
    final path =
        item.properties
            .firstWhere((element) => element.key == GeneralIds.binaryPath)
            .stringValue ??
        '';
    if (path.isEmpty) {
      return const Placeholder();
    }
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.fill);
    }
    return Image.file(File(path), fit: BoxFit.fill);
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    final loc = AppLocalizations.of(context)!;
    final existingPath =
        initial
            ?.where((p) => p.key == GeneralIds.binaryPath)
            .firstOrNull
            ?.stringValue ??
        '';
    final existingID =
        initial
            ?.where((p) => p.key == GeneralIds.binary)
            .firstOrNull
            ?.intValue ??
        0;
    return showConfigDialog<List<ViewConfigProperty>>(
      context: context,
      title: loc.editImagePickPhotos,
      onDelete: onDelete,
      buildForm: (ctx, formKey) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderImagePicker(
              name: 'img',
              decoration: InputDecoration(labelText: loc.editImagePickPhotos),
              initialValue: [
                existingPath.isNotEmpty ? XFile(existingPath) : null,
              ],
              maxImages: 1,
              previewAutoSizeWidth: true,
              validator: FormBuilderValidators.required(),
            ),
          ],
        );
      },
      onSubmit: (values) async {
        final sel = (values['img'] as List?) ?? const [];
        final first = sel.first as XFile;
        return [
          ViewConfigProperty(
            key: GeneralIds.binaryPath,
            type: ViewConfigPropertyType.string,
            stringValue: first.path,
          ),
          ViewConfigProperty(
            key: GeneralIds.binary,
            type: ViewConfigPropertyType.int,
            intValue: existingID,
          ),
        ];
      },
    );
  }
}
