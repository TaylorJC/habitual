import 'package:flutter/material.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late Color _themeColor;
  late String _themeColorName;

  ThemeMode get themeMode => _themeMode;
  Color get themeColor => _themeColor;
  String get themeColorName => _themeColorName;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _themeColor = await _settingsService.themeColor();
    _themeColorName = await _settingsService.themeColorName();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

    /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeColor(Color? newColor) async {
    if (newColor == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newColor == _themeColor) return;

    // Otherwise, store the new ThemeMode in memory
    _themeColor = newColor;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeColor(newColor);
  }
}