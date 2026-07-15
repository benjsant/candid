/// Enregistrement des offres, avec déduplication par hash.
library;

import 'package:drift/drift.dart';

import '../domain/hash.dart';
import '../domain/scoring.dart';
import 'database.dart';

/// Ce qu'il est advenu d'une offre qu'on a tenté d'enregistrer.
enum SaveOutcome {
  /// Nouvelle offre, enregistrée.
  saved,

  /// Déjà connue (même hash) : on n'a rien fait.
  duplicate,

  /// Écartée par une exclusion du profil.
  excluded,
}

class SaveResult {
  const SaveResult(this.outcome, {this.offerId, this.score});

  final SaveOutcome outcome;
  final int? offerId;
  final int? score;
}

class OffersRepository {
  OffersRepository(this._db);

  final AppDatabase _db;

  /// Enregistre une offre si elle est nouvelle. Le hash est la clé : deux
  /// offres qui se canonicalisent pareil sont la même offre, quelle que soit la
  /// source qui l'a apportée.
  Future<SaveResult> save({
    required String source,
    required String title,
    String? company,
    String? location,
    String? description,
    String? url,
    String? contractType,
    String? salary,
    String? sourceId,
    Prefs prefs = const Prefs(),
  }) async {
    final offer = ScorableOffer(
      title: title,
      company: company,
      location: location,
      description: description,
      contractType: contractType,
      salary: salary,
    );
    final annotated = annotate(offer, prefs);

    if (annotated.excluded) {
      return const SaveResult(SaveOutcome.excluded);
    }

    final existing = await (_db.select(_db.offers)
          ..where((o) => o.hash.equals(annotated.hash)))
        .getSingleOrNull();
    if (existing != null) {
      return SaveResult(
        SaveOutcome.duplicate,
        offerId: existing.id,
        score: existing.score,
      );
    }

    final id = await _db.into(_db.offers).insert(
          OffersCompanion.insert(
            source: source,
            sourceId: Value(sourceId),
            hash: annotated.hash,
            title: title,
            company: Value(company),
            companyCanon: Value(canonCompany(company)),
            location: Value(location),
            description: Value(description),
            url: Value(url),
            contractType: Value(contractType),
            salary: Value(salary),
            score: Value(annotated.score),
          ),
        );

    return SaveResult(SaveOutcome.saved, offerId: id, score: annotated.score);
  }

  /// Les offres à trier, les mieux notées d'abord.
  Stream<List<Offer>> watchInbox() {
    return (_db.select(_db.offers)
          ..where((o) => o.status.isIn([OfferStatus.newOffer, OfferStatus.reviewed]))
          ..orderBy([
            (o) => OrderingTerm(expression: o.score, mode: OrderingMode.desc),
            (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<void> setStatus(int offerId, String status) async {
    await (_db.update(_db.offers)..where((o) => o.id.equals(offerId)))
        .write(OffersCompanion(status: Value(status)));
  }
}
