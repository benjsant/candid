/// Le suivi des candidatures : création depuis une offre (idempotente, sort
/// l'offre de la boîte), cycle de vie daté, et garde-fou « rien n'est envoyé »
/// (appliedAt ne se pose que sur passage à « envoyée »).
library;

import 'package:candid/data/applications_repository.dart';
import 'package:candid/data/database.dart';
import 'package:candid/data/offers_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late OffersRepository offers;
  late ApplicationsRepository apps;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    offers = OffersRepository(db);
    apps = ApplicationsRepository(db);
  });
  tearDown(() => db.close());

  Future<Offer> anOffer() async {
    final r = await offers.save(
      source: 'shared',
      title: 'Développeur IA Junior',
      company: 'ACME',
      url: 'https://ex.fr/1',
    );
    return (db.select(db.offers)..where((o) => o.id.equals(r.offerId!)))
        .getSingle();
  }

  test('créer depuis une offre : brouillon, champs figés, offre sortie de la boîte',
      () async {
    final offer = await anOffer();
    final id = await apps.createFromOffer(offer);
    final app = await (db.select(db.applications)
          ..where((a) => a.id.equals(id)))
        .getSingle();

    expect(app.status, ApplicationStatus.draft);
    expect(app.poste, 'Développeur IA Junior');
    expect(app.entreprise, 'ACME');
    expect(app.lien, 'https://ex.fr/1');
    expect(app.appliedAt, isNull, reason: 'rien n\'est envoyé à la création');

    // L'offre a quitté la boîte de réception.
    final refreshed =
        await (db.select(db.offers)..where((o) => o.id.equals(offer.id)))
            .getSingle();
    expect(refreshed.status, OfferStatus.selected);
  });

  test('création idempotente : deux appels, une seule candidature', () async {
    final offer = await anOffer();
    final a = await apps.createFromOffer(offer);
    final b = await apps.createFromOffer(offer);
    expect(a, b);
    expect(await db.select(db.applications).get(), hasLength(1));
  });

  test('marquer « envoyée » renseigne appliedAt', () async {
    final offer = await anOffer();
    final id = await apps.createFromOffer(offer);
    await apps.setStatus(id, ApplicationStatus.sent);
    final app =
        await (db.select(db.applications)..where((a) => a.id.equals(id)))
            .getSingle();
    expect(app.status, ApplicationStatus.sent);
    expect(app.appliedAt, isNotNull);
    expect(app.responseAt, isNull);
  });

  test('une réponse (entretien) renseigne responseAt', () async {
    final offer = await anOffer();
    final id = await apps.createFromOffer(offer);
    await apps.setStatus(id, ApplicationStatus.interview);
    final app =
        await (db.select(db.applications)..where((a) => a.id.equals(id)))
            .getSingle();
    expect(app.responseAt, isNotNull);
  });

  test('notes et relance se posent et s\'effacent', () async {
    final offer = await anOffer();
    final id = await apps.createFromOffer(offer);
    await apps.setNotes(id, 'Relancer le recruteur');
    await apps.setReminder(id, DateTime(2026, 8, 1));
    var app = await (db.select(db.applications)..where((a) => a.id.equals(id)))
        .getSingle();
    expect(app.notes, 'Relancer le recruteur');
    expect(app.remindedAt, DateTime(2026, 8, 1));

    await apps.setNotes(id, '');
    await apps.setReminder(id, null);
    app = await (db.select(db.applications)..where((a) => a.id.equals(id)))
        .getSingle();
    expect(app.notes, isNull);
    expect(app.remindedAt, isNull);
  });

  test('supprimer une candidature la retire de la liste', () async {
    final offer = await anOffer();
    final id = await apps.createFromOffer(offer);
    await apps.delete(id);
    expect(await db.select(db.applications).get(), isEmpty);
  });
}
