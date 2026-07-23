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

  /// Ce qu'il faut connaître d'une offre déjà en base pour la comparer, et
  /// rien de plus.
  ///
  /// La comparaison se fait en Dart et non en SQL : `canonTitle` et `canonCity`
  /// ne sont pas exprimables en SQLite sans dupliquer leur logique. Mais charger
  /// les lignes **entières** serait coûteux : la description d'une offre France
  /// Travail pèse environ 2,4 ko, et cette requête repart à chaque
  /// enregistrement. Sur une collecte de 150 offres avec 125 déjà en base, cela
  /// représentait une quarantaine de mégaoctets de texte alloués pour rien.
  Future<({int id, int? score})?> _findCrossSourceDuplicate({
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

    final t = _db.offers;
    // On ne compare qu'aux offres des AUTRES sources (la règle les exige
    // différentes), et on ne lit que les cinq colonnes qui servent.
    final query = _db.selectOnly(t)
      ..addColumns([t.id, t.source, t.title, t.company, t.location, t.score])
      ..where(t.source.equals(source).not());

    for (final row in await query.get()) {
      final existing = DedupCandidate(
        source: row.read(t.source) ?? '',
        title: row.read(t.title) ?? '',
        company: row.read(t.company),
        location: row.read(t.location),
      );
      if (isCrossSourceDuplicate(candidate, existing)) {
        return (id: row.read(t.id)!, score: row.read(t.score));
      }
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
