/// La chaîne de collecte de bout en bout, sans réseau : API simulée → normalisé
/// → enregistré avec déduplication. C'est le critère d'acceptation de l'étape 6
/// (« un second appui sur Collecter n'ajoute aucun doublon ») vérifié en test.
library;

import 'package:candid/core/secrets.dart';
import 'package:candid/data/database.dart';
import 'package:candid/data/offers_repository.dart';
import 'package:candid/sources/collect_service.dart';
import 'package:candid/sources/france_travail.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Répond à la place du réseau.
class _FakeTransport extends Interceptor {
  _FakeTransport(this.offers);

  /// Offres brutes au format France Travail que l'API est censée renvoyer.
  List<Map<String, dynamic>> offers;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final body = options.path.contains('access_token')
        ? {'access_token': 'jeton', 'expires_in': 1499}
        : {'resultats': offers};
    handler.resolve(
      Response<dynamic>(requestOptions: options, statusCode: 200, data: body),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late OffersRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = OffersRepository(db);
    FlutterSecureStorage.setMockInitialValues({
      SecretKey.franceTravailClientId.storageKey: 'id',
      SecretKey.franceTravailClientSecret.storageKey: 'secret',
    });
  });
  tearDown(() => db.close());

  CollectService serviceWith(_FakeTransport transport) => CollectService(
        db: db,
        repository: repo,
        franceTravail: FranceTravailClient(
          secrets: Secrets(),
          dio: Dio()..interceptors.add(transport),
        ),
      );

  test('collecte : les offres arrivent en base avec un score', () async {
    final transport = _FakeTransport([
      {
        'id': '1',
        'intitule': 'Développeur Python IA',
        'entreprise': {'nom': 'ACME'},
        'description': 'Machine learning, LLM, API FastAPI.',
      },
    ]);

    final report = await serviceWith(transport).collect();

    expect(report.fetched, 1);
    expect(report.saved, 1);
    expect(report.errors, isEmpty);

    final stored = await db.select(db.offers).get();
    expect(stored.single.title, 'Développeur Python IA');
    expect(stored.single.source, 'france_travail');
    expect(stored.single.score, greaterThan(0));
  });

  test('un second appui n\'ajoute aucun doublon', () async {
    // Critère d'acceptation de l'étape 6, tel qu'écrit dans TASKS.md.
    final transport = _FakeTransport([
      {'id': '1', 'intitule': 'Développeur IA', 'entreprise': {'nom': 'ACME'}},
    ]);
    final service = serviceWith(transport);

    final first = await service.collect();
    final second = await service.collect();

    expect(first.saved, 1);
    expect(second.saved, 0);
    expect(second.duplicates, 1);
    expect(await db.select(db.offers).get(), hasLength(1));
  });

  test('identifiants absents : la collecte le dit et ne plante pas', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final report = await serviceWith(_FakeTransport([])).collect();

    expect(report.saved, 0);
    expect(report.errors.single, contains('identifiants absents'));
  });

  test('le résumé est lisible', () async {
    final transport = _FakeTransport([
      {'id': '1', 'intitule': 'Développeur IA', 'entreprise': {'nom': 'A'}},
      {'id': '2', 'intitule': 'Data Engineer Python', 'entreprise': {'nom': 'B'}},
    ]);
    final report = await serviceWith(transport).collect();

    expect(report.summary, contains('2 nouvelles'));
    expect(report.summary, contains('sur 2'));
  });
}
