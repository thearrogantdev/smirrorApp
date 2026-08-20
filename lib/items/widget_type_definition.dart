import 'package:material_ui/material_ui.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

abstract class WidgetTypeDefinition {
  final int typeId;
  final String Function(BuildContext)? nameBuilder;
  final Size defaultSize;
  final bool isExperimental;

  const WidgetTypeDefinition({
    required this.typeId,
    required this.nameBuilder,
    required this.defaultSize,
    this.isExperimental = false,
  });

  /// Each widget defines its own property list (in correct key order)
  List<ViewConfigProperty> createDefaultProperties();

  /// The token ID required by this widget, if any.
  String? get requiredTokenId => null;

  /// Builds the inner child widget (not the draggable wrapper)
  Widget buildChild(ViewConfigItem item);

  /// Whether this widget is resizable on the canvas.
  bool get isResizable => true;

  /// Gets the size of this widget. By default, returns the size stored in the item.
  Size getSize(ViewConfigItem item) => item.size;

  String nameOf(BuildContext context) =>
      nameBuilder?.call(context) ?? "Not implemented";

  /// Optional dialog shown when widget is added to the canvas or long-clicked.
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    if (onDelete != null || initial != null) {
      return promptParameterlessProperties(
        context,
        initial: initial,
        onDelete: onDelete,
      );
    }
    return Future.value(createDefaultProperties());
  }

  /// Dialog shown for widgets with no configurable parameters when long-clicked.
  Future<List<ViewConfigProperty>?> promptParameterlessProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    final loc = AppLocalizations.of(context)!;
    return showConfigDialog<List<ViewConfigProperty>>(
      context: context,
      title: nameOf(context),
      onDelete: onDelete,
      buildForm: (ctx, formKey) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            loc.noWidgetParameters,
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
        );
      },
      onSubmit: (values) => createDefaultProperties(),
    );
  }
}
