import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_models.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/database/home_dashboard.dart';
import 'package:smirror_app/screens/home_assistant/picker_helpers.dart';

class ItemConfigDialog extends StatefulWidget {
  final HAEntityState entity;
  final Offset position;
  final DashboardItem? existingItem;

  const ItemConfigDialog({
    super.key,
    required this.entity,
    required this.position,
    this.existingItem,
  });

  @override
  State<ItemConfigDialog> createState() => _ItemConfigDialogState();
}

class _ItemConfigDialogState extends State<ItemConfigDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  late DashboardItemType type;

  // Track dynamic thresholds locally before saving to ObjectBox
  final List<Map<String, dynamic>> _thresholds = [];

  Map<String, dynamic> _initialValues = {};

  @override
  void initState() {
    super.initState();
    // 1. Determine Type
    type = widget.existingItem?.type ?? _determineType(widget.entity.entityId);

    // 2. Set Basic Initial Values
    _initialValues = {
      'displayName':
          widget.existingItem?.displayName ??
          widget.entity.attributes['friendly_name'] ??
          widget.entity.entityId,
      'stdIcon':
          widget.existingItem?.standardIconCodePoint ??
          Icons.help_outline.codePoint,
      'stdColor':
          widget.existingItem?.standardColorValue ?? Colors.grey.toARGB32(),
      'unitOverride': widget.existingItem?.unitOverride,
    };

    // 3. Load Thresholds
    if (widget.existingItem != null &&
        widget.existingItem!.thresholds.isNotEmpty) {
      // EDIT MODE: Load from DB
      for (var t in widget.existingItem!.thresholds) {
        final uniqueId = t.id == 0
            ? DateTime.now().microsecondsSinceEpoch + _thresholds.length
            : t.id;

        _thresholds.add({
          'id': uniqueId,
          'value': t.triggerValue,
          'icon': t.iconCodePoint,
          'color': t.colorValue,
        });

        // Add to form initial values so the text fields are filled
        _initialValues['t_val_$uniqueId'] = t.triggerValue.toString();
        _initialValues['t_icon_$uniqueId'] = t.iconCodePoint;
        _initialValues['t_color_$uniqueId'] = t.colorValue;
      }
    } else if (type == DashboardItemType.boolean) {
      // NEW BOOLEAN: Add default "On" state
      _addThreshold(
        initialValue: 1.0,
        icon: Icons.lightbulb,
        color: Colors.yellow,
      );
    }
  }

  DashboardItemType _determineType(String entityId) {
    if (entityId.startsWith('light.') ||
        entityId.startsWith('switch.') ||
        entityId.startsWith('binary_sensor.') ||
        entityId.startsWith('lock.')) {
      return DashboardItemType.boolean;
    }
    return DashboardItemType.numeric;
  }

  void _addThreshold({
    double initialValue = 0.0,
    IconData? icon,
    Color? color,
  }) {
    setState(() {
      _thresholds.add({
        'id': DateTime.now().millisecondsSinceEpoch, // Unique ID for form keys
        'value': initialValue,
        'icon': (icon ?? Icons.star).codePoint,
        'color': (color ?? Colors.blue).toARGB32(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tune, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(loc.haConfigEntityTitle(widget.entity.entityId))),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValues,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display Name Section
                _buildSectionHeader(context, loc.haConfigDisplayName, Icons.label_outline),
                FormBuilderTextField(
                  name: 'displayName',
                  decoration: InputDecoration(
                    hintText: loc.haConfigDisplayName,
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 24),

                // Standard Style Section
                _buildSectionHeader(context, loc.haConfigStandardStyle, Icons.palette_outlined),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildIconPickerField('stdIcon', colorFieldName: 'stdColor'),
                      const Divider(height: 24, indent: 8, endIndent: 8),
                      _buildColorPickerField('stdColor'),
                    ],
                  ),
                ),

                if (type != DashboardItemType.string) ...[
                  const SizedBox(height: 24),
                  // Thresholds Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(
                        context,
                        type == DashboardItemType.boolean ? "Active Style (On)" : "Thresholds",
                        type == DashboardItemType.boolean ? Icons.toggle_on_outlined : Icons.layers_outlined,
                      ),
                      if (type == DashboardItemType.numeric)
                        IconButton.filledTonal(
                          onPressed: () => _addThreshold(),
                          icon: const Icon(Icons.add),
                        ),
                    ],
                  ),
                  ..._thresholds.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tId = entry.value['id'];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (type == DashboardItemType.numeric)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FormBuilderTextField(
                                        name: 't_val_$tId',
                                        initialValue: entry.value['value'].toString(),
                                        decoration: InputDecoration(
                                          labelText: loc.haConfigTriggerValue,
                                          prefixIcon: const Icon(Icons.speed),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                          FormBuilderValidators.numeric(),
                                        ]),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: theme.colorScheme.error,
                                      onPressed: () => setState(() => _thresholds.removeAt(idx)),
                                    ),
                                  ],
                                ),
                              ),
                            _buildIconPickerField('t_icon_$tId', colorFieldName: 't_color_$tId', initialValue: entry.value['icon']),
                            const Divider(height: 24, indent: 8, endIndent: 8),
                            _buildColorPickerField('t_color_$tId', initialValue: entry.value['color']),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (widget.existingItem != null)
          TextButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: Text(
              AppLocalizations.of(context)!.haDeleteSymbol,
              style: const TextStyle(color: Colors.red),
            ),
          )
        else
          const SizedBox.shrink(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save_outlined),
              label: Text(loc.save),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.haDeleteSymbol),
        content: Text(loc.haDeleteSymbolConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close confirmation
              Navigator.pop(
                context,
                'delete',
              ); // Close config dialog with delete signal
            },
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPickerField(String name, {required String colorFieldName, int? initialValue}) {
    return FormBuilderField<int>(
      name: name,
      initialValue: initialValue,
      builder: (FormFieldState<int?> field) {
        final colorValue = _formKey.currentState?.fields[colorFieldName]?.value as int?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text("Icon", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
            ),
            IconPickerRow(
              selectedIcon: field.value ?? Icons.help_outline.codePoint,
              selectedColor: colorValue,
              onSelected: (val) => field.didChange(val),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildColorPickerField(String name, {int? initialValue}) {
    return FormBuilderField<int>(
      name: name,
      initialValue: initialValue,
      builder: (FormFieldState<int?> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text("Color", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
            ),
            ColorPickerRow(
              selectedColor: field.value ?? Colors.grey.toARGB32(),
              onSelected: (val) => field.didChange(val),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  void _onSave() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      // Use the existing item if we have one, otherwise create a new one
      final item =
          widget.existingItem ??
          DashboardItem(
            dbType: type.index,
            entityId: widget.entity.entityId,
            displayName: values['displayName'],
            x: widget.position.dx,
            y: widget.position.dy,
            standardIconCodePoint: values['stdIcon'],
            standardColorValue: values['stdColor'],
          );

      // If it's an existing item, we update its fields manually
      // The 'id' and 'dashboard' relation stay exactly as they were
      if (widget.existingItem != null) {
        item.displayName = values['displayName'];
        item.standardIconCodePoint = values['stdIcon'];
        item.standardColorValue = values['stdColor'];
        item.unitOverride = values['unitOverride'];
      }

      // Handle Thresholds: Clear old ones and add new ones from form
      item.thresholds.clear();
      for (var tData in _thresholds) {
        final tId = tData['id'];
        item.thresholds.add(
          ThresholdConfig(
            triggerValue:
                double.tryParse(values['t_val_$tId'].toString()) ?? 0.0,
            iconCodePoint: values['t_icon_$tId'],
            colorValue: values['t_color_$tId'],
          ),
        );
      }

      Navigator.pop(context, item);
    }
  }
}
