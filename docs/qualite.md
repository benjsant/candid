---
title: Qualité et tests
---

# Qualité et tests

[← Retour](index.html)

Mesures du **22 juillet 2026**, obtenues par `flutter test --coverage`,
`flutter analyze` et `flutter pub outdated`.

## Couverture réelle

Code généré par `drift` exclu, car il n'est pas écrit à la main et le compter
gonflerait artificiellement le dénominateur.

| Couche | Lignes couvertes | Taux |
|---|---:|---:|
| `domain/` | 124 / 124 | **100,0 %** |
| `render/` | 338 / 371 | **91,1 %** |
| `sources/` | 296 / 333 | **88,9 %** |
| `agent/` | 243 / 305 | **79,7 %** |
| `data/` | 200 / 323 | **61,9 %** |
| `core/` | 17 / 59 | **28,8 %** |
| **Total** | **1 218 / 1 515** | **80,4 %** |

La hiérarchie n'est pas un accident : **plus une couche est pure, plus elle est
couverte**. `domain/` ne dépend de rien, donc rien n'empêche de le tester
exhaustivement.

## Ce qui n'est pas testé, et pourquoi

Il serait malhonnête d'annoncer 80 % sans dire ce que ce chiffre exclut.

### L'interface : zéro test

Les huit écrans n'ont **aucun test de widget**. C'est un choix, pas un oubli :

- ils sont **vérifiés sur un appareil réel**, capture à l'appui, à chaque étape
  du plan de construction ;
- un test de widget vérifie qu'un bouton existe, pas que le partage depuis
  LinkedIn fonctionne, or c'est cela qui compte ici.

C'est une dette assumée. Elle deviendrait coûteuse si l'interface se
complexifiait.

### Le code lié aux plugins

`secrets.dart` (42 %), `notifications.dart` (40 %), `assets.dart` (5 %),
`app_prefs.dart` (0 %) : ils appellent des canaux de plateforme qui n'existent
pas en test unitaire.

La partie *logique* de ces modules est extraite en fonctions pures et testée à
part. `collectNotification()` et `digestNotification()` en sont l'exemple :
**16 tests** portent sur le texte des notifications, sans jamais toucher au
plugin.

### La tâche de fond

`collect_task.dart` n'est pas couvert : il orchestre un isolat Android.
Vérifié sur appareil, application fermée, avec la notification reçue en preuve.

## Répartition des 169 tests

| Domaine | Tests |
|---|---:|
| Logique métier (`domain`) | 18 |
| Garde-fous de l'agent | 18 |
| France Travail | 14 |
| Digest | 10 |
| Normalisation, géocodage, rapprochement | 27 |
| Collecte | 9 |
| Dépôts (offres, candidatures, profils, entreprises) | 25 |
| Partage, lettre, rendu | 16 |
| Agent (graphe, client, grounding) | 16 |
| Base et migrations | 4 |

**Ce que les tests protègent en priorité** : les garde-fous anti-invention (18),
et les règles de déduplication (27). Ce sont les endroits où une régression
serait invisible à l'œil nu et grave pour l'utilisateur.

### Des tests écrits contre le réel

Beaucoup de cas ne viennent pas d'une imagination de développeur mais d'un
constat daté, et le test le dit :

```dart
test('MÊME SOURCE : jamais fusionnées, même si tout se ressemble', () {
  // Cas réel : quatre « Développeur / Développeuse web (H/F) » à Lille,
  // tous chez France Travail, publiés par des agences différentes.
  ...
```

## Analyse statique

```
flutter analyze  →  No issues found!
```

**Zéro avertissement** est la règle du projet, pas un objectif. Six directives
`// ignore:` figurent dans le code, toutes pour la même raison documentée : un
paramètre nommé ne peut pas être privé en Dart, donc l'`initializing formal`
suggéré par le linter est impossible.

## Dette technique

| Indicateur | Valeur |
|---|---|
| `TODO` / `FIXME` / `HACK` | **aucun** |
| Dépendances directes en retard | **aucune** (16 à jour) |
| Ratio test / code | 2 754 / 6 816 = **0,40** |
| Violations de couches | **aucune** |

Les dépendances transitives en retard (analyzer, meta, vector_math…) sont
bloquées par les contraintes de Flutter lui-même : rien à faire côté projet.

## Le cycle

```bash
flutter analyze     # zéro avertissement attendu
flutter test        # 169 tests, quelques secondes

# OBLIGATOIRE après toute modification de lib/data/database.dart
dart run build_runner build --delete-conflicting-outputs
```

Oublier `build_runner` après un changement de schéma casse la compilation de
façon confuse : l'erreur pointe rarement le vrai coupable.

## La règle de vérification

> On ne coche une étape qu'après **vérification sur un appareil réel**, pas sur
> l'émulateur.

Cette règle a payé plusieurs fois. Les quatre pièges les plus coûteux du projet
(le ET de `motsCles`, le `200 []` de `geo.api.gouv.fr`, l'URL nue des partages,
le gel des processus par ColorOS) étaient **tous invisibles en test unitaire**.
Les simulacres répondaient sagement ce qu'on leur avait dit de répondre.

[← Sécurité](securite.html) · [Décisions →](decisions.html)
