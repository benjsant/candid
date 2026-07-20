/// Préférences d'apparence de l'application (non secrètes). On réutilise le même
/// stockage local que le reste, pour ne pas ajouter de dépendance.
///
/// Par défaut, l'application suit le thème du système (`ThemeMode.system`).
/// L'utilisateur peut forcer Clair ou Sombre depuis les réglages.
library;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPrefs {
  AppPrefs({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _kTheme = 'theme_mode';

  Future<ThemeMode> themeMode() async {
    switch (await _storage.read(key: _kTheme)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _storage.write(key: _kTheme, value: mode.name);
}
