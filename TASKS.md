# TASKS.md

Plan de build ordonné. Exécuter les tâches dans l'ordre, cocher au fur et à
mesure, et ne passer à l'étape suivante qu'une fois son critère d'acceptation
vérifié **sur un appareil réel**, pas seulement sur l'émulateur.

Le raisonnement derrière cet ordre est dans `PLAN.md`. En deux mots : on construit
d'abord la chaîne « une offre en entrée, un dossier de candidature en sortie »,
qui est le cœur du produit. La collecte automatique, la partie la plus fragile,
vient en dernier.

> **État au 19/07/2026** : étapes 1 et 2 codées, 28 tests verts, analyse
> propre, et **vérifiées sur appareil réel** (OnePlus CPH2195, Android 13) :
> partage → écran de réception (titre, entreprise, URL, source extraits) →
> enregistrement avec score → doublon refusé au repartage. Partage réel
> depuis l'app LinkedIn officielle validé et figé en fixture : elle ne
> partage QUE l'URL (titre et entreprise saisis à la main). Restent Indeed,
> WTTJ et HelloWork à capturer. SDK Android installé (voir étape 0).

## Étape 0 : prérequis (à faire par Benjamin)

- [x] SDK Flutter installé (3.44.6, le projet compile et les tests passent)
- [x] SDK **Android** installé le 19/07/2026, sans sudo ni Android Studio :
      cmdline-tools + platform-tools + plateformes 36 et 37 + build-tools 36
      dans `~/Android/Sdk`, JDK Temurin 21 dans `~/Android/jdk` (le système
      n'a qu'un JRE). Déclarés à Flutter via `flutter config --android-sdk`
      et `--jdk-dir` : `flutter doctor` est vert, VSCode voit l'appareil
      (redémarrer l'éditeur après un changement de config)
- [x] Mode développeur et débogage USB activés (adb et scrcpy installés)
- [x] Vérification visuelle avec Claude : scrcpy sert à l'humain (miroir de
      l'écran) ; pour que Claude « voie » le téléphone, passer par
      `adb exec-out screencap -p > capture.png` (adb est fourni avec le SDK
      Android et embarqué dans scrcpy), puis lui faire lire le PNG
- [ ] Récupérer les clés : DeepSeek, France Travail (client id + secret), LBA
      (elles ne vont **pas** dans le dépôt, elles seront saisies dans l'application)

## Étape 1 : socle et base

- [x] `flutter create`, structure de dossiers conforme à `PLAN.md`
- [x] Dépendances de l'étape 1 : `drift`, `drift_flutter`, `sqlite3_flutter_libs`,
      `path_provider`, `dio`, `flutter_secure_storage`, `crypto`
      (les autres s'ajoutent à l'étape qui les utilise : `pdf` et `printing` en 3,
      `workmanager` et `flutter_local_notifications` en 6)
- [x] Schéma `drift` porté depuis `reference/schema.sql` (offers, companies,
      applications, generated_documents, search_profiles ; la table `profile`
      n'est pas portée, le profil candidat vit dans `assets/cv/*.json`)
- [x] Écran de réglages : saisie et stockage des clés dans le secure storage
- [x] Chargement des assets (prompt système, templates de lettres, données CV)

**Acceptation :** les clés survivent au redémarrage de l'application, et les
assets se lisent.

## Étape 2 : entrée par partage (le cœur)

- [x] Déclarer l'application comme cible de partage Android (`ACTION_SEND`,
      `text/plain`) dans le manifeste
- [x] Écran de réception : afficher le texte et l'URL reçus, laisser corriger le
      titre et l'entreprise si l'extraction est imparfaite
- [x] Porter `norm`, `canonTitle`, `canonCompany`, le hash SHA256 depuis
      `reference/offer-utils.mjs` vers `lib/domain/hash.dart`
- [x] Porter le scoring local depuis `reference/offer-utils.mjs` vers
      `lib/domain/scoring.dart`
- [x] Reprendre les cas de test de `reference/offer-utils.test.mjs` en tests Dart
- [x] Enregistrer l'offre en base, avec dédup par hash
- [ ] Lors du test sur appareil : capturer les textes **réellement** partagés
      et les figer en fixtures dans `test/shared_text_test.dart` (harnais
      `capturesReelles`). Fait : LinkedIn (19/07/2026, URL seule — aucune
      regex de titre ne verra jamais un partage LinkedIn). Restent : Indeed,
      WTTJ, HelloWork. Les regex actuelles restent des suppositions pour ces
      sources-là ; ne pas les « améliorer » sans capture réelle.

**Acceptation :** partager une offre depuis l'application LinkedIn officielle crée
l'entrée en base, avec un titre et une entreprise corrects, et un score cohérent.
Partager deux fois la même offre ne crée qu'une entrée.

## Étape 3 : rendu PDF

- [ ] `lib/render/cv_document.dart` : le CV en widgets `pdf`, à partir des données
      de `assets/cv/*.json` (s'inspirer de `reference/template-ats.astro`)
- [ ] `lib/render/letter_document.dart` : la lettre (voir
      `reference/letter-template.mjs`)
- [ ] Aperçu à l'écran (`printing`) et partage du fichier PDF

**Acceptation :** le PDF s'ouvre sur le téléphone et se partage par mail.

> Ne pas chercher la parité au pixel près avec le PDF Astro. C'est un puits sans
> fond, et personne ne le remarquera. Un template propre et lisible suffit.

## Étape 4 : l'agent

- [ ] `lib/agent/llm.dart` : interface `LlmClient` (multi-fournisseurs, voir
      PLAN.md « Le LLM »). Une méthode : prompt système + message → texte/JSON.
      **Concevoir pour le cache dès le départ** : le préfixe constant (prompt
      système + cv-index) toujours en tête des messages, dans le même ordre, et
      tout ce qui varie (l'offre) à la fin. Les tokens en cache coûtent une
      fraction du prix et répondent plus vite ; dur à retrofitter ensuite.
- [ ] `lib/agent/providers/` : trois implémentations HTTP compatibles OpenAI :
      `deepseek.dart` (défaut), `openrouter.dart` (mode gratuit/privé, option
      d'entraînement désactivée), `gemini.dart` (option, données non sensibles).
      Modèle configurable dans les réglages, jamais codé en dur.
- [ ] Réglages : choix du fournisseur actif + du modèle ; clé par fournisseur
      dans le secure storage. Une clé absente désactive proprement le fournisseur.
- [ ] `lib/agent/graph.dart` : porter les 5 nœuds de `reference/graph.py`
      (analyze, research, accroche, judge, validate) en fonctions `async`.
      Le grounding de `research` (`recherche-entreprises.api.gouv.fr`) est sans
      clé et sans OAuth : il se porte tel quel en un appel dio. Ne pas le
      remplacer par « demander au LLM ce qu'il sait de l'entreprise » : c'est
      lui qui ancre l'accroche dans des faits vérifiables.
- [ ] `lib/agent/guards.dart` : porter `no_dash`, `check_accroche`,
      `sanitize_personalisation` (garde-fous **non négociables**)
- [ ] Tests des garde-fous : une personnalisation qui invente une compétence
      absente du CV doit être rejetée
- [ ] Plafond d'appels quotidiens à l'agent (garde-fou de coût), **visible dans
      l'interface** (« 3/5 aujourd'hui ») plutôt qu'un refus silencieux
- [ ] Brancher : une offre partagée produit un CV et une lettre personnalisés

**Acceptation :** sur une offre réelle, la lettre passe les garde-fous (rien
d'inventé, aucun tiret cadratin) et l'accroche cite un fait vérifiable sur
l'entreprise.

## Étape 5 : suivi

- [ ] Écran de suivi : candidatures, statuts (draft, sent, interview, rejected,
      accepted), dates
- [ ] Marquer une candidature comme envoyée après l'avoir envoyée soi-même
- [ ] Rappel de relance
- [ ] Export de la base (partage du fichier SQLite ou d'un JSON) : contrairement
      au Postgres du projet Docker, tout l'historique vit sur un téléphone qui
      peut se perdre. Une heure de travail qui protège des mois de suivi.

**Acceptation :** le cycle complet, du partage de l'offre à « envoyée », tient
sans quitter l'application.

## Étape 6 : collecte automatique

- [ ] `lib/sources/france_travail.dart` : OAuth client_credentials, recherche
- [ ] `lib/sources/lba.dart` : La Bonne Alternance
- [ ] `lib/sources/normalize.dart` : porter depuis `reference/sources.mjs`
- [ ] Écran de liste : offres triées par score, triage au balayage
- [ ] « Re-scorer » : recalculer les scores des offres en attente quand le
      profil de recherche change (les scores sont figés à l'insertion ; la
      logique est pure, c'est trois lignes)
- [ ] `workmanager` : collecte une fois par jour
- [ ] Notification locale : « 12 nouvelles offres, dont 3 au-dessus de 75 »

**Acceptation :** un second appui sur « Collecter » n'ajoute aucun doublon, et la
notification arrive sans ouvrir l'application.

> Piège connu : Xiaomi, Samsung et Huawei tuent les tâches de fond. Si la collecte
> ne part pas, c'est probablement l'optimisation de batterie du constructeur, pas
> le code. Ne pas y passer trois soirées : l'application reste utilisable sans.

## Étape 7 : facultatif

- [ ] Dédup sémantique embarquée (MiniLM quantifié en ONNX, cosinus en Dart)
- [ ] Digest hebdomadaire
- [ ] Candidature spontanée depuis les entreprises remontées par LBA
- [ ] Import ponctuel de l'historique depuis le dump PostgreSQL
      (`/mnt/Data/Dev/migration-n8n/db/`)
