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

  group('franceTravailOfferId', () {
    test('extrait l\'identifiant des URL réellement partagées', () {
      // Formes relevées en base après une collecte réelle (21/07/2026).
      expect(
        franceTravailOfferId(
            'https://candidat.francetravail.fr/offres/recherche/detail/210RHTN'),
        '210RHTN',
      );
      expect(
        franceTravailOfferId(
            'https://candidat.francetravail.fr/offres/recherche/detail/3964931'),
        '3964931',
      );
      expect(
        franceTravailOfferId(
            'https://candidat.pole-emploi.fr/offres/recherche/detail/191KTPX'),
        '191KTPX',
      );
    });

    test('une URL d\'une autre source n\'est pas résolue', () {
      expect(franceTravailOfferId('https://www.linkedin.com/jobs/view/123456'),
          isNull);
      expect(
        franceTravailOfferId(
            'https://www.welcometothejungle.com/fr/companies/x/jobs/detail/abcdef'),
        isNull,
        reason: 'le seul motif /detail/ ne suffit pas',
      );
    });

    test('rien à extraire : null, on ne devine pas', () {
      expect(franceTravailOfferId(null), isNull);
      expect(franceTravailOfferId(''), isNull);
      expect(franceTravailOfferId('https://candidat.francetravail.fr/offres/'),
          isNull);
      expect(
        franceTravailOfferId('https://candidat.francetravail.fr/detail/AB'),
        isNull,
        reason: 'trop court pour être un identifiant d\'offre',
      );
    });
  });

  group('offerById', () {
    test('résout une offre complète', () async {
      final transport = _FakeTransport((o) => o.path.contains('access_token')
          ? (200, {'access_token': 'j', 'expires_in': 1499})
          : (
              200,
              {
                'id': '210RHTN',
                'intitule': 'Développeur Informatique (H/F)',
                'entreprise': {'nom': 'SASU SLUSARSKI'},
                'lieuTravail': {'libelle': '59 - ESCAUDAIN'},
                'typeContrat': 'CDD',
                'description': 'SOMEX, acteur reconnu…',
              }
            ));
      final client =
          FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

      final offer = await client.offerById('210RHTN');

      expect(offer, isNotNull);
      expect(offer!.title, 'Développeur Informatique (H/F)');
      expect(offer.company, 'SASU SLUSARSKI');
      expect(offer.location, '59 - ESCAUDAIN');
      expect(offer.contractType, 'CDD');
      expect(offer.description, 'SOMEX, acteur reconnu…');
    });

    test('identifiant inconnu (400) : null, pas d\'exception', () async {
      // L'offre a pu être retirée. L'utilisateur complétera à la main : ce
      // n'est pas une raison d'interrompre le partage.
      final transport = _FakeTransport((o) => o.path.contains('access_token')
          ? (200, {'access_token': 'j', 'expires_in': 1499})
          : (400, null));
      final client =
          FranceTravailClient(secrets: Secrets(), dio: _dioWith(transport));

      expect(await client.offerById('INEXISTANT'), isNull);
    });
  });

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
