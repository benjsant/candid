/// Enregistrement des offres, avec déduplication par hash.
library;

import 'package:drift/drift.dart';

import '../domain/dedup.dart';
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

  /// Cherche une offre déjà connue qui serait la même, venue d'une autre
  /// source. La comparaison se fait en Dart et non en SQL : `canonTitle` et
  /// `canonCity` ne sont pas exprimables en SQLite sans dupliquer leur logique,
  /// et le nombre d'offres à parcourir se compte en centaines.
  Future<Offer?> _findCrossSourceDuplicate({
    required String source,
    required String title,
    String? company,
    String? location,
  }) async {
    final candidate = DedupCandidate(
      source: source,
      title: title,
      company: company,
      location: location,
    );
    // On ne compare qu'aux offres des AUTRES sources : la règle les exige
    // différentes, autant ne pas charger le reste.
    final others = await (_db.select(_db.offers)
          ..where((o) => o.source.equals(source).not()))
        .get();

    for (final o in others) {
      final existing = DedupCandidate(
        source: o.source,
        title: o.title,
        company: o.company,
        location: o.location,
      );
      if (isCrossSourceDuplicate(candidate, existing)) return o;
    }
    return null;
  }

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

    // Rapprochement inter-sources AVANT le hash : une offre rediffusée d'une
    // source à l'autre a un hash différent (l'entreprise est nommée d'un côté,
    // vide de l'autre) et passerait donc deux fois. Voir dedup.dart pour
    // pourquoi la règle est délibérément étroite.
    final crossSource = await _findCrossSourceDuplicate(
      source: source,
      title: title,
      company: company,
      location: location,
    );
    if (crossSource != null) {
      return SaveResult(
        SaveOutcome.duplicate,
        offerId: crossSource.id,
        score: crossSource.score,
      );
    }

    // Dédup sur l'URL quand elle existe (identité stable des partages), sinon
    // sur le hash titre+entreprise+lieu. Voir dedupHash() pour le pourquoi.
    final hash = dedupHash(
      url: url,
      title: title,
      company: company,
      location: location,
    );

    // Un seul INSERT OR IGNORE : la contrainte UNIQUE sur le hash fait la
    // dédup, sans SELECT préalable ni fenêtre de course. Renvoie null si la
    // ligne existait déjà ; on ne paie le SELECT que dans ce cas-là.
    final row = await _db.into(_db.offers).insertReturningOrNull(
          OffersCompanion.insert(
            source: source,
            sourceId: Value(sourceId),
            hash: hash,
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
          mode: InsertMode.insertOrIgnore,
        );

    if (row == null) {
      final existing = await (_db.select(_db.offers)
            ..where((o) => o.hash.equals(hash)))
          .getSingle();
      return SaveResult(
        SaveOutcome.duplicate,
        offerId: existing.id,
        score: existing.score,
      );
    }

    return SaveResult(SaveOutcome.saved, offerId: row.id, score: annotated.score);
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
