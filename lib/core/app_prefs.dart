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

  static const _kDailyCollect = 'daily_collect';

  /// Collecte quotidienne en arrière-plan. **Désactivée par défaut** : elle
  /// consomme de la batterie et du réseau sans que l'utilisateur l'ait demandé,
  /// et sur beaucoup d'appareils elle ne partira pas de toute façon. C'est un
  /// choix explicite, pas un réglage qu'on impose.
  Future<bool> dailyCollect() async =>
      (await _storage.read(key: _kDailyCollect)) == 'true';

  Future<void> setDailyCollect(bool enabled) =>
      _storage.write(key: _kDailyCollect, value: enabled.toString());

  static const _kWeeklyDigest = 'weekly_digest';

  /// Digest hebdomadaire. Désactivé par défaut, comme la collecte : c'est une
  /// notification de plus, elle doit être voulue.
  Future<bool> weeklyDigest() async =>
      (await _storage.read(key: _kWeeklyDigest)) == 'true';

  Future<void> setWeeklyDigest(bool enabled) =>
      _storage.write(key: _kWeeklyDigest, value: enabled.toString());
}
