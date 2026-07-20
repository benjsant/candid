/// Client LLM multi-fournisseurs, tous en HTTP compatible OpenAI.
///
/// DeepSeek par défaut (cœur du produit). OpenRouter en repli gratuit et
/// respectueux des données. Gemini en option, réservé au non-sensible. Le modèle
/// est configurable, jamais codé en dur (voir les réglages).
///
/// Conçu pour le cache de préfixe : le prompt système (gros, stable) est toujours
/// le premier message, dans le même ordre ; seul le message utilisateur varie
/// d'une offre à l'autre. Les fournisseurs facturent le préfixe stable au tarif
/// « cache hit », bien moins cher.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/secrets.dart';

/// Un fournisseur LLM et ses valeurs par défaut. `baseUrl` pointe vers un
/// endpoint compatible OpenAI (`/chat/completions`).
enum LlmProvider {
  deepseek(
    label: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com',
    defaultModel: 'deepseek-chat',
    keyName: SecretKey.deepseekApiKey,
  ),
  openrouter(
    label: 'OpenRouter',
    baseUrl: 'https://openrouter.ai/api/v1',
    defaultModel: 'deepseek/deepseek-chat',
    keyName: SecretKey.openrouterApiKey,
  ),
  gemini(
    label: 'Gemini',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
    defaultModel: 'gemini-2.0-flash',
    keyName: SecretKey.geminiApiKey,
  );

  const LlmProvider({
    required this.label,
    required this.baseUrl,
    required this.defaultModel,
    required this.keyName,
  });

  final String label;
  final String baseUrl;
  final String defaultModel;
  final SecretKey keyName;

  static LlmProvider fromId(String? id) => LlmProvider.values.firstWhere(
        (p) => p.name == id,
        orElse: () => LlmProvider.deepseek,
      );
}

/// Configuration résolue d'un appel : fournisseur, modèle, clé.
class LlmConfig {
  const LlmConfig({
    required this.provider,
    required this.apiKey,
    String? model,
  }) : model = model ?? '';

  final LlmProvider provider;
  final String apiKey;
  final String model;

  String get effectiveModel =>
      model.trim().isEmpty ? provider.defaultModel : model.trim();
}

/// Erreur d'appel LLM, avec un message lisible pour l'interface.
class LlmException implements Exception {
  LlmException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Client d'appel. Une seule opération : un prompt système + un message
/// utilisateur, en attendant un objet JSON en réponse.
class LlmClient {
  LlmClient(this.config, {Dio? dio}) : _dio = dio ?? Dio();

  final LlmConfig config;
  final Dio _dio;

  /// Un appel en mode JSON. Renvoie l'objet décodé.
  ///
  /// [systemPrompt] est le préfixe stable (cache) ; [userMessage] est la partie
  /// variable (l'offre). [temperature] : basse pour le scoring reproductible,
  /// plus haute pour l'accroche créative.
  Future<Map<String, dynamic>> completeJson({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.2,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw LlmException('Aucune clé pour ${config.provider.label}.');
    }
    final Response<dynamic> resp;
    try {
      resp = await _dio.post<dynamic>(
        '${config.provider.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          // On veut lire le corps même sur 4xx pour remonter le message d'erreur.
          validateStatus: (_) => true,
        ),
        data: {
          'model': config.effectiveModel,
          'temperature': temperature,
          'response_format': {'type': 'json_object'},
          'messages': [
            // Préfixe stable d'abord (cache), variable ensuite.
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
        },
      );
    } on DioException catch (e) {
      throw LlmException('Réseau : ${e.message ?? e.type.name}');
    }

    if (resp.statusCode == null || resp.statusCode! >= 400) {
      throw LlmException(
          '${config.provider.label} a répondu ${resp.statusCode} : '
          '${_errorText(resp.data)}');
    }

    final content = _extractContent(resp.data);
    if (content == null) {
      throw LlmException('Réponse ${config.provider.label} sans contenu.');
    }
    return _decodeJsonObject(content);
  }

  static String _errorText(Object? data) {
    if (data is Map && data['error'] is Map) {
      return (data['error']['message'] ?? data['error']).toString();
    }
    final s = data?.toString() ?? '';
    return s.length > 300 ? s.substring(0, 300) : s;
  }

  static String? _extractContent(Object? data) {
    if (data is! Map) return null;
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final message = (choices.first as Map?)?['message'];
    final content = (message as Map?)?['content'];
    return content?.toString();
  }

  /// Décode un objet JSON, en tolérant les clôtures markdown ```json … ```
  /// que certains modèles ajoutent malgré le mode JSON.
  static Map<String, dynamic> _decodeJsonObject(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text
          .replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic>
          ? decoded
          : (decoded is Map ? decoded.cast<String, dynamic>() : <String, dynamic>{});
    } catch (_) {
      throw LlmException('Réponse non-JSON du modèle.');
    }
  }
}

/// Résout la configuration active depuis les réglages : le fournisseur choisi,
/// son modèle, et sa clé. Renvoie null si la clé du fournisseur actif manque
/// (la fonctionnalité se désactive proprement, elle ne plante pas).
Future<LlmConfig?> resolveLlmConfig({
  required Secrets secrets,
  required LlmProvider provider,
  String? model,
}) async {
  final key = await secrets.read(provider.keyName);
  if (key == null) return null;
  return LlmConfig(provider: provider, apiKey: key, model: model);
}
