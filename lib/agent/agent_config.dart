/// Réglages de l'agent : fournisseur actif, modèle, et plafond d'appels
/// quotidien. Persistés localement (pas des secrets, mais on réutilise le même
/// stockage sécurisé pour ne pas ajouter de dépendance).
///
/// Le plafond de coût est un garde-fou du projet : sur mobile, un bouton se
/// presse vite. Il est visible dans l'interface (« 3/5 aujourd'hui »), pas un
/// refus silencieux.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'llm.dart';

/// Plafond d'appels à l'agent par jour, par défaut. Un « appel agent » = un
/// passage complet du graphe (plusieurs requêtes LLM comptent pour un).
const kDefaultDailyCap = 5;

class AgentConfig {
  AgentConfig({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kProvider = 'agent_provider';
  static const _kModel = 'agent_model';
  static const _kCapDate = 'agent_cap_date';
  static const _kCapCount = 'agent_cap_count';

  /// Le fournisseur actif (DeepSeek par défaut).
  Future<LlmProvider> provider() async =>
      LlmProvider.fromId(await _storage.read(key: _kProvider));

  Future<void> setProvider(LlmProvider p) =>
      _storage.write(key: _kProvider, value: p.name);

  /// Le modèle choisi ('' = modèle par défaut du fournisseur).
  Future<String> model() async =>
      (await _storage.read(key: _kModel))?.trim() ?? '';

  Future<void> setModel(String model) =>
      _storage.write(key: _kModel, value: model.trim());

  // ── Plafond d'appels quotidien ────────────────────────────────────────────

  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  /// Nombre d'appels déjà consommés aujourd'hui (0 si on a changé de jour).
  Future<int> usedToday() async {
    final date = await _storage.read(key: _kCapDate);
    if (date != _today) return 0;
    return int.tryParse(await _storage.read(key: _kCapCount) ?? '0') ?? 0;
  }

  /// Reste-t-il un appel disponible aujourd'hui ?
  Future<bool> hasBudget({int cap = kDefaultDailyCap}) async =>
      (await usedToday()) < cap;

  /// Incrémente le compteur du jour (à appeler après un passage réussi).
  Future<void> recordCall() async {
    final used = await usedToday();
    await _storage.write(key: _kCapDate, value: _today);
    await _storage.write(key: _kCapCount, value: '${used + 1}');
  }
}
