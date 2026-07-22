---
title: Candid
---

# Documentation technique

**Candid** est un assistant de candidature Android **entièrement autonome** :
pas de serveur, pas d'hébergement. Tout tourne sur le téléphone, et les seuls
appels sortants vont vers des API publiques.

Cette documentation décrit **ce que le code fait réellement**. Les chiffres
qu'elle contient ont été mesurés, pas estimés ; les pièges qu'elle signale ont
été rencontrés en conditions réelles, avec leur date.

---

## Le contrat

> L'assistant de candidature qui ne brode jamais. Il ne vous invente ni
> compétence, ni expérience, et n'envoie rien sans vous.

Ce n'est pas une accroche marketing, c'est une contrainte d'ingénierie. Trois
règles ne se négocient jamais :

1. **Ne rien inventer** — aucune compétence, expérience, certification ou
   mission qui ne figure pas déjà dans le CV maître.
2. **Ne rien envoyer** — l'application produit des PDF et s'arrête là.
   L'utilisateur relit, puis envoie lui-même depuis sa messagerie.
3. **Ne rien modifier sans validation** — les données personnelles restent
   sous contrôle de l'utilisateur.

Ces règles sont tenues par **du code testé**, pas par de la discipline : voir
[les garde-fous de l'agent](agent.html#les-garde-fous) et
[le rapprochement des doublons](sources.html#rapprochement-inter-sources).
Les contourner fait tomber des tests. C'est délibéré.

---

## Le parcours

```
offre partagée depuis LinkedIn / France Travail / WTTJ
        │
        ├─ résolution de l'URL (France Travail) ──── titre, entreprise, description
        │
        ▼
  normalisation → déduplication → scoring local (0-100)
        │
        ▼
  agent LLM : analyse → grounding INSEE → accroche → juge → validation
        │
        ▼
  CV ciblé + lettre, en PDF, sur l'appareil
        │
        ▼
  relecture humaine → envoi manuel → suivi de candidature
```

Secondairement, l'application **collecte aussi toute seule** (France Travail,
La Bonne Alternance) et notifie.

---

## Les pages

| Page | Contenu |
|---|---|
| [Architecture](architecture.html) | les couches, leurs dépendances, et pourquoi elles tiennent |
| [Modèle de données](donnees.html) | schéma, index, migrations, déduplication |
| [L'agent](agent.html) | le graphe à cinq nœuds, les garde-fous, le grounding |
| [Les sources](sources.html) | partage Android, France Travail, La Bonne Alternance, géocodage |
| [Sécurité et vie privée](securite.html) | audit complet, ce qui sort de l'appareil, ce qui reste |
| [Qualité et tests](qualite.html) | couverture mesurée, ce qui n'est pas testé, et pourquoi |
| [Décisions](decisions.html) | les choix structurants, avec leur raison et leur date |

---

## En un coup d'œil

| | |
|---|---|
| **Code** | 6 816 lignes écrites à la main (+ 6 506 générées) |
| **Tests** | 169 tests, **80,4 %** de couverture hors interface |
| **Analyse statique** | zéro avertissement |
| **Dette signalée** | aucun `TODO`, `FIXME` ni `HACK` |
| **Dépendances directes** | 16, toutes à jour |
| **Permissions Android** | 7, aucune dangereuse |
| **Schéma** | version 2, migration écrite et vérifiée |

Mesuré le 22 juillet 2026 sur `flutter test --coverage` et `flutter pub outdated`.
