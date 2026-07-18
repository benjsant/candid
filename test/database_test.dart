/// Vérifie le socle de l'étape 1 : le schéma porté depuis PostgreSQL tient, et
/// la déduplication par hash fait bien son travail.
library;

import 'package:candid/data/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('une offre s\'insère et se relit', () async {
    await db.into(db.offers).insert(
          OffersCompanion.insert(
            source: 'shared',
            hash: 'abc123',
            title: 'Développeur IA junior',
            company: const Value('ACME'),
          ),
        );

    final offers = await db.select(db.offers).get();
    expect(offers, hasLength(1));
    expect(offers.single.title, 'Développeur IA junior');
    // Valeur par défaut reprise du schéma PostgreSQL.
    expect(offers.single.status, OfferStatus.newOffer);
  });

  test('le hash est unique : une offre déjà connue ne rentre pas deux fois',
      () async {
    Future<void> insert() => db.into(db.offers).insert(
          OffersCompanion.insert(
            source: 'shared',
            hash: 'meme-hash',
            title: 'Développeur IA junior',
          ),
        );

    await insert();
    expect(insert(), throwsA(isA<SqliteException>()));
    expect(await db.select(db.offers).get(), hasLength(1));
  });

  test('les index de parité Postgres existent (statut, date, entreprise)',
      () async {
    // Sans eux, watchInbox() balaierait toute la table à chaque écriture.
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
        )
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll({
        'idx_offers_status',
        'idx_offers_created_at',
        'idx_offers_company_canon',
      }),
    );
  });

  test('supprimer une candidature supprime ses documents (cascade)', () async {
    final appId = await db.into(db.applications).insert(
          ApplicationsCompanion.insert(poste: const Value('Dev IA')),
        );
    await db.into(db.generatedDocuments).insert(
          GeneratedDocumentsCompanion.insert(
            applicationId: appId,
            cvPath: const Value('/tmp/cv.pdf'),
          ),
        );

    await (db.delete(db.applications)..where((a) => a.id.equals(appId))).go();

    // Sans `PRAGMA foreign_keys = ON`, SQLite laisserait l'orphelin en place.
    expect(await db.select(db.generatedDocuments).get(), isEmpty);
  });
}
