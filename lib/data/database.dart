/// Base locale (SQLite via drift). Port consolidé de `reference/schema.sql`.
///
/// Le schéma PostgreSQL d'origine porte des années de migrations successives
/// (des `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` empilés). On reprend ici
/// l'état final, à plat, sans deux choses qui n'ont pas de sens sur mobile :
///  - la colonne `embedding vector(384)` (pgvector) : la dédup sémantique est
///    hors V1, et il n'y a pas d'index vectoriel en SQLite ;
///  - `applications.airtable_id` : pas de synchronisation externe.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Statuts d'une offre, repris tels quels du projet Docker.
class OfferStatus {
  static const newOffer = 'new';
  static const reviewed = 'reviewed';
  static const selected = 'selected';
  static const ignored = 'ignored';
  static const applied = 'applied';
  static const all = [newOffer, reviewed, selected, ignored, applied];
}

/// Statuts d'une candidature.
class ApplicationStatus {
  static const draft = 'draft';
  static const sent = 'sent';
  static const interview = 'interview';
  static const rejected = 'rejected';
  static const accepted = 'accepted';
  static const all = [draft, sent, interview, rejected, accepted];
}

/// Origine d'une candidature : réponse à une offre, ou démarchage spontané.
class ApplicationKind {
  static const offer = 'offer';
  static const spontaneous = 'spontaneous';
  static const all = [offer, spontaneous];
}

/// Configurations de recherche (multi-profils). Le collecteur boucle sur les
/// profils actifs.
class SearchProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get keywords => text()();
  TextColumn get locationInsee => text().nullable()();
  TextColumn get locationLabel => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get romeCodes => text().nullable()();
  IntColumn get radiusKm => integer().nullable()();
  TextColumn get contractTypes => text().nullable()();
  TextColumn get seniority => text().nullable()();
  TextColumn get mustHave => text().nullable()();
  TextColumn get exclusions => text().nullable()();
  IntColumn get scoreThreshold =>
      integer().withDefault(const Constant(60))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Offres collectées ou reçues par partage.
///
/// `hash` = SHA256 du titre, de l'entreprise et du lieu canonicalisés. C'est la
/// clé de déduplication : une offre déjà connue est ignorée.
/// `companyCanon` sert aux rapprochements entre sources.
///
/// Index : parité avec le schéma Postgres d'origine (idx_offers_*). Sans eux,
/// `watchInbox()` (filtre statut + tri score/date) balaierait toute la table à
/// chaque rafraîchissement du stream, à chaque écriture.
@TableIndex(name: 'idx_offers_status', columns: {#status})
@TableIndex(name: 'idx_offers_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_offers_company_canon', columns: {#companyCanon})
class Offers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `france_travail`, `lba`, ou `shared` (reçue par partage Android).
  TextColumn get source => text()();
  TextColumn get sourceId => text().nullable()();
  TextColumn get hash => text().unique()();
  TextColumn get title => text()();
  TextColumn get company => text().nullable()();
  TextColumn get companyCanon => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get contractType => text().nullable()();
  TextColumn get salary => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get score => integer().nullable()();
  TextColumn get scoreReason => text().nullable()();
  IntColumn get profileId => integer()
      .nullable()
      .references(SearchProfiles, #id, onDelete: KeyAction.setNull)();
  TextColumn get status =>
      text().withDefault(const Constant(OfferStatus.newOffer))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Entreprises, enrichies par l'étape `research` de l'agent.
class Companies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get website => text().nullable()();
  TextColumn get sector => text().nullable()();
  TextColumn get description => text().nullable()();

  /// Ajoutés en v2 pour les entreprises « à démarcher » de La Bonne Alternance.
  /// Le SIRET est la seule identité fiable : deux établissements peuvent porter
  /// le même nom commercial.
  TextColumn get siret => text().nullable()();
  TextColumn get location => text().nullable()();

  /// D'où vient la fiche (`la_bonne_alternance`). Une entreprise saisie à la
  /// main un jour ne devra pas être écrasée par une collecte.
  TextColumn get source => text().nullable()();

  /// Résumé produit par l'agent, toujours fondé sur une source réelle.
  TextColumn get aiSummary => text().nullable()();
  TextColumn get applyUrl => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}

/// Candidatures. `appliedAt` n'est renseigné que lorsque l'utilisateur déclare
/// avoir envoyé lui-même : l'application n'envoie jamais rien.
class Applications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get offerId => integer()
      .nullable()
      .references(Offers, #id, onDelete: KeyAction.setNull)();
  IntColumn get companyId => integer()
      .nullable()
      .references(Companies, #id, onDelete: KeyAction.setNull)();
  TextColumn get kind =>
      text().withDefault(const Constant(ApplicationKind.offer))();
  TextColumn get status =>
      text().withDefault(const Constant(ApplicationStatus.draft))();

  /// Copies figées au moment de la candidature : l'offre peut disparaître, la
  /// trace du suivi doit rester lisible.
  TextColumn get poste => text().nullable()();
  TextColumn get entreprise => text().nullable()();
  TextColumn get lien => text().nullable()();
  IntColumn get score => integer().nullable()();

  DateTimeColumn get appliedAt => dateTime().nullable()();
  DateTimeColumn get responseAt => dateTime().nullable()();
  DateTimeColumn get remindedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// CV et lettre produits pour une candidature (chemins locaux sur l'appareil).
class GeneratedDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId =>
      integer().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get cvPath => text().nullable()();
  TextColumn get letterPath => text().nullable()();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    SearchProfiles,
    Offers,
    Companies,
    Applications,
    GeneratedDocuments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.executor);

  /// v2 (22/07/2026) : `companies` gagne siret, location et source, pour les
  /// entreprises à démarcher remontées par La Bonne Alternance.
  ///
  /// **Première migration écrite avec des installations réelles en service.**
  /// Elle ajoute des colonnes nullables, donc aucune donnée existante n'est
  /// touchée ni perdue. Toute évolution ultérieure doit incrémenter ce numéro
  /// ET ajouter son cas ici : sauter cette étape corromprait les bases
  /// installées de façon silencieuse.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(companies, companies.siret);
            await m.addColumn(companies, companies.location);
            await m.addColumn(companies, companies.source);
          }
        },
        beforeOpen: (details) async {
          // Sans ça, SQLite ignore silencieusement les clés étrangères.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _open() =>
      driftDatabase(name: 'candid', native: const DriftNativeOptions());
}
