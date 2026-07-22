/// Digest hebdomadaire : où en est la recherche d'emploi, en un coup d'œil.
///
/// Ce que le suivi ne dit pas tout seul : est-ce que j'ai avancé cette semaine ?
/// Ai-je des relances qui traînent ? L'onglet Suivi montre l'état, le digest
/// montre le **mouvement** et ce qui demande une action.
///
/// Comme le reste : il informe, il n'agit pas. Aucune relance n'est envoyée.
library;

import 'package:drift/drift.dart';

import 'database.dart';

/// L'état de la recherche sur une période.
class Digest {
  const Digest({
    this.newOffers = 0,
    this.notableOffers = 0,
    this.applicationsSent = 0,
    this.responses = 0,
    this.interviews = 0,
    this.pending = 0,
    this.dueReminders = 0,
  });

  /// Offres collectées ou reçues pendant la période.
  final int newOffers;
  final int notableOffers;

  /// Candidatures déclarées envoyées pendant la période.
  final int applicationsSent;

  /// Réponses reçues (entretien, refus, acceptation) pendant la période.
  final int responses;
  final int interviews;

  /// Candidatures envoyées et toujours sans réponse, toutes périodes.
  final int pending;

  /// Relances dont la date est passée ou arrive aujourd'hui.
  final int dueReminders;

  bool get isEmpty =>
      newOffers == 0 &&
      applicationsSent == 0 &&
      responses == 0 &&
      dueReminders == 0;
}

/// Texte du digest. Fonction pure, donc testable sans base ni plugin.
///
/// Rend `null` s'il ne s'est rien passé **et** qu'il n'y a rien à faire :
/// un rappel hebdomadaire vide est une nuisance, pas un service.
({String title, String body})? digestNotification(Digest d) {
  if (d.isEmpty) return null;

  final faits = <String>[
    if (d.newOffers > 0)
      '${d.newOffers} offre${d.newOffers > 1 ? 's' : ''} collectée'
          '${d.newOffers > 1 ? 's' : ''}',
    if (d.applicationsSent > 0)
      '${d.applicationsSent} candidature${d.applicationsSent > 1 ? 's' : ''} '
          'envoyée${d.applicationsSent > 1 ? 's' : ''}',
    if (d.responses > 0)
      '${d.responses} réponse${d.responses > 1 ? 's' : ''}',
  ];

  // L'action à faire passe avant le bilan : c'est elle qui justifie d'ouvrir.
  final actions = <String>[
    if (d.dueReminders > 0)
      '${d.dueReminders} relance${d.dueReminders > 1 ? 's' : ''} à faire',
    if (d.pending > 0)
      '${d.pending} sans réponse',
  ];

  return (
    title: faits.isEmpty ? 'Votre semaine' : 'Cette semaine : ${faits.join(', ')}',
    body: actions.isEmpty
        ? 'Rien qui demande une action.'
        : actions.join(' · '),
  );
}

class DigestService {
  DigestService(this._db);

  final AppDatabase _db;

  /// Le bilan des [days] derniers jours (une semaine par défaut).
  Future<Digest> build({int days = 7, int notableScore = 75}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    // Comparer les relances à la fin de la journée : une relance prévue
    // aujourd'hui doit apparaître, pas seulement celles d'hier.
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final offers = await (_db.select(_db.offers)
          ..where((o) => o.createdAt.isBiggerThanValue(since)))
        .get();

    final applications = await _db.select(_db.applications).get();

    final sentThisWeek = applications
        .where((a) => a.appliedAt != null && a.appliedAt!.isAfter(since))
        .length;
    final respondedThisWeek = applications
        .where((a) => a.responseAt != null && a.responseAt!.isAfter(since))
        .toList();

    return Digest(
      newOffers: offers.length,
      notableOffers: offers.where((o) => (o.score ?? 0) >= notableScore).length,
      applicationsSent: sentThisWeek,
      responses: respondedThisWeek.length,
      interviews: respondedThisWeek
          .where((a) => a.status == ApplicationStatus.interview)
          .length,
      // « Envoyée » et toujours rien en retour, quelle que soit la date : c'est
      // le stock qui compte ici, pas le mouvement de la semaine.
      pending: applications
          .where((a) =>
              a.status == ApplicationStatus.sent && a.responseAt == null)
          .length,
      dueReminders: applications
          .where((a) =>
              a.remindedAt != null && a.remindedAt!.isBefore(endOfToday))
          .length,
    );
  }
}
