---
title: Modèle de données
---

# Modèle de données

[← Retour](index.html)

Base **SQLite locale** via [drift](https://drift.simonbinder.eu/). Le schéma est
porté depuis le PostgreSQL du projet Docker `job_hunter`, index compris.

## Les tables

| Table | Colonnes | Rôle |
|---|---:|---|
| `search_profiles` | 16 | ce qu'on cherche, et où |
| `offers` | 17 | les offres, collectées ou partagées |
| `companies` | 13 | les entreprises à démarcher (candidature spontanée) |
| `applications` | 14 | le suivi des candidatures |
| `generated_documents` | 5 | les PDF produits |

**La table `profile` du schéma d'origine n'est pas portée.** Le profil candidat
vit dans `assets/cv/*.json`, en données statiques embarquées : il ne change pas
au fil de l'usage, une table serait de la complexité sans contrepartie.

## Les index

```
idx_offers_status         (status)
idx_offers_created_at     (created_at)
idx_offers_company_canon  (company_canon)
```

Ils ne sont pas décoratifs. `watchInbox()` filtre par statut et trie par
score puis date, dans un `Stream` réévalué **à chaque écriture**. Sans index,
chaque insertion d'une collecte de 150 offres rebalayait toute la table.

## Déduplication : trois niveaux

C'est le mécanisme le plus subtil du projet, et celui qui a le plus évolué au
contact du réel.

### 1. Hash d'unicité

Une contrainte `UNIQUE` sur `offers.hash`, alimentée par `dedupHash()` :

- **si l'offre a une URL** : `sha256('url:' + urlCanonique)` — l'URL est
  l'identité la plus stable d'une annonce ;
- **sinon** : `sha256(titre + entreprise + lieu)`, canonicalisés (minuscules,
  accents repliés, « (H/F) » retiré).

L'insertion se fait en `INSERT OR IGNORE` : **un seul aller-retour**, pas de
`SELECT` préalable, donc pas de fenêtre de course.

> Vérifié sur appareil le 20/07/2026 : deux partages de la même URL France
> Travail, avec le titre saisi différemment (« Dev IA » puis
> « Developpeur IA H/F »), produisent **une seule entrée**.

### 2. Déduplication intra-collecte

Une même offre remonte souvent sur plusieurs mots-clés (« développeur » et
« python »). Les résultats sont dédoublonnés **par identifiant de source avant
d'atteindre la base**.

Sans cela le bilan annonçait « 2 nouvelles sur 6 » : exact, mais
incompréhensible.

### 3. Rapprochement inter-sources

Le cas qui échappe au hash : La Bonne Alternance **rediffuse** les offres
France Travail, sans le nom de l'employeur. Deux hash différents pour une seule
offre.

La règle est volontairement étroite — voir [Sources](sources.html#rapprochement-inter-sources)
pour le raisonnement complet et les données qui l'ont dictée.

## Migrations

**Le schéma est en version 2**, et des installations réelles tournent. Toute
évolution exige d'incrémenter `schemaVersion` **et** d'écrire son cas dans
`MigrationStrategy`.

```dart
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.addColumn(companies, companies.siret);
    await m.addColumn(companies, companies.location);
    await m.addColumn(companies, companies.source);
  }
}
```

### Le protocole, éprouvé le 22/07/2026

La v1 → v2 a été la première migration écrite avec des données réelles en jeu.
La méthode qui a fonctionné, à reprendre :

1. **Sauvegarder la base de l'appareil avant** (`adb exec-out run-as … cat`).
2. **N'ajouter que des colonnes nullables** — aucune donnée existante n'est
   touchée, aucune valeur par défaut à inventer.
3. **Vérifier les comptes après** : 125 offres, 1 candidature, 1 profil,
   `user_version` passée à 2. Tous intacts.

> `PRAGMA foreign_keys = ON` est posé dans `beforeOpen`. Sans lui, SQLite
> **ignore silencieusement** les clés étrangères.

## Ce que l'export contient

L'export JSON de l'onglet Suivi emporte les tables `offers` et `applications`,
avec un en-tête (`schema_version`, `exported_at`). **Il ne contient aucune clé
API.**

Le fichier temporaire est **effacé après le partage**, ainsi que les exports
d'anciennes versions restés en cache. Voir [Sécurité](securite.html).

[← Architecture](architecture.html) · [L'agent →](agent.html)
