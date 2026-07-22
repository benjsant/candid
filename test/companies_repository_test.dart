/// Les entreprises « à démarcher ».
///
/// Le test le plus important est le dernier : ces fiches n'ont pas de poste
/// publié, et rien ne doit en fabriquer un. C'est la même règle que pour
/// l'agent et pour le parseur de partage.
library;

import 'package:candid/data/companies_repository.dart';
import 'package:candid/data/database.dart';
import 'package:candid/sources/normalize.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CompaniesRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CompaniesRepository(db);
  });
  tearDown(() => db.close());

  const acme = NormalizedRecruiter(
    sourceId: 'r-1',
    name: 'ACME',
    siret: '12345678900011',
    sector: 'Programmation informatique',
    website: 'https://acme.fr',
    location: '59300 Valenciennes',
    applyUrl: 'https://labonnealternance.fr/r-1',
    email: 'rh@acme.fr',
  );

  test('enregistre une entreprise avec ses coordonnées', () async {
    expect(await repo.saveAll([acme]), 1);

    final c = (await db.select(db.companies).get()).single;
    expect(c.name, 'ACME');
    expect(c.siret, '12345678900011');
    expect(c.location, '59300 Valenciennes');
    expect(c.email, 'rh@acme.fr');
    expect(c.source, kSourceLba);
  });

  test('une seconde collecte ne duplique pas', () async {
    await repo.saveAll([acme]);
    expect(await repo.saveAll([acme]), 0, reason: 'aucune nouvelle');
    expect(await db.select(db.companies).get(), hasLength(1));
  });

  test('le SIRET prime sur le nom pour identifier', () async {
    // Deux établissements peuvent porter le même nom commercial ; le SIRET est
    // la seule identité fiable.
    await repo.saveAll([acme]);
    const autreEtablissement = NormalizedRecruiter(
      sourceId: 'r-2',
      name: 'ACME Nord',
      siret: '99999999900022',
    );
    expect(await repo.saveAll([autreEtablissement]), 1);
    expect(await db.select(db.companies).get(), hasLength(2));
  });

  test('une fiche modifiée à la main n\'est pas écrasée par une collecte',
      () async {
    // L'utilisateur a pu corriger un contact ou annoter la fiche. Une collecte
    // ne doit pas effacer son travail.
    await db.into(db.companies).insert(CompaniesCompanion.insert(
          name: 'ACME',
          siret: const Value('12345678900011'),
          email: const Value('contact-verifie@acme.fr'),
        ));

    await repo.saveAll([acme]);

    final c = (await db.select(db.companies).get()).single;
    expect(c.email, 'contact-verifie@acme.fr');
  });

  test('une entreprise sans nom est ignorée', () async {
    expect(await repo.saveAll([const NormalizedRecruiter(sourceId: 'x', name: '')]),
        0);
    expect(await db.select(db.companies).get(), isEmpty);
  });

  test('aucun poste n\'est inventé : ni titre, ni description', () async {
    // Garde-fou central. Une entreprise « à démarcher » n'a pas publié
    // d'offre : lui en fabriquer une serait exactement ce que le projet
    // s'interdit.
    await repo.saveAll([acme]);

    final c = (await db.select(db.companies).get()).single;
    expect(c.description, isNull);
    expect(c.aiSummary, isNull);
    // Et surtout : rien n'a atterri dans la boîte aux offres.
    expect(await db.select(db.offers).get(), isEmpty);
  });
}
