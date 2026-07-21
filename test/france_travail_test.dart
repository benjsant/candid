/// Tests du client France Travail sur un `Dio` simulé : aucun appel réseau, et
/// donc aucune clé nécessaire. On vérifie surtout les comportements que le
/// projet Docker a appris à ses dépens : cache du jeton, dégradation propre.
library;

import 'package:candid/core/secrets.dart';
import 'package:candid/sources/france_travail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Intercepteur qui répond à la place du réseau et compte les appels.
class _FakeTransport extends Interceptor {
  _FakeTransport(this.handlerFor);

  /// Rend le couple (statut, corps) pour une requête donnée.
  final (int, Object?) Function(RequestOptions options) handlerFor;

  final List<RequestOptions> calls = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    calls.add(options);
    final (status, body) = handlerFor(options);
    handler.resolve(
      Response<dynamic>(requestOptions: options, statusCode: status, data: body),
    );
  }

  int get tokenCalls =>
      calls.where((c) => c.path.contains('access_token')).length;
  int get searchCalls => calls.where((c) => c.path.contains('search')).length;
}

Dio _dioWith(_FakeTransport transport) => Dio()..interceptors.add(transport);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      SecretKey.franceTravailClientId.storageKey: 'un-client-id',
      SecretKey.franceTravailClientSecret.storageKey: 'un-secret',
    });
  });

  (int, Object?) nominal(RequestOptions o) {
    if (o.path.contains('access_token')) {
      return (200, {'access_token': 'jeton-abc', 'expires_in': 1499});
    }
    return (
      200,
      {
        'resultats': [
          {'id': '1', 'intitule': 'Développeur IA', 'entreprise': {'nom': 'ACME'}},
        ],
      }
    );
  }

  test('recherche nominale : jeton puis offres normalisées', () async {
    final transport = _FakeTransport(nominal);
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    final offers = await client.search(keywords: 'développeur ia');

    expect(offers, hasLength(1));
    expect(offers.single.title, 'Développeur IA');
    expect(offers.single.source, 'france_travail');
    expect(transport.tokenCalls, 1);
    expect(transport.searchCalls, 1);
  });

  test('le jeton est mis en cache entre deux recherches', () async {
    // Le jeton vit ~25 min. Le redemander à chaque recherche est un appel
    // gratuit en plus : c'est la leçon du nœud n8n d'origine.
    final transport = _FakeTransport(nominal);
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    await client.search(keywords: 'a');
    await client.search(keywords: 'b');

    expect(transport.tokenCalls, 1, reason: 'un seul jeton pour deux recherches');
    expect(transport.searchCalls, 2);
  });

  test('les paramètres du workflow Docker sont repris', () async {
    final transport = _FakeTransport(nominal);
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    await client.search(keywords: 'dev', communeInsee: '59606', radiusKm: 30);

    final search = transport.calls.firstWhere((c) => c.path.contains('search'));
    expect(search.queryParameters['motsCles'], 'dev');
    expect(search.queryParameters['commune'], '59606');
    expect(search.queryParameters['distance'], 30);
    expect(search.headers['Authorization'], 'Bearer jeton-abc');
  });

  test('commune absente : le paramètre n\'est pas envoyé vide', () async {
    final transport = _FakeTransport(nominal);
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    await client.search(keywords: 'dev');

    final search = transport.calls.firstWhere((c) => c.path.contains('search'));
    expect(search.queryParameters.containsKey('commune'), isFalse);
    expect(search.queryParameters.containsKey('distance'), isFalse);
  });

  test('204 : aucun résultat, ce n\'est pas une erreur', () async {
    final transport = _FakeTransport((o) => o.path.contains('access_token')
        ? (200, {'access_token': 'j', 'expires_in': 1499})
        : (204, null));
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    expect(await client.search(keywords: 'introuvable'), isEmpty);
  });

  test('206 : réponse partielle, le corps reste exploitable', () async {
    final transport = _FakeTransport((o) => o.path.contains('access_token')
        ? (200, {'access_token': 'j', 'expires_in': 1499})
        : (206, {
            'resultats': [
              {'id': '1', 'intitule': 'Dev'},
            ],
          }));
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    expect(await client.search(keywords: 'dev'), hasLength(1));
  });

  test('identifiants absents : message clair, pas de plantage', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final transport = _FakeTransport(nominal);
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    expect(await client.isConfigured, isFalse);
    await expectLater(
      client.search(keywords: 'dev'),
      throwsA(isA<FranceTravailUnavailable>().having(
        (e) => e.message,
        'message',
        contains('réglages'),
      )),
    );
    expect(transport.tokenCalls, 0, reason: 'aucun appel réseau inutile');
  });

  test('identifiants refusés (400) : message actionnable', () async {
    final transport = _FakeTransport((_) => (400, {'error': 'invalid_client'}));
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    await expectLater(
      client.search(keywords: 'dev'),
      throwsA(isA<FranceTravailUnavailable>().having(
        (e) => e.message,
        'message',
        contains('refusés'),
      )),
    );
  });

  test('panne de l\'API de recherche : exception typée', () async {
    final transport = _FakeTransport((o) => o.path.contains('access_token')
        ? (200, {'access_token': 'j', 'expires_in': 1499})
        : (500, null));
    final client =
        FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

    await expectLater(
      client.search(keywords: 'dev'),
      throwsA(isA<FranceTravailUnavailable>()),
    );
  });
}
