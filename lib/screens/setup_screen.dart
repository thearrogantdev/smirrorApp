import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/database/view_store.dart';
import 'package:smirror_app/database/home_assistant_store.dart';
import 'package:smirror_app/services/path_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/bloc/setup_cubit.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:restart_app/restart_app.dart';
import 'package:package_info_plus/package_info_plus.dart';

@RoutePage()
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<DateTime> _versionTaps = [];
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    }
  }

  void _onVersionTap() {
    final now = DateTime.now();
    _versionTaps.add(now);

    // Keep only taps within the last 3 seconds
    _versionTaps.removeWhere(
      (tap) => now.difference(tap).inMilliseconds > 3000,
    );

    if (_versionTaps.length >= 5) {
      _versionTaps.clear();
      final setupCubit = context.read<SetupCubit>();
      final loc = AppLocalizations.of(context)!;
      // Read the message before toggling – current state is the OLD value,
      // so !developerMode tells us what the NEW value will be.
      final message = !setupCubit.state.developerMode
          ? loc.developerModeEnabled
          : loc.developerModeDisabled;
      setupCubit.toggleDeveloperMode();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> _performFactoryReset(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.setupFactoryResetConfirmTitle),
        content: Text(loc.setupFactoryResetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.setupFactoryReset),
          ),
        ],
      ),
    );

    if (confirm == true) {
      GetIt.I<ViewStore>().dispose();
      GetIt.I<HomeAssistantStore>().dispose();

      final String directory = await GetIt.I<PathService>().getRootDir();
      final vsDir = Directory('$directory/objectbox_vs');
      if (vsDir.existsSync()) {
        vsDir.deleteSync(recursive: true);
      }
      final haDir = Directory('$directory/objectbox_ha');
      if (haDir.existsSync()) {
        haDir.deleteSync(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      try {
        await const FlutterSecureStorage().deleteAll();
      } catch (e) {
        if (kDebugMode) {
          print('Factory reset secure storage clear failed (normal for web/http): $e');
        }
      }

      Restart.restartApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupCubit = context.read<SetupCubit>();
    final setupState = context.watch<SetupCubit>().state;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.setup)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    loc.setupAppearance,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: Text(loc.themeMode),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ThemeMode>(
                              value: setupState.themeMode,
                              icon: const Icon(Icons.expand_more, size: 20),
                              isDense: true,
                              borderRadius: BorderRadius.circular(16),
                              onChanged: (mode) {
                                if (mode != null) setupCubit.setTheme(mode);
                              },
                              items: [
                                DropdownMenuItem(
                                  value: ThemeMode.light,
                                  child: Text(loc.setupThemeLight),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.dark,
                                  child: Text(loc.setupThemeDark),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.system,
                                  child: Text(loc.setupThemeSystem),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    loc.setupSystem,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: Text(loc.language),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Locale>(
                              value: setupState.locale,
                              icon: const Icon(Icons.expand_more, size: 20),
                              isDense: true,
                              borderRadius: BorderRadius.circular(16),
                              onChanged: (locale) {
                                if (locale != null) {
                                  setupCubit.setLanguage(locale);
                                }
                              },
                              items: SetupCubit.supportedLanguages.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: Locale(entry.key),
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (setupState.developerMode) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
                    child: Text(
                      loc.developerMode,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.home_outlined),
                          title: Text(loc.emulateHomeAssistant),
                          value: setupState.emulateHomeAssistant,
                          onChanged: (_) =>
                              setupCubit.toggleEmulateHomeAssistant(),
                        ),
                      ],
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
                  child: Text(
                    loc.setupDangerZone,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          loc.setupFactoryReset,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () => _performFactoryReset(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Version pinned to the very bottom of the screen
          GestureDetector(
            onTap: _onVersionTap,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Center(
                child: Text(
                  loc.setupVersion(_appVersion),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
