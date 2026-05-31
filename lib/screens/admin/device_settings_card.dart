import 'package:flutter/material.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

class DeviceSettingsCard extends StatelessWidget {
  const DeviceSettingsCard({
    super.key,
    required this.deviceNameController,
    required this.autoSwitch,
    required this.onAutoSwitchChanged,
    required this.onSubmit,
    required this.l10n,
  });

  final TextEditingController deviceNameController;
  final bool autoSwitch;
  final ValueChanged<bool> onAutoSwitchChanged;
  final VoidCallback onSubmit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.adminDeviceSettingsTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: deviceNameController,
              decoration: InputDecoration(
                labelText: l10n.adminDeviceName,
                prefixIcon: const Icon(Icons.badge_outlined),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.adminAutoSwitch),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.adminAutoSwitchTooltip,
                    triggerMode: TooltipTriggerMode.tap,
                    child: const Icon(Icons.help_outline, size: 20),
                  ),
                ],
              ),
              subtitle: Text(
                l10n.homeAutoSwitch,
                style: theme.textTheme.labelSmall,
              ),
              value: autoSwitch,
              onChanged: onAutoSwitchChanged,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.check),
                label: Text(l10n.adminApplySettings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
