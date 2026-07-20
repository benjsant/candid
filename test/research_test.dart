/// Le grounding INSEE doit produire des faits lisibles quand le registre répond,
/// et une chaîne vide (jamais une invention) quand il ne répond rien. Tests avec
/// un adaptateur Dio simulé, pas de réseau.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:candid/agent/research.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);
  final int status;
  final String body;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(body, status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  void close({bool force = false}) {}
}

Dio _dio(int status, String body) =>
    Dio()..httpClientAdapter = _FakeAdapter(status, body);

void main() {
  test('un résultat du registre produit des faits lisibles', () async {
    final body = jsonEncode({
      'results': [
        {
          'nom_complet': 'CAPGEMINI',
          'categorie_entreprise': 'GE',
          'date_creation': '1984-09-19',
          'activite_principale': '70.10Z',
          'siege': {'libelle_commune': 'PARIS', 'code_postal': '75017'},
        },
      ],
    });
    final text = await companyRegistryGrounding('Capgemini', dio: _dio(200, body));
    expect(text, contains('CAPGEMINI'));
    expect(text, contains('grande entreprise'));
    expect(text, contains('PARIS (75017)'));
    expect(text, contains('1984'));
    expect(text, contains('registre des entreprises, INSEE'));
  });

  test('aucun résultat : chaîne vide (jamais d\'invention)', () async {
    final text = await companyRegistryGrounding('zzz',
        dio: _dio(200, jsonEncode({'results': []})));
    expect(text, isEmpty);
  });

  test('erreur réseau/HTTP : chaîne vide, pas d\'exception', () async {
    final text =
        await companyRegistryGrounding('x', dio: _dio(500, 'boom'));
    expect(text, isEmpty);
  });

  test('un nom d\'entreprise vide n\'interroge rien', () async {
    expect(await companyRegistryGrounding('   '), isEmpty);
  });

  test('un résultat réduit au seul nom est jugé trop maigre', () async {
    final body = jsonEncode({
      'results': [
        {'nom_complet': 'X'},
      ],
    });
    expect(await companyRegistryGrounding('X', dio: _dio(200, body)), isEmpty);
  });
}
