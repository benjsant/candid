/// La chaîne de collecte de bout en bout, sans réseau : API simulée → normalisé
/// → enregistré avec déduplication. C'est le critère d'acceptation de l'étape 6
/// (« un second appui sur Collecter n'ajoute aucun doublon ») vérifié en test.
library;

import 'package:candid/core/secrets.dart';
import 'package:candid/data/database.dart';
import 'package:candid/data/offers_repository.dart';
import 'package:candid/data/profile_repository.dart';
import 'package:candid/sources/collect_service.dart';
import 'package:candid/sources/france_travail.dart';
import 'package:candid/sources/lba.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Répond à la place du réseau.
class _FakeTransport extends Interceptor {
  _FakeTransport(this.offers);

  /// Offres brutes au format France Travail que l'API est censée renvoyer.
  List<Map<String, dynamic>> offers;

  final List<RequestOptions> calls = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    calls.add(options);
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
        lba: LbaClient(
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

    // Trois termes par défaut, mais la même offre : dédoublonnée dès la
    // collecte, elle ne compte qu'une fois.
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

  test('une requête par mot-clé, pas une requête avec tous les mots', () async {
    // France Travail fait un ET entre les mots de `motsCles` (vérifié en réel
    // le 21/07/2026 : 4 mots -> 204, « python » seul -> 7 offres). On envoie
    // donc un terme par requête.
    final transport = _FakeTransport([
      {'id': '1', 'intitule': 'Développeur IA', 'entreprise': {'nom': 'A'}},
    ]);
    await ProfileRepository(db).save(
      keywords: 'développeur, python, intelligence artificielle',
      locationInsee: '59606',
      radiusKm: 30,
    );

    await serviceWith(transport).collect();

    final searches =
        transport.calls.where((c) => c.path.contains('search')).toList();
    expect(searches, hasLength(3), reason: 'un appel par terme');
    expect(
      searches.map((c) => c.queryParameters['motsCles']),
      ['développeur', 'python', 'intelligence artificielle'],
    );
    // Le filtre géographique accompagne chaque requête.
    expect(searches.first.queryParameters['commune'], '59606');
    expect(searches.first.queryParameters['distance'], 30);
  });

  test('sans virgule, chaque mot devient une recherche', () async {
    // Piège réel du 21/07/2026 : « développeur python intelligence artificielle »
    // saisi sans virgule partait en UNE requête, que France Travail traitait en
    // ET -> 204, zéro offre, sans explication pour l'utilisateur.
    final transport = _FakeTransport([]);
    await ProfileRepository(db).save(keywords: 'développeur python ia');

    await serviceWith(transport).collect();

    final searches =
        transport.calls.where((c) => c.path.contains('search')).toList();
    expect(searches.map((c) => c.queryParameters['motsCles']),
        ['développeur', 'python', 'ia']);
  });

  test('un terme est borné à trois mots (limite de l\'API)', () async {
    final transport = _FakeTransport([]);
    await ProfileRepository(db)
        .save(keywords: 'un deux trois quatre cinq, python');

    await serviceWith(transport).collect();

    final searches =
        transport.calls.where((c) => c.path.contains('search')).toList();
    expect(searches.first.queryParameters['motsCles'], 'un deux trois');
  });

  test('le résumé est lisible', () async {
    final transport = _FakeTransport([
      {'id': '1', 'intitule': 'Développeur IA', 'entreprise': {'nom': 'A'}},
      {'id': '2', 'intitule': 'Data Engineer Python', 'entreprise': {'nom': 'B'}},
    ]);
    final report = await serviceWith(transport).collect();

    expect(report.summary, contains('2 nouvelles'));
    expect(report.summary, contains('sur 2'),
        reason: 'les doublons entre requêtes ne gonflent pas le total');
  });
}
