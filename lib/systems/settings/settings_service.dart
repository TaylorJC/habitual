import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int? themeIndex = prefs.getInt('theme');

    if (themeIndex != null) {
      return ThemeMode.values[themeIndex];
    } else {
      if (ThemeMode.system == ThemeMode.dark) {
        return ThemeMode.dark;
      }
      return ThemeMode.light;
    }
    
  }

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<Color> themeColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();


    final String? colorA = prefs.getString('color_a');
    final String? colorR = prefs.getString('color_r');
    final String? colorB = prefs.getString('color_b');
    final String? colorG = prefs.getString('color_g');


    if (colorA == null || colorR == null || colorG == null || colorB == null) {
      return Colors.deepPurple;
    } else {
      return Color.from(alpha: double.parse(colorA), red: double.parse(colorR), green: double.parse(colorG), blue: double.parse(colorB));
    }
  }

  Future<String> themeColorName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? colorName = prefs.getString('color');

    if (colorName != null) {
      return colorName;
    } else {
      return 'Purple';
    }
  }

  Future<void> updateThemeColor(Color color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('color_a', color.a.toStringAsFixed(5));
    await prefs.setString('color_r', color.r.toStringAsFixed(5));
    await prefs.setString('color_b', color.b.toStringAsFixed(5));
    await prefs.setString('color_g', color.g.toStringAsFixed(5));

    await prefs.setString('color', color.toString());
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('theme', theme.index);
  }
}