import 'package:flutter/material.dart';
import 'package:mobile_orvexis/config/theme/theme_mode_storage.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({ThemeModeStorage? storage}) : _storage = storage ?? const ThemeModeStorage();

  final ThemeModeStorage _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadSavedThemeMode() async {
    final savedMode = await _storage.readThemeMode();
    if (savedMode == null) return;

    _themeMode = savedMode;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _storage.writeThemeMode(mode);
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _storage.writeThemeMode(_themeMode);
    notifyListeners();
  }
}
