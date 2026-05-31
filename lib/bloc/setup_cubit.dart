import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool developerMode;
  final bool emulateHomeAssistant;
  final bool developerLogs;

  const SetupState({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('en'),
    this.developerMode = false,
    this.emulateHomeAssistant = false,
    this.developerLogs = false,
  });

  SetupState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? developerMode,
    bool? emulateHomeAssistant,
    bool? developerLogs,
  }) {
    return SetupState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      developerMode: developerMode ?? this.developerMode,
      emulateHomeAssistant: emulateHomeAssistant ?? this.emulateHomeAssistant,
      developerLogs: developerLogs ?? this.developerLogs,
    );
  }
}

class SetupCubit extends Cubit<SetupState> {
  SetupCubit() : super(const SetupState()) {
    _loadPreferences();
  }

  static const _themeKey = 'themeMode';
  static const _languageKey = 'languageCode';
  static const _developerModeKey = 'developerMode';
  static const _emulateHAKey = 'emulateHomeAssistant';
  static const _developerLogsKey = 'developerLogs';

  // Exposed for UI
  static const supportedLanguages = {'en': 'English', 'de': 'Deutsch'};

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    final themeMode = ThemeMode.values[themeIndex];

    // Load saved language or system language
    String? languageCode = prefs.getString(_languageKey);
    languageCode ??= PlatformDispatcher.instance.locale.languageCode;

    // Validate language
    if (!supportedLanguages.keys.contains(languageCode)) {
      languageCode = 'en';
    }

    // Load expert mode
    final developerMode = prefs.getBool(_developerModeKey) ?? false;
    final emulateHA = prefs.getBool(_emulateHAKey) ?? false;
    final developerLogs = prefs.getBool(_developerLogsKey) ?? false;

    emit(
      SetupState(
        themeMode: themeMode,
        locale: Locale(languageCode),
        developerMode: developerMode,
        emulateHomeAssistant: emulateHA,
        developerLogs: developerLogs,
      ),
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setTheme(newMode);
  }

  Future<void> setLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> toggleDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.developerMode;
    await prefs.setBool(_developerModeKey, newValue);
    emit(state.copyWith(developerMode: newValue));
  }

  Future<void> toggleEmulateHomeAssistant() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.emulateHomeAssistant;
    await prefs.setBool(_emulateHAKey, newValue);
    emit(state.copyWith(emulateHomeAssistant: newValue));
  }

  Future<void> toggleDeveloperLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.developerLogs;
    await prefs.setBool(_developerLogsKey, newValue);
    emit(state.copyWith(developerLogs: newValue));
  }
}
