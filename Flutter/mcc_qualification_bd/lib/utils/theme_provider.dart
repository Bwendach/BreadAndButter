// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.system;

  ThemeModeOption get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    _themeMode = ThemeModeOption.values.firstWhere(
      (mode) => mode.toString().split('.').last == themeModeString,
      orElse: () => ThemeModeOption.system,
    );
    notifyListeners();
  }

  void setThemeMode(ThemeModeOption newMode) async {
    if (newMode == _themeMode) return;
    _themeMode = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode.toString().split('.').last);
    notifyListeners();
  }

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }
}
