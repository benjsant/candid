/// Le digest hebdomadaire : le mouvement de la semaine, et ce qui demande une
/// action. Le texte est une fonction pure ; le calcul se teste sur une base en
/// mémoire.
library;

import 'package:candid/data/database.dart';
import 'package:candid/data/digest_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('digestNotification', () {
    test('semaine vide et rien à faire : pas de notification', () {
      // Un rappel hebdomadaire qui ne dit rien est une nuisance.
      expect(digestNotification(const Digest()), isNull);
    });

    test('une semaine active', () {
      final n = digestNotification(const Digest(
        newOffers: 24,
        applicationsSent: 3,
        responses: 1,
      ));
      expect(n!.title, contains('24 offres collectées'));
      expect(n.title, contains('3 candidatures envoyées'));
      expect(n.title, contains('1 réponse'));
    });

    test('l\'action à faire prime sur le bilan', () {
      // Les relances sont ce qui justifie d'ouvrir l'application.
      final n = digestNotification(const Digest(
        newOffers: 5,
        dueReminders: 2,
        pending: 4,
      ));
      expect(n!.body, contains('2 relances à faire'));
      expect(n.body, contains('4 sans réponse'));
    });

    test('rien de neuf mais une relance : on prévient quand même', () {
      final n = digestNotification(const Digest(dueReminders: 1));
      expect(n, isNotNull);
      expect(n!.title, 'Votre semaine');
      expect(n.body, contains('1 relance à faire'));
    });

    test('activité sans action : on le dit', () {
      final n = digestNotification(const Digest(newOffers: 3));
      expect(n!.body, 'Rien qui demande une action.');
    });
  });

  group('DigestService', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> addOffer({required int score, required DateTime at}) async {
      await db.into(db.offers).insert(OffersCompanion.insert(
            source: 'france_travail',
            hash: 'h-${at.microsecondsSinceEpoch}-$score',
            title: 'Dev',
            score: Value(score),
            createdAt: Value(at),
          ));
    }

    test('ne compte que la période demandée', () async {
      final now = DateTime.now();
      await addOffer(score: 80, at: now.subtract(const Duration(days: 2)));
      await addOffer(score: 40, at: now.subtract(const Duration(days: 3)));
      await addOffer(score: 90, at: now.subtract(const Duration(days: 30)));

      final d = await DigestService(db).build();
      expect(d.newOffers, 2, reason: 'celle d\'il y a 30 jours est hors période');
      expect(d.notableOffers, 1);
    });

    test('les candidatures sans réponse sont comptées, toutes périodes',
        () async {
      final now = DateTime.now();
      await db.into(db.applications).insert(ApplicationsCompanion.insert(
            status: const Value(ApplicationStatus.sent),
            // Envoyée il y a longtemps : elle reste « en attente ».
            appliedAt: Value(now.subtract(const Duration(days: 40))),
          ));

      final d = await DigestService(db).build();
      expect(d.applicationsSent, 0, reason: 'hors de la semaine');
      expect(d.pending, 1, reason: 'toujours sans réponse');
    });

    test('une relance prévue aujourd\'hui est due', () async {
      // Comparer à « maintenant » raterait les relances de plus tard dans la
      // journée : on compare à la fin du jour.
      final now = DateTime.now();
      await db.into(db.applications).insert(ApplicationsCompanion.insert(
            status: const Value(ApplicationStatus.sent),
            remindedAt: Value(DateTime(now.year, now.month, now.day, 23)),
          ));

      final d = await DigestService(db).build();
      expect(d.dueReminders, 1);
    });

    test('une relance future n\'est pas due', () async {
      await db.into(db.applications).insert(ApplicationsCompanion.insert(
            status: const Value(ApplicationStatus.sent),
            remindedAt: Value(DateTime.now().add(const Duration(days: 3))),
          ));

      final d = await DigestService(db).build();
      expect(d.dueReminders, 0);
    });

    test('base vide : digest vide, donc silencieux', () async {
      final d = await DigestService(db).build();
      expect(d.isEmpty, isTrue);
      expect(digestNotification(d), isNull);
    });
  });
}
