# CLAUDE.md

Contexte projet pour Claude Code. Lis ce fichier en début de session.

## 👉 Par où commencer

1. Lis ce fichier en entier.
2. Lis `PLAN.md` : l'architecture et l'ordre de construction, avec les critères
   d'acceptation de chaque étape.
3. Ouvre `TASKS.md` : le plan de build ordonné. Exécute les tâches dans l'ordre,
   coche-les, vérifie les critères d'acceptation.
4. Ne committe jamais de clé API. Ne demande jamais à inventer une info perso :
   demande à l'utilisateur.

## Identité

| | |
|---|---|
| Nom affiché | **Candid** |
| Package Android | `com.benjsant.candid` |
| Dépôt | `benjsant/candid` |
| Pitch | « L'assistant de candidature qui ne brode jamais. Il ne vous invente ni compétence, ni expérience, et n'envoie rien sans vous. » |

Le nom porte la règle centrale du projet : *candid*, franc, qui n'invente rien.
Ce n'est pas décoratif, c'est le contrat (voir la section Philosophie).

À ne pas confondre avec **Job Hunter**, qui est le nom du projet Docker
(`n8n_jobs_pipeline`). Il apparaît dans `assets/cv/projects.json` et dans le
prompt système en tant que réalisation de portfolio : ne rien y renommer, ces
mentions désignent bien l'autre projet.

## Objectif

**Candid** : compagnon Android de recherche d'emploi pour un
développeur junior orienté IA. Application Flutter **entièrement autonome**, sans
serveur ni hébergement. Tout tourne sur le téléphone ou la tablette ; les seuls
appels sortants vont vers des API publiques.

Le parcours central, celui qui définit le produit :

```
offre partagée depuis LinkedIn / Indeed / WTTJ (cible de partage Android)
  → normalisation + hash + scoring local
  → agent DeepSeek (analyze → research → accroche → judge → validate)
  → CV + lettre en PDF sur l'appareil
  → relecture humaine, puis envoi manuel par l'utilisateur
```

Secondairement, l'application collecte aussi des offres toute seule (France
Travail, La Bonne Alternance) et notifie.

## Relation avec le projet Docker

Ce projet est le **compagnon** de `n8n_jobs_pipeline` (stack Docker : n8n,
PostgreSQL, LangGraph, Astro, Discord), qui reste en service sur le PC et
continue de ratisser large avec toutes ses sources.

**Ce n'est pas un portage à parité, et il ne faut pas viser la parité.** Les deux
produits ont des forces différentes. Le mobile assume d'avoir moins de sources
(pas de JobSpy, donc pas de scraping LinkedIn/Indeed/Glassdoor) et le compense par
la cible de partage, que la version Docker ne peut pas avoir. Chercher à retrouver
toutes les fonctionnalités de la version Docker coûterait des semaines pour un
résultat qui en ferait moins.

Ce qui se réutilise **sans réécriture**, recopié dans `assets/` :

- `assets/prompts/agent-system-prompt.md` : la source de vérité du comportement de
  l'agent. Toute évolution du comportement passe par ce fichier, pas par du code
  dispersé ;
- `assets/letters/*.md` : les 7 templates de lettres, corps figé, validés ;
- `assets/cv/*.json` : les données du CV maître (profil, compétences, projets,
  expériences, formation).

Ce qui se **porte** (la logique existe, il faut la traduire en Dart) :

| Source (projet Docker) | Destination (ici) |
|---|---|
| `workflows/lib/offer-utils.mjs` | `lib/domain/` (norm, canonTitle, hash, scoring) |
| `workflows/lib/sources.mjs` | `lib/sources/normalize.dart` |
| `services/agent-langgraph/agent/graph.py` | `lib/agent/graph.dart` |
| `db/schema.sql` | `lib/data/database.dart` (drift) |
| `cv/template-ats.astro` | `lib/render/cv_document.dart` |

## Philosophie (garde-fous non négociables)

Identiques au projet Docker, et ils ne se négocient pas parce qu'on change de
plateforme. Le système assiste le candidat. Il ne doit **jamais** :

- inventer une compétence, une expérience, une certification, une mission ;
- envoyer automatiquement une candidature ou un email ;
- modifier des données personnelles sans validation.

L'application **produit des PDF et s'arrête là**. C'est l'utilisateur qui envoie,
depuis sa messagerie, après relecture. Aucune fonctionnalité d'envoi automatique
ne doit être ajoutée, même si elle est demandée « pour tester ».

Les garde-fous du code se portent tels quels depuis `graph.py` :
`sanitize_personalisation` (aucune compétence ni projet qui ne soit déjà dans le
CV), `check_accroche`, et `no_dash`.

## Stack

- **Framework** : Flutter (Dart), cible Android (téléphone et tablette).
- **Base locale** : `drift` (SQLite). Même schéma que le PostgreSQL d'origine :
  `search_profiles`, `offers`, `companies`, `applications`,
  `generated_documents`. La table `profile` n'est pas portée : le profil
  candidat vit dans `assets/cv/*.json`, données statiques embarquées. Pas de
  pgvector : si la dédup sémantique est ajoutée un jour, la similarité cosinus
  se calcule en Dart.
- **LLM** : DeepSeek (API compatible OpenAI, base URL `https://api.deepseek.com`,
  modèle `deepseek-chat` par défaut).
- **Sources** : API France Travail (OAuth client_credentials), La Bonne
  Alternance. Plus la cible de partage Android, qui est la voie d'entrée
  principale.
- **PDF** : packages `pdf` + `printing` (Dart pur, pas de navigateur embarqué).
- **Arrière-plan** : `workmanager` (collecte quotidienne).
- **Notifications** : `flutter_local_notifications` (remplace Discord).
- **Secrets** : `flutter_secure_storage` (Keystore Android).
- **HTTP** : `dio`.

## Secrets : rien en dur, jamais

Tout ce qui est compilé dans un APK est extractible en quelques minutes. Il n'y a
donc **aucun `.env`, aucune clé en dur dans le code, aucune clé dans les assets**.

L'utilisateur saisit lui-même, au premier lancement, dans l'écran de réglages :
sa clé DeepSeek, ses identifiants France Travail (client id et secret), sa clé La
Bonne Alternance. Elles sont stockées dans `flutter_secure_storage`.

Si une clé manque, la fonctionnalité concernée se désactive proprement avec un
message clair. Elle ne plante pas.

## Conventions

- **Langue** : prose, commentaires et documentation en français ; identifiants
  techniques en anglais.
- **Pas de tiret cadratin** dans les textes générés (lettres, résumés). Le
  garde-fou `no_dash` existe pour ça, il ne doit pas être retiré.
- **Tests** : la logique pure (hash, dédup, scoring, garde-fous de l'agent) est
  testée. Elle est portée depuis du code déjà testé côté Docker
  (`offer-utils.test.mjs`), donc les cas de test se reprennent.
- **Une étape à la fois** : `PLAN.md` donne un ordre et des critères
  d'acceptation. On ne passe à l'étape suivante qu'après vérification sur un
  appareil réel, pas seulement sur l'émulateur.

## Pièges connus

- **Les tâches de fond.** Android exécute `workmanager` en théorie, mais Xiaomi,
  Samsung et Huawei tuent agressivement les processus d'arrière-plan. La collecte
  automatique peut ne pas partir selon l'appareil. C'est pour ça qu'elle est en
  étape 6 et pas en étape 2 : elle ne doit pas bloquer le reste.
- **Le rendu du CV.** Chercher la parité au pixel près avec le PDF Astro est un
  puits sans fond, invisible pour un recruteur. Un template propre suffit.
- **Le coût DeepSeek.** Sur mobile, un bouton se presse plus vite que sur un PC.
  Prévoir un garde-fou (plafond d'appels à l'agent par jour).

## Tâches typiques pour Claude Code

- Porter une fonction de `workflows/lib/` ou de `agent/` vers Dart, avec ses tests.
- Ajuster le prompt système de l'agent (`assets/prompts/`).
- Faire évoluer le schéma drift ou le rendu PDF.
- Débugger la cible de partage ou une tâche `workmanager`.
