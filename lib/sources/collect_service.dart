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
import '../data/profile_repository.dart';
import 'france_travail.dart';
import 'geo.dart';
import 'lba.dart';
import 'normalize.dart';

/// Bilan d'une collecte, affichable tel quel.
class CollectReport {
  const CollectReport({
    this.fetched = 0,
    this.saved = 0,
    this.duplicates = 0,
    this.excluded = 0,
    this.recruiters = 0,
    this.errors = const [],
  });

  /// Nombre d'offres remontées par les sources, avant déduplication.
  final int fetched;
  final int saved;
  final int duplicates;
  final int excluded;

  /// Entreprises à démarcher remontées par La Bonne Alternance. Ce ne sont pas
  /// des offres (aucun poste publié), donc elles ne sont pas enregistrées comme
  /// telles. On les compte pour ne pas perdre l'information.
  final int recruiters;

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
    final base = 'Collecte : ${parts.join(', ')} (sur $fetched).'
        '${recruiters > 0 ? ' $recruiters entreprise'
            '${recruiters > 1 ? 's' : ''} à démarcher (non enregistrées).' : ''}';
    return errors.isEmpty ? base : '$base ${errors.join(' ')}';
  }
}

class CollectService {
  CollectService({
    required AppDatabase db,
    required OffersRepository repository,
    required FranceTravailClient franceTravail,
    required LbaClient lba,
  })  // Les champs restent privés, et un paramètre nommé ne peut pas l'être :
      // l'initializing formal suggéré par le linter est ici impossible.
      // ignore: prefer_initializing_formals
      : _db = db,
        // ignore: prefer_initializing_formals
        _repository = repository,
        // ignore: prefer_initializing_formals
        _franceTravail = franceTravail,
        // ignore: prefer_initializing_formals
        _lba = lba;

  final AppDatabase _db;
  final OffersRepository _repository;
  final FranceTravailClient _franceTravail;
  final LbaClient _lba;

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

    var fetched = 0, saved = 0, duplicates = 0, excluded = 0, recruiters = 0;
    final errors = <String>[];

    // Toutes les offres des sources, dédoublonnées par identifiant avant même
    // de toucher la base : une même offre remonte souvent sur plusieurs termes,
    // et les offres partenaires apparaissent des deux côtés.
    final byId = <String, NormalizedOffer>{};
    void collectAll(Iterable<NormalizedOffer> found) {
      for (final o in found) {
        byId.putIfAbsent(
          o.sourceId.isNotEmpty ? o.sourceId : '${o.title}|${o.company}',
          () => o,
        );
      }
    }

    if (await _franceTravail.isConfigured) {
      try {
        // Une requête PAR mot-clé, et non une requête avec tous les mots.
        // France Travail fait un ET entre les termes de `motsCles` : vérifié le
        // 21/07/2026, « développeur python intelligence artificielle » près de
        // Valenciennes renvoyait 204 (zéro), là où « python » seul en donnait 7.
        // Les doublons entre requêtes sont absorbés par la dédup par hash.
        for (final term in _queryTerms(profile?.keywords)) {
          collectAll(await _franceTravail.search(
            keywords: term,
            communeInsee: profile?.locationInsee,
            radiusKm: profile?.radiusKm,
          ));
        }
      } on FranceTravailUnavailable catch (e) {
        errors.add(e.message);
      }
    } else {
      errors.add('France Travail : identifiants absents (réglages).');
    }

    // La Bonne Alternance : une recherche par commune, car elle prend des
    // coordonnées et non une liste de codes INSEE.
    if (await _lba.isConfigured) {
      try {
        final communes =
            ProfileCommunes.parse(profile?.locationLabel, profile?.locationInsee);
        final coords = await communeCoordinates(communes.codes);
        if (coords.isEmpty) {
          errors.add('La Bonne Alternance : aucune commune localisable.');
        }
        for (final point in coords.values) {
          final result = await _lba.search(
            latitude: point.latitude,
            longitude: point.longitude,
            radiusKm: profile?.radiusKm ?? 30,
            romeCodes: profile?.romeCodes ?? kDefaultRomeCodes,
          );
          collectAll(result.jobs);
          recruiters += result.recruiterCount;
        }
      } on LbaUnavailable catch (e) {
        errors.add(e.message);
      }
    }

    // Enregistrement unique, toutes sources confondues.
    fetched += byId.length;
    for (final o in byId.values) {
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

    return CollectReport(
      fetched: fetched,
      saved: saved,
      duplicates: duplicates,
      excluded: excluded,
      recruiters: recruiters,
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

  /// Découpe les mots-clés du profil en **requêtes séparées**, une par terme.
  ///
  /// France Travail fait un ET entre les mots de `motsCles`, et n'en accepte
  /// que trois au maximum. Envoyer toute la liste du profil revient donc à ne
  /// rien trouver.
  ///
  /// La virgule sépare les recherches, ce qui préserve les expressions comme
  /// « intelligence artificielle ». **Sans virgule, on sépare sur les espaces** :
  /// quelqu'un qui tape « développeur python ia » veut trois recherches, pas une
  /// offre contenant les trois mots. Sans cette règle, il obtient zéro résultat
  /// sans comprendre pourquoi (constat du 21/07/2026, sur cette même saisie).
  static List<String> _queryTerms(String? keywords) {
    final raw = (keywords ?? '').trim();
    if (raw.isEmpty) return _defaultTerms;

    final parts = raw.contains(',') ? raw.split(',') : raw.split(RegExp(r'\s+'));
    final terms = parts
        .map((t) => t.trim().split(RegExp(r'\s+')).take(3).join(' '))
        .where((t) => t.isNotEmpty)
        .toList();

    if (terms.isEmpty) return _defaultTerms;
    // Chaque terme est un appel réseau : on borne pour ne pas transformer un
    // appui sur « Collecter » en dizaine de requêtes.
    return terms.take(_maxQueries).toList();
  }

  static const _maxQueries = 5;

  /// Repli quand le profil n'existe pas encore : des termes larges, chacun
  /// interrogé séparément.
  static const _defaultTerms = ['développeur', 'python', 'intelligence artificielle'];
}
