import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThemeModeStorage {
  const ThemeModeStorage();

  Future<ThemeMode?> readThemeMode() async {
    final file = await _getFile();
    if (!await file.exists()) return null;

    final raw = (await file.readAsString()).trim();
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    final file = await _getFile();
    await file.writeAsString(_serialize(mode));
  }

  String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'theme_mode.txt'));
  }
}
