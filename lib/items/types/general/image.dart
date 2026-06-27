import 'dart:io' show File;
import 'dart:convert' show base64Decode;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:get_it/get_it.dart';
import 'package:smirror_app/database/binary_database.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:image_picker/image_picker.dart';
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
    final binaryId =
        item.properties
            .where((p) => p.key == GeneralIds.binary)
            .firstOrNull
            ?.intValue ??
        0;

    if (binaryId != 0) {
      return StreamBuilder<String?>(
        stream: GetIt.I<BinaryDatabase>().watchBinaryPath(binaryId),
        builder: (context, snapshot) {
          final resolvedPath = snapshot.data;
          if (resolvedPath != null && resolvedPath.isNotEmpty) {
            if (resolvedPath.startsWith('data:')) {
              try {
                final commaIndex = resolvedPath.indexOf(',');
                if (commaIndex != -1) {
                  final base64Data = resolvedPath.substring(commaIndex + 1);
                  final bytes = base64Decode(base64Data);
                  return Image.memory(bytes, fit: BoxFit.fill);
                }
              } catch (_) {}
            }
            if (kIsWeb) {
              return Image.network(resolvedPath, fit: BoxFit.fill);
            }
            return Image.file(File(resolvedPath), fit: BoxFit.fill);
          }
          // Fallback if not resolved in DB yet
          final fallbackPath =
              item.properties
                  .firstWhere((element) => element.key == GeneralIds.binaryPath)
                  .stringValue ??
              '';
          if (fallbackPath.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fallbackPath.startsWith('data:')) {
            try {
              final commaIndex = fallbackPath.indexOf(',');
              if (commaIndex != -1) {
                final base64Data = fallbackPath.substring(commaIndex + 1);
                final bytes = base64Decode(base64Data);
                return Image.memory(bytes, fit: BoxFit.fill);
              }
            } catch (_) {}
          }
          if (kIsWeb) {
            return Image.network(
              fallbackPath,
              fit: BoxFit.fill,
              errorBuilder: (ctx, err, stack) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }
          return Image.file(
            File(fallbackPath),
            fit: BoxFit.fill,
            errorBuilder: (ctx, err, stack) =>
                const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final path =
        item.properties
            .firstWhere((element) => element.key == GeneralIds.binaryPath)
            .stringValue ??
        '';
    if (path.isEmpty) {
      return const Placeholder();
    }
    if (path.startsWith('data:')) {
      try {
        final commaIndex = path.indexOf(',');
        if (commaIndex != -1) {
          final base64Data = path.substring(commaIndex + 1);
          final bytes = base64Decode(base64Data);
          return Image.memory(bytes, fit: BoxFit.fill);
        }
      } catch (_) {
        // fallback
      }
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
        final isPhone = !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.android);
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
              availableImageSources: isPhone
                  ? const [ImageSourceOption.camera, ImageSourceOption.gallery]
                  : const [ImageSourceOption.gallery],
              onTap: isPhone
                  ? null
                  : (_) async {
                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        formKey.currentState?.fields['img']?.didChange([pickedFile]);
                      }
                    },
            ),
          ],
        );
      },
      onSubmit: (values) async {
        final sel = (values['img'] as List?) ?? const [];
        final first = sel.first as XFile;
        final isNew = first.path != existingPath;
        return [
          ViewConfigProperty(
            key: GeneralIds.binaryPath,
            type: ViewConfigPropertyType.string,
            stringValue: first.path,
          ),
          ViewConfigProperty(
            key: GeneralIds.binary,
            type: ViewConfigPropertyType.int,
            intValue: isNew ? 0 : existingID,
          ),
        ];
      },
    );
  }
}
