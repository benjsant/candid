/// Collecte : interroge les sources, normalise, et enregistre via le dépôt
/// d'offres (qui déduplique par hash).
///
/// Ce service est volontairement **déclenché à la main** pour l'instant (bouton
/// « Collecter »). La collecte périodique par `workmanager` viendra ensuite :
/// le PLAN la place en dernier parce que les surcouches constructeur (ColorOS,
/// MIUI, One UI) tuent les tâches de fond, et qu'il ne faut pas que ce risque
/// bloque une fonctionnalité par ailleurs utilisable.
library;

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm;

import '../data/database.dart';
import '../data/offers_repository.dart';
import '../domain/scoring.dart';
import 'france_travail.dart';

/// Bilan d'une collecte, affichable tel quel.
class CollectReport {
  const CollectReport({
    this.fetched = 0,
    this.saved = 0,
    this.duplicates = 0,
    this.excluded = 0,
    this.errors = const [],
  });

  /// Nombre d'offres remontées par les sources, avant déduplication.
  final int fetched;
  final int saved;
  final int duplicates;
  final int excluded;

  /// Sources en échec, avec leur message. Une source qui tombe n'annule pas
  /// les autres : on collecte ce qu'on peut et on le dit.
  final List<String> errors;

  bool get isEmpty => fetched == 0 && errors.isEmpty;

  /// Résumé en français, pour la SnackBar.
  String get summary {
    if (errors.isNotEmpty && fetched == 0) return errors.join(' ');
    final parts = <String>[
      '$saved nouvelle${saved > 1 ? 's' : ''}',
      if (duplicates > 0) '$duplicates déjà connue${duplicates > 1 ? 's' : ''}',
      if (excluded > 0) '$excluded écartée${excluded > 1 ? 's' : ''}',
    ];
    final base = 'Collecte : ${parts.join(', ')} (sur $fetched).';
    return errors.isEmpty ? base : '$base ${errors.join(' ')}';
  }
}

class CollectService {
  CollectService({
    required AppDatabase db,
    required OffersRepository repository,
    required FranceTravailClient franceTravail,
  })  // Les champs restent privés, et un paramètre nommé ne peut pas l'être :
      // l'initializing formal suggéré par le linter est ici impossible.
      // ignore: prefer_initializing_formals
      : _db = db,
        // ignore: prefer_initializing_formals
        _repository = repository,
        // ignore: prefer_initializing_formals
        _franceTravail = franceTravail;

  final AppDatabase _db;
  final OffersRepository _repository;
  final FranceTravailClient _franceTravail;

  /// Lance une collecte sur toutes les sources configurées.
  Future<CollectReport> collect() async {
    final profile = await _activeProfile();
    final prefs = profile == null
        ? const Prefs()
        : Prefs.fromProfile(
            keywords: profile.keywords,
            mustHave: profile.mustHave,
            exclusions: profile.exclusions,
            contractTypes: profile.contractTypes,
            seniority: profile.seniority,
          );

    var fetched = 0, saved = 0, duplicates = 0, excluded = 0;
    final errors = <String>[];

    if (await _franceTravail.isConfigured) {
      try {
        final offers = await _franceTravail.search(
          keywords: profile?.keywords ?? _defaultKeywords,
          communeInsee: profile?.locationInsee,
          radiusKm: profile?.radiusKm,
        );
        fetched += offers.length;
        for (final o in offers) {
          final result = await _repository.save(
            source: o.source,
            title: o.title,
            company: o.company,
            location: o.location,
            description: o.description,
            url: o.url,
            contractType: o.contractType,
            salary: o.salary,
            sourceId: o.sourceId,
            prefs: prefs,
          );
          switch (result.outcome) {
            case SaveOutcome.saved:
              saved++;
            case SaveOutcome.duplicate:
              duplicates++;
            case SaveOutcome.excluded:
              excluded++;
          }
        }
      } on FranceTravailUnavailable catch (e) {
        errors.add(e.message);
      }
    } else {
      errors.add(
        'France Travail : identifiants absents (réglages).',
      );
    }

    return CollectReport(
      fetched: fetched,
      saved: saved,
      duplicates: duplicates,
      excluded: excluded,
      errors: errors,
    );
  }

  /// Le profil de recherche actif, s'il en existe un. Tant qu'aucun écran ne
  /// permet d'en créer, la collecte tourne sur les valeurs par défaut du
  /// scoring : c'est dégradé mais utilisable, pas bloquant.
  Future<SearchProfile?> _activeProfile() async {
    final query = _db.select(_db.searchProfiles)
      ..where((p) => p.active.equals(true))
      ..orderBy([(p) => OrderingTerm(expression: p.id, mode: OrderingMode.asc)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Requête de repli : les mots-clés du scoring, qui décrivent déjà le profil
  /// visé. On ne cherche pas à deviner autre chose.
  static const _defaultKeywords = 'développeur python intelligence artificielle';
}
