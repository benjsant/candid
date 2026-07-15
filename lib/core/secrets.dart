/// Stockage des clés API dans le Keystore Android (`flutter_secure_storage`).
///
/// RÈGLE NON NÉGOCIABLE : aucune clé n'est écrite en dur dans le code ni dans
/// les assets. Tout ce qui est compilé dans un APK est extractible en quelques
/// minutes. L'utilisateur saisit ses clés lui-même, dans l'écran de réglages.
///
/// Une clé absente ne fait pas planter l'application : la fonctionnalité
/// concernée se désactive, et l'interface le dit clairement.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Les secrets attendus par l'application, et ce qu'ils débloquent.
enum SecretKey {
  deepseekApiKey('deepseek_api_key', 'Clé DeepSeek',
      'Sans elle, pas de scoring fin, pas de lettre, pas de CV personnalisé.'),
  franceTravailClientId('ft_client_id', 'France Travail : client id',
      'Sans elle, la collecte automatique France Travail est désactivée.'),
  franceTravailClientSecret('ft_client_secret', 'France Travail : client secret',
      'Sans elle, la collecte automatique France Travail est désactivée.'),
  lbaApiKey('lba_api_key', 'Clé La Bonne Alternance',
      'Sans elle, la collecte La Bonne Alternance est désactivée.');

  const SecretKey(this.storageKey, this.label, this.consequence);

  final String storageKey;
  final String label;

  /// Ce qui ne marchera pas si la clé manque. Affiché dans les réglages.
  final String consequence;
}

class Secrets {
  Secrets({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(SecretKey key) async {
    final value = await _storage.read(key: key.storageKey);
    // Une chaîne vide vaut absence : évite un « Bearer  » envoyé à l'API.
    return (value == null || value.trim().isEmpty) ? null : value.trim();
  }

  Future<void> write(SecretKey key, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await _storage.delete(key: key.storageKey);
      return;
    }
    await _storage.write(key: key.storageKey, value: trimmed);
  }

  Future<void> delete(SecretKey key) => _storage.delete(key: key.storageKey);

  Future<bool> has(SecretKey key) async => (await read(key)) != null;

  /// L'agent DeepSeek est le cœur du produit : sans sa clé, l'application se
  /// réduit à une liste d'offres.
  Future<bool> get canRunAgent => has(SecretKey.deepseekApiKey);

  /// La collecte France Travail exige les deux moitiés de l'identifiant OAuth.
  Future<bool> get canCollectFranceTravail async =>
      await has(SecretKey.franceTravailClientId) &&
      await has(SecretKey.franceTravailClientSecret);

  Future<bool> get canCollectLba => has(SecretKey.lbaApiKey);
}
