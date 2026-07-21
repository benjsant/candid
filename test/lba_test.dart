/// Client La Bonne Alternance, sur un `Dio` simulé.
///
/// Le point le plus important est le dernier test : les `recruiters` sont des
/// entreprises **sans offre publiée**. Les enregistrer comme des offres
/// reviendrait à inventer une annonce, ce que le projet s'interdit.
library;

import 'package:candid/core/secrets.dart';
import 'package:candid/sources/lba.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fake extends Interceptor {
  _Fake(this.status, this.body);
  final int status;
  final Object? body;
  final List<RequestOptions> calls = [];

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    calls.add(o);
    h.resolve(Response<dynamic>(
        requestOptions: o, statusCode: status, data: body));
  }
}

/// Forme réelle, relevée sur un appel du 21/07/2026 (Lille, ROME M1805).
const _reponseReelle = {
  'jobs': [
    {
      'identifier': {
        'id': '6a40507d1f2518e8d1c3bded',
        'partner_label': 'France Travail',
        'partner_job_id': '4307479',
      },
      'offer': {'title': 'Développeur / Développeuse informatique (H/F)'},
      // Cas documenté : les offres partenaires n'ont aucun nom d'entreprise.
      'workplace': {
        'brand': null,
        'name': null,
        'legal_name': null,
        'location': {'address': '59100 Roubaix'},
      },
      'contract': {
        'type': ['Apprentissage'],
      },
      'apply': {'url': 'https://www.meteojob.com/jobs/51409157'},
    },
  ],
  'recruiters': [
    {
      'identifier': {'id': 'r-1'},
      'workplace': {'name': 'ACME', 'siret': '12345678900011'},
      'apply': {'url': 'https://labonnealternance.fr/r-1'},
    },
    {
      'identifier': {'id': 'r-2'},
      'workplace': {'name': 'BETA'},
    },
  ],
  'warnings': <dynamic>[],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      SecretKey.lbaApiKey.storageKey: 'une-cle',
    });
  });

  LbaClient clientWith(_Fake f) =>
      LbaClient(secrets: Secrets(), dio: Dio()..interceptors.add(f));

  test('mappe la réponse réelle', () async {
    final result = await clientWith(_Fake(200, _reponseReelle)).search(
      latitude: 50.6366,
      longitude: 3.0709,
    );

    expect(result.jobs, hasLength(1));
    final j = result.jobs.single;
    expect(j.source, 'la_bonne_alternance');
    expect(j.title, 'Développeur / Développeuse informatique (H/F)');
    expect(j.location, '59100 Roubaix');
    expect(j.contractType, 'Apprentissage');
    expect(j.company, '', reason: 'offre partenaire : rien à inventer');
  });

  test('les recruteurs sont comptés, pas transformés en offres', () async {
    // Une entreprise « à fort potentiel » n'a pas publié d'offre : lui en
    // fabriquer une serait exactement ce que le projet s'interdit.
    final result = await clientWith(_Fake(200, _reponseReelle)).search(
      latitude: 50.6366,
      longitude: 3.0709,
    );

    expect(result.recruiterCount, 2);
    expect(result.jobs, hasLength(1), reason: 'les 2 recruteurs restent dehors');
  });

  test('les paramètres attendus par l\'API sont envoyés', () async {
    final f = _Fake(200, _reponseReelle);
    await clientWith(f).search(
      latitude: 50.358,
      longitude: 3.523,
      radiusKm: 20,
      romeCodes: 'M1805,M1810',
    );

    final q = f.calls.single.queryParameters;
    expect(q['latitude'], 50.358);
    expect(q['longitude'], 3.523);
    expect(q['radius'], 20);
    expect(q['romes'], 'M1805,M1810');
    expect(f.calls.single.headers['Authorization'], 'Bearer une-cle');
  });

  test('clé absente : message clair, aucun appel', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final f = _Fake(200, _reponseReelle);
    final client = clientWith(f);

    expect(await client.isConfigured, isFalse);
    await expectLater(
      client.search(latitude: 1, longitude: 1),
      throwsA(isA<LbaUnavailable>()
          .having((e) => e.message, 'message', contains('réglages'))),
    );
    expect(f.calls, isEmpty);
  });

  test('clé refusée (401) : message actionnable', () async {
    await expectLater(
      clientWith(_Fake(401, null)).search(latitude: 1, longitude: 1),
      throwsA(isA<LbaUnavailable>()
          .having((e) => e.message, 'message', contains('refusée'))),
    );
  });

  test('réponse vide : aucune offre, pas d\'erreur', () async {
    final result = await clientWith(_Fake(200, {'jobs': [], 'recruiters': []}))
        .search(latitude: 1, longitude: 1);
    expect(result.jobs, isEmpty);
    expect(result.recruiterCount, 0);
  });
}
