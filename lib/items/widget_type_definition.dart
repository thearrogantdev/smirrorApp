import 'package:flutter/material.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';

abstract class WidgetTypeDefinition {
  final int typeId;
  final String Function(BuildContext)? nameBuilder;
  final Size defaultSize;

  const WidgetTypeDefinition({
    required this.typeId,
    required this.nameBuilder,
    required this.defaultSize,
  });

  /// Each widget defines its own property list (in correct key order)
  List<ViewConfigProperty> createDefaultProperties();

  /// The token ID required by this widget, if any.
  String? get requiredTokenId => null;

  /// Builds the inner child widget (not the draggable wrapper)
  Widget buildChild(ViewConfigItem item);

  String nameOf(BuildContext context) =>
      nameBuilder?.call(context) ?? "Not implemented";

  /// Optional dialog shown when widget is added to the canvas
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) => Future.value(createDefaultProperties());
}
