import 'package:flutter/material.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

class SystemUpdatesCard extends StatelessWidget {
  const SystemUpdatesCard({
    super.key,
    required this.isChecking,
    required this.checked,
    required this.noNewUpdates,
    required this.currentFrontendVersion,
    required this.currentBackendVersion,
    required this.currentWebappVersion,
    required this.availableFrontendVersion,
    required this.availableBackendVersion,
    required this.availableWebappVersion,
    required this.isUpdatingFrontend,
    required this.isUpdatingBackend,
    required this.isUpdatingWebapp,
    required this.onCheckForUpdates,
    required this.onStartUpdate,
    required this.l10n,
  });

  final bool isChecking;
  final bool checked;
  final bool noNewUpdates;
  final String currentFrontendVersion;
  final String currentBackendVersion;
  final String currentWebappVersion;
  final String availableFrontendVersion;
  final String availableBackendVersion;
  final String availableWebappVersion;
  final bool isUpdatingFrontend;
  final bool isUpdatingBackend;
  final bool isUpdatingWebapp;
  final VoidCallback onCheckForUpdates;
  final VoidCallback onStartUpdate;
  final AppLocalizations l10n;

  Widget _buildUpdateStatusRow({
    required BuildContext context,
    required String title,
    required String currentVersion,
    required String newVersion,
    required bool isUpdating,
  }) {
    final theme = Theme.of(context);
    final hasUpdate = newVersion.isNotEmpty;
    final isReachable = currentVersion.isNotEmpty || title == l10n.adminWebappUpdate;
    final displayedVersion =
        currentVersion.isNotEmpty ? currentVersion : (title == l10n.adminWebappUpdate ? "-" : l10n.haUnreachable);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      l10n.setupVersion(displayedVersion),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    if (hasUpdate) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.trending_flat_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          newVersion,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ] else if (isReachable) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.adminNoUpdatesFound, // or "Up to date"
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasUpdate && isUpdating)
            SizedBox(
              width: 44,
              height: 44,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.adminUpdateSectionTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: isChecking ? null : onCheckForUpdates,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.adminCheckForUpdates),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildUpdateStatusRow(
                context: context,
                title: l10n.adminFrontendUpdate,
                currentVersion: currentFrontendVersion,
                newVersion: availableFrontendVersion,
                isUpdating: isUpdatingFrontend,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              _buildUpdateStatusRow(
                context: context,
                title: l10n.adminBackendUpdate,
                currentVersion: currentBackendVersion,
                newVersion: availableBackendVersion,
                isUpdating: isUpdatingBackend,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              _buildUpdateStatusRow(
                context: context,
                title: l10n.adminWebappUpdate,
                currentVersion: currentWebappVersion,
                newVersion: availableWebappVersion,
                isUpdating: isUpdatingWebapp,
              ),
              if (!checked || noNewUpdates) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.black.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          !checked
                              ? l10n.adminUpdatesNotChecked
                              : l10n.adminNoUpdatesFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (checked &&
                  (availableFrontendVersion.isNotEmpty ||
                      availableBackendVersion.isNotEmpty ||
                      availableWebappVersion.isNotEmpty)) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF6B4EFF), Color(0xFF8B75FF)],
                          ),
                    color: (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                        ? (isDark ? Colors.white12 : Colors.black12)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                        ? null
                        : onStartUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                        const SizedBox(width: 10),
                        Text(
                          (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                              ? "Updating System..."
                              : l10n.updateAll,
                          style: TextStyle(
                            color: (isUpdatingFrontend || isUpdatingBackend || isUpdatingWebapp)
                                ? (isDark ? Colors.white38 : Colors.black38)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
