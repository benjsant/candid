/// Le profil de recherche : ce que l'utilisateur cherche, et où.
///
/// Il pilote deux choses distinctes, et c'est important de ne pas les confondre :
///  - la **requête** envoyée aux sources (mots-clés, commune INSEE, rayon) :
///    c'est lui qui évite de ratisser toute la France ;
///  - le **scoring local** (mots-clés, indispensables, exclusions, séniorité),
///    via `Prefs.fromProfile`.
///
/// L'application n'en gère qu'un seul, actif. Le schéma en accepte plusieurs
/// (parité avec le Postgres d'origine), mais une interface multi-profils sur
/// mobile serait de la complexité sans usage.
library;

import 'package:drift/drift.dart';

import 'database.dart';

/// Nom du profil unique. Constant : l'utilisateur ne le voit pas, il n'a pas à
/// le nommer.
const kDefaultProfileName = 'principal';

/// Séparateur des libellés de communes. Volontairement différent de la virgule,
/// qui sert aux **codes** : « Valenciennes (59) » n'en contient pas, mais un
/// libellé futur pourrait, et on ne veut pas d'ambiguïté à la relecture.
const _labelSeparator = ' ; ';

/// Les communes du profil, telles que stockées.
///
/// Plusieurs communes tiennent dans les colonnes existantes : les codes sont
/// joints par des virgules, ce qui est **exactement** ce qu'attend le paramètre
/// `commune` de France Travail (vérifié le 21/07/2026 : `59606,31555` renvoie
/// bien des offres des deux départements, c'est une union). Aucun changement de
/// schéma, donc aucune migration à écrire alors qu'une installation réelle
/// existe déjà sur le téléphone.
class ProfileCommunes {
  const ProfileCommunes(this.labels, this.codes);

  final List<String> labels;
  final List<String> codes;

  bool get isEmpty => codes.isEmpty;
  int get length => codes.length;

  /// Ce qui part dans la requête : « 59606,59350 ».
  String get query => codes.join(',');

  static ProfileCommunes parse(String? labels, String? codes) {
    final c = (codes ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final l = (labels ?? '')
        .split(_labelSeparator)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    // Les deux listes doivent rester alignées : si un stockage ancien ou abîmé
    // les désaccorde, on retombe sur le code, qui est ce qui compte.
    return ProfileCommunes(
      l.length == c.length ? l : c,
      c,
    );
  }

  String get storedLabels => labels.join(_labelSeparator);
  String get storedCodes => codes.join(',');
}

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  /// Le profil actif, ou `null` s'il n'a jamais été créé.
  Future<SearchProfile?> active() {
    final query = _db.select(_db.searchProfiles)
      ..where((p) => p.active.equals(true))
      ..orderBy([(p) => OrderingTerm(expression: p.id, mode: OrderingMode.asc)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Stream<SearchProfile?> watchActive() {
    final query = _db.select(_db.searchProfiles)
      ..where((p) => p.active.equals(true))
      ..orderBy([(p) => OrderingTerm(expression: p.id, mode: OrderingMode.asc)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  /// Crée ou met à jour le profil. Les champs vides sont stockés `null` plutôt
  /// que chaîne vide : un rayon ou une commune absents doivent *disparaître* de
  /// la requête, pas y être envoyés vides.
  Future<void> save({
    required String keywords,
    String? locationLabel,
    String? locationInsee,
    int? radiusKm,
    String? contractTypes,
    String? seniority,
    String? mustHave,
    String? exclusions,
  }) async {
    String? clean(String? v) {
      final t = v?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    final existing = await active();
    final companion = SearchProfilesCompanion(
      name: Value(existing?.name ?? kDefaultProfileName),
      keywords: Value(keywords.trim()),
      locationLabel: Value(clean(locationLabel)),
      locationInsee: Value(clean(locationInsee)),
      radiusKm: Value(radiusKm),
      contractTypes: Value(clean(contractTypes)),
      seniority: Value(clean(seniority)),
      mustHave: Value(clean(mustHave)),
      exclusions: Value(clean(exclusions)),
      active: const Value(true),
    );

    if (existing == null) {
      await _db.into(_db.searchProfiles).insert(companion);
    } else {
      await (_db.update(_db.searchProfiles)
            ..where((p) => p.id.equals(existing.id)))
          .write(companion);
    }
  }
}
