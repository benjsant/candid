/// Le client LLM parle à des endpoints compatibles OpenAI. Ces tests utilisent
/// un adaptateur Dio simulé : ils vérifient l'extraction du contenu, la
/// tolérance aux clôtures markdown, et la remontée d'erreur lisible, sans réseau.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:candid/agent/llm.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adaptateur qui renvoie une réponse figée et capture la requête envoyée.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);
  final int status;
  final String body;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    captured = options;
    return ResponseBody.fromString(body, status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
  }

  @override
  void close({bool force = false}) {}
}

LlmClient _client(_FakeAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return LlmClient(
    const LlmConfig(provider: LlmProvider.deepseek, apiKey: 'sk-test'),
    dio: dio,
  );
}

String _chat(String content) => jsonEncode({
      'choices': [
        {
          'message': {'content': content},
        },
      ],
    });

void main() {
  test('extrait et décode le contenu JSON de la réponse', () async {
    final adapter = _FakeAdapter(200, _chat('{"score": 82, "langue": "fr"}'));
    final data = await _client(adapter).completeJson(
      systemPrompt: 'SYS',
      userMessage: 'USER',
    );
    expect(data['score'], 82);
    expect(data['langue'], 'fr');
  });

  test('le prompt système est le premier message (cache de préfixe)', () async {
    final adapter = _FakeAdapter(200, _chat('{}'));
    await _client(adapter)
        .completeJson(systemPrompt: 'STABLE', userMessage: 'VARIABLE');
    final sent = adapter.captured!.data as Map;
    final messages = sent['messages'] as List;
    expect(messages.first['role'], 'system');
    expect(messages.first['content'], 'STABLE');
    expect(messages.last['content'], 'VARIABLE');
  });

  test('tolère une réponse encadrée par des clôtures markdown', () async {
    final adapter = _FakeAdapter(200, _chat('```json\n{"score": 5}\n```'));
    final data = await _client(adapter)
        .completeJson(systemPrompt: 's', userMessage: 'u');
    expect(data['score'], 5);
  });

  test('une erreur HTTP remonte un message lisible', () async {
    final adapter = _FakeAdapter(
        401, jsonEncode({'error': {'message': 'Invalid API key'}}));
    expect(
      () => _client(adapter).completeJson(systemPrompt: 's', userMessage: 'u'),
      throwsA(isA<LlmException>()
          .having((e) => e.message, 'message', contains('Invalid API key'))),
    );
  });

  test('une clé vide échoue proprement, sans appel', () async {
    final client = LlmClient(
      const LlmConfig(provider: LlmProvider.deepseek, apiKey: ''),
    );
    expect(
      () => client.completeJson(systemPrompt: 's', userMessage: 'u'),
      throwsA(isA<LlmException>()),
    );
  });

  test('le modèle par défaut du fournisseur s\'applique si non précisé', () {
    const c = LlmConfig(provider: LlmProvider.deepseek, apiKey: 'k');
    expect(c.effectiveModel, 'deepseek-chat');
    const c2 =
        LlmConfig(provider: LlmProvider.openrouter, apiKey: 'k', model: 'x/y');
    expect(c2.effectiveModel, 'x/y');
  });
}
