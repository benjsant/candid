---
title: Architecture
---

# Architecture

[← Retour](index.html)

Candid est une application Flutter mono-processus, sans backend. L'organisation
suit six couches, et **la direction des dépendances est vérifiée**, pas
seulement souhaitée.

## Les couches

| Couche | Fichiers | Lignes | Rôle |
|---|---:|---:|---|
| `domain/` | 3 | 400 | logique pure : normalisation, hash, scoring, rapprochement |
| `data/` | 7 | 930 | base SQLite (drift), dépôts, export, digest |
| `sources/` | 6 | 1 043 | partage Android, France Travail, LBA, géocodage, collecte |
| `agent/` | 7 | 1 009 | le graphe LLM et ses garde-fous |
| `render/` | 4 | 732 | CV et lettre en PDF |
| `ui/` | 8 | 1 905 | les écrans |
| `core/` | 4 | 298 | secrets, préférences, notifications, assets |
| `background/` | 1 | 168 | tâches `workmanager` |

Le code généré par `drift` (6 506 lignes) n'est pas compté : il n'est pas écrit
à la main et ne se relit pas.

## La règle de dépendance

```
        ui/  ──────────────┐
         │                 │
         ▼                 ▼
  sources/ ─── agent/ ─── render/
         │       │         │
         └───────┼─────────┘
                 ▼
              data/
                 │
                 ▼
             domain/          (aucune dépendance sortante)
```

**`domain/` ne dépend de rien** — pas même de Flutter. C'est ce qui rend le
scoring, le hash et le rapprochement testables en quelques millisecondes, sans
émulateur ni base. Cette pureté est vérifiée : aucun `import 'package:flutter/'`
n'y figure.

Aucune couche basse n'importe `ui/`. Vérifié pour `domain/`, `data/`,
`sources/`, `agent/` et `render/`.

## Injection des dépendances

Pas de conteneur, pas de `get_it`, pas de `provider`. Les dépendances sont
**passées par constructeur** depuis `main.dart`, qui est le seul endroit où
l'application se câble.

Ce choix a une conséquence directe et voulue : **tout ce qui sort sur le réseau
est injectable**, donc testable sans réseau.

```dart
CollectService(
  db: db,
  repository: OffersRepository(db),
  franceTravail: FranceTravailClient(secrets: secrets),
  lba: LbaClient(secrets: secrets),
  geocoder: communeCoordinates,   // injectable
)
```

> **Un défaut trouvé par un test.** `CollectService` appelait initialement
> `communeCoordinates` en fonction globale. Toute la branche La Bonne Alternance
> devenait alors intestable : en test, l'accès réseau est coupé et la fonction
> rendait une liste vide, ce qui faisait échouer un test pourtant correct.
> Le géocodeur a été rendu injectable. Un test qui échoue pour de mauvaises
> raisons signale souvent un vrai problème de conception.

## Les deux isolats

L'application tourne dans **deux isolats Dart distincts**, qui ne partagent
rien :

| | Isolat principal | Isolat de fond (`workmanager`) |
|---|---|---|
| Déclenché par | l'utilisateur | Android, une fois par jour |
| Base | ouverte au démarrage | **rouverte puis refermée** |
| Coffre-fort | instance de l'UI | instance propre |

La fermeture de la base dans l'isolat de fond n'est pas un détail : sans elle,
le fichier SQLite reste verrouillé et l'application principale ne peut plus
écrire. Elle est en `finally`, donc garantie même en cas d'erreur.

## Ce qui ne dépend d'aucun serveur

Il n'y a **ni backend, ni compte, ni synchronisation**. Les conséquences sont
assumées :

- **Tout l'historique vit sur le téléphone.** D'où l'export JSON de l'onglet
  Suivi, qui est le seul filet de sécurité.
- **Les clés API sont celles de l'utilisateur**, saisies par lui, stockées dans
  le Keystore Android. Voir [Sécurité](securite.html).
- **Aucune donnée n'est agrégée ailleurs.** Personne, pas même l'auteur, ne voit
  les candidatures.

[← Retour](index.html) · [Modèle de données →](donnees.html)
