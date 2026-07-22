/// Les entreprises « à démarcher » : celles que La Bonne Alternance signale
/// comme embauchant, **sans offre publiée**.
///
/// Garde-fou central de ce fichier : ce ne sont pas des offres. Il n'y a ni
/// intitulé de poste, ni description, ni salaire, et il ne faut surtout pas en
/// fabriquer. L'application dit « cette entreprise recrute dans votre domaine,
/// à vous de la contacter », pas « voici un poste ».
///
/// Conséquence directe : elles ne passent pas par le scoring (il n'y a rien à
/// scorer) et ne rejoignent pas la boîte aux offres.
library;

import 'package:drift/drift.dart';

import '../sources/normalize.dart';
import 'database.dart';

/// D'où vient une fiche. Une entreprise collectée ne doit pas écraser une
/// entreprise que l'utilisateur aurait saisie ou annotée lui-même.
const kSourceLba = 'la_bonne_alternance';

class CompaniesRepository {
  CompaniesRepository(this._db);

  final AppDatabase _db;

  /// Enregistre les entreprises remontées par une collecte.
  ///
  /// Déduplication : le **SIRET** d'abord, qui est la seule identité fiable
  /// (deux établissements peuvent porter le même nom commercial), le nom
  /// ensuite quand le SIRET manque. Rend le nombre de fiches réellement
  /// nouvelles.
  Future<int> saveAll(List<NormalizedRecruiter> recruiters) async {
    var created = 0;
    for (final r in recruiters) {
      if (r.name.trim().isEmpty) continue; // sans nom, la fiche ne sert à rien
      if (await _upsert(r)) created++;
    }
    return created;
  }

  Future<bool> _upsert(NormalizedRecruiter r) async {
    final existing = await _find(siret: r.siret, name: r.name);

    final companion = CompaniesCompanion(
      name: Value(r.name),
      siret: Value(_orNull(r.siret)),
      sector: Value(_orNull(r.sector)),
      website: Value(_orNull(r.website)),
      location: Value(_orNull(r.location)),
      applyUrl: Value(_orNull(r.applyUrl)),
      phone: Value(_orNull(r.phone)),
      email: Value(_orNull(r.email)),
      source: const Value(kSourceLba),
      lastUpdated: Value(DateTime.now()),
    );

    if (existing == null) {
      await _db.into(_db.companies).insert(companion);
      return true;
    }

    // Une fiche saisie ou enrichie à la main n'est jamais écrasée par une
    // collecte : on ne rafraîchit que ce qui vient déjà de la même source.
    if (existing.source != kSourceLba) return false;

    await (_db.update(_db.companies)..where((c) => c.id.equals(existing.id)))
        .write(companion);
    return false;
  }

  Future<Company?> _find({required String siret, required String name}) async {
    if (siret.trim().isNotEmpty) {
      final bySiret = await (_db.select(_db.companies)
            ..where((c) => c.siret.equals(siret.trim()))
            ..limit(1))
          .getSingleOrNull();
      if (bySiret != null) return bySiret;
    }
    return (_db.select(_db.companies)
          ..where((c) => c.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Les entreprises à démarcher, les plus récemment vues d'abord.
  Stream<List<Company>> watchAll() {
    final query = _db.select(_db.companies)
      ..orderBy([
        (c) => OrderingTerm(
            expression: c.lastUpdated, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.companies)..where((c) => c.id.equals(id))).go();

  static String? _orNull(String v) => v.trim().isEmpty ? null : v.trim();
}
