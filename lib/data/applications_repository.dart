/// Suivi des candidatures (étape 5). Crée une candidature à partir d'une offre,
/// suit la liste, et gère le cycle de vie : brouillon, envoyée, entretien,
/// refusée, acceptée.
///
/// Règle du projet : l'application n'envoie jamais rien. `appliedAt` n'est
/// renseigné que lorsque l'utilisateur déclare avoir envoyé lui-même (statut
/// « envoyée »). Les champs poste/entreprise/lien sont figés à la création :
/// l'offre peut disparaître, la trace du suivi doit rester lisible.
library;

import 'package:drift/drift.dart';

import 'database.dart';

class ApplicationsRepository {
  ApplicationsRepository(this._db);

  final AppDatabase _db;

  /// La candidature liée à une offre, si elle existe déjà.
  Future<Application?> forOffer(int offerId) {
    return (_db.select(_db.applications)
          ..where((a) => a.offerId.equals(offerId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Crée une candidature (brouillon) à partir d'une offre, et sort l'offre de
  /// la boîte de réception (statut `selected`). Idempotent : si une candidature
  /// existe déjà pour cette offre, on la renvoie sans en créer une seconde.
  Future<int> createFromOffer(Offer offer) async {
    final existing = await forOffer(offer.id);
    if (existing != null) return existing.id;

    final id = await _db.into(_db.applications).insert(
          ApplicationsCompanion.insert(
            offerId: Value(offer.id),
            kind: const Value(ApplicationKind.offer),
            status: const Value(ApplicationStatus.draft),
            poste: Value(offer.title),
            entreprise: Value(offer.company),
            lien: Value(offer.url),
            score: Value(offer.score),
          ),
        );
    // L'offre quitte la boîte : elle est en cours de traitement, pas à trier.
    await (_db.update(_db.offers)..where((o) => o.id.equals(offer.id)))
        .write(const OffersCompanion(status: Value(OfferStatus.selected)));
    return id;
  }

  /// Les candidatures, la plus récente d'abord.
  Stream<List<Application>> watchAll() {
    return (_db.select(_db.applications)
          ..orderBy([
            (a) => OrderingTerm(
                expression: a.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<Application> _byId(int id) =>
      (_db.select(_db.applications)..where((a) => a.id.equals(id))).getSingle();

  /// Change le statut. Effets de bord datés, sans jamais rien envoyer :
  ///  - passage à « envoyée » : renseigne `appliedAt` (l'utilisateur l'a envoyée) ;
  ///  - passage à une réponse (entretien/refus/accepté) : renseigne `responseAt`.
  Future<void> setStatus(int id, String status) async {
    final current = await _byId(id);
    var companion = ApplicationsCompanion(status: Value(status));

    if (status == ApplicationStatus.sent && current.appliedAt == null) {
      companion = companion.copyWith(appliedAt: Value(DateTime.now()));
    }
    const responses = [
      ApplicationStatus.interview,
      ApplicationStatus.rejected,
      ApplicationStatus.accepted,
    ];
    if (responses.contains(status) && current.responseAt == null) {
      companion = companion.copyWith(responseAt: Value(DateTime.now()));
    }

    await (_db.update(_db.applications)..where((a) => a.id.equals(id)))
        .write(companion);
  }

  /// Date de relance à se rappeler (ou null pour l'effacer).
  Future<void> setReminder(int id, DateTime? date) async {
    await (_db.update(_db.applications)..where((a) => a.id.equals(id)))
        .write(ApplicationsCompanion(remindedAt: Value(date)));
  }

  Future<void> setNotes(int id, String notes) async {
    await (_db.update(_db.applications)..where((a) => a.id.equals(id)))
        .write(ApplicationsCompanion(notes: Value(notes.isEmpty ? null : notes)));
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.applications)..where((a) => a.id.equals(id))).go();
  }
}
