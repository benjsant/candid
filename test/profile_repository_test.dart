/// Le profil de recherche : c'est lui qui borne la collecte. Ces tests
/// vérifient surtout qu'un champ vide devient `null` et disparaît donc de la
/// requête, au lieu d'y être envoyé vide.
library;

import 'package:candid/data/database.dart';
import 'package:candid/data/profile_repository.dart';
import 'package:candid/domain/scoring.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProfileRepository(db);
  });
  tearDown(() => db.close());

  test('aucun profil au départ', () async {
    expect(await repo.active(), isNull);
  });

  test('création puis mise à jour ne crée qu\'un seul profil', () async {
    await repo.save(keywords: 'python', locationLabel: 'Lille (59)',
        locationInsee: '59350', radiusKm: 30);
    await repo.save(keywords: 'python ia', locationLabel: 'Valenciennes (59)',
        locationInsee: '59606', radiusKm: 20);

    final all = await db.select(db.searchProfiles).get();
    expect(all, hasLength(1), reason: 'un seul profil, mis à jour');
    expect(all.single.keywords, 'python ia');
    expect(all.single.locationInsee, '59606');
    expect(all.single.radiusKm, 20);
  });

  test('les champs vides deviennent null, pas des chaînes vides', () async {
    // Sinon la requête France Travail partirait avec `commune=` vide, ce que
    // l'API n'apprécie pas.
    await repo.save(
      keywords: 'python',
      locationLabel: '   ',
      locationInsee: '',
      radiusKm: null,
      exclusions: '',
    );

    final p = (await repo.active())!;
    expect(p.locationLabel, isNull);
    expect(p.locationInsee, isNull);
    expect(p.radiusKm, isNull);
    expect(p.exclusions, isNull);
  });

  group('plusieurs communes', () {
    test('codes joints par des virgules : c\'est ce qu\'attend l\'API', () {
      const c = ProfileCommunes(
        ['Valenciennes (59)', 'Lille (59)'],
        ['59606', '59350'],
      );
      expect(c.query, '59606,59350');
      expect(c.length, 2);
    });

    test('aller-retour stockage sans perte', () async {
      const saisi = ProfileCommunes(
        ['Valenciennes (59)', 'Lille (59)', 'Douai (59)'],
        ['59606', '59350', '59178'],
      );
      await repo.save(
        keywords: 'python',
        locationLabel: saisi.storedLabels,
        locationInsee: saisi.storedCodes,
        radiusKm: 30,
      );

      final p = (await repo.active())!;
      final relu = ProfileCommunes.parse(p.locationLabel, p.locationInsee);
      expect(relu.codes, saisi.codes);
      expect(relu.labels, saisi.labels);
      expect(relu.query, '59606,59350,59178');
    });

    test('libellés désaccordés : on retombe sur les codes', () {
      // Robustesse : les codes sont ce qui pilote la requête, ils priment.
      final c = ProfileCommunes.parse('Lille (59)', '59350,59606');
      expect(c.codes, ['59350', '59606']);
      expect(c.labels, ['59350', '59606']);
    });

    test('aucune commune : vide, pas de virgule parasite', () {
      final c = ProfileCommunes.parse('', '');
      expect(c.isEmpty, isTrue);
      expect(c.query, '');
    });
  });

  test('le profil alimente bien le scoring', () async {
    await repo.save(
      keywords: 'python ia',
      seniority: 'junior',
      exclusions: 'php',
    );
    final p = (await repo.active())!;
    final prefs = Prefs.fromProfile(
      keywords: p.keywords,
      mustHave: p.mustHave,
      exclusions: p.exclusions,
      contractTypes: p.contractTypes,
      seniority: p.seniority,
    );

    expect(prefs.keywords, contains('python'));
    expect(prefs.exclusions, contains('php'));
    expect(prefs.seniority, 'junior');
  });
}
