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
      `capturesReelles`). Fait : LinkedIn (app, 19/07), France Travail (app,
      20/07), WTTJ (navigateur, 20/07) — **tous URL seule**. Enseignement
      transversal : même le navigateur n'envoie que l'URL dans `EXTRA_TEXT`, le
      titre de page part dans `EXTRA_SUBJECT` non lu (piste PLAN : le lire en
      natif). Les regex « Titre chez Entreprise » ne se déclenchent donc sur
      aucune source réelle testée. Reste Indeed (app derrière login) et
      HelloWork. Ne pas « améliorer » les regex sans capture réelle.

**Acceptation :** partager une offre depuis l'application LinkedIn officielle crée
l'entrée en base, avec un titre et une entreprise corrects, et un score cohérent.
Partager deux fois la même offre ne crée qu'une entrée.

## Étape 3 : rendu PDF

- [x] `lib/render/cv_document.dart` : le CV en widgets `pdf`, port du template
      ATS (1 colonne, indigo sobre) depuis `assets/cv/*.json`
- [x] `lib/render/letter_template.dart` : port pur de `letter-template.mjs`
      (accroche + placeholders + objet + anti-dash), testé
- [x] `lib/render/letter_document.dart` : mise en page de la lettre (expéditeur,
      objet, corps figé, signature)
- [x] `lib/render/pdf_theme.dart` : police embarquée Liberation Sans. La
      Helvetica intégrée du paquet `pdf` affichait « • » et « œ » en tofu.
- [x] Aperçu à l'écran (`printing`) et partage du fichier PDF, via
      `document_preview_screen.dart` ; accès depuis `offer_detail_screen.dart`
      (tap sur une offre)

**Acceptation :** le PDF s'ouvre sur le téléphone et se partage par mail.
✅ Vérifié sur appareil (Oppo, 20/07) : CV et lettre s'affichent (aperçu
`printing`), les puces et « œuvre » sont correctes, et la feuille de partage
propose Gmail. L'accroche de la lettre est un placeholder marqué « à générer »
(l'agent la rédige à l'étape 4) : rien n'est inventé.

> Ne pas chercher la parité au pixel près avec le PDF Astro. C'est un puits sans
> fond, et personne ne le remarquera. Un template propre et lisible suffit.

## Étape 4 : l'agent

- [x] `lib/agent/llm.dart` : interface `LlmClient` (+ `LlmGateway` abstrait),
      cache-friendly (prompt système stable en 1er message, offre variable
      ensuite). Un appel JSON, tolérant aux clôtures markdown.
- [x] Trois fournisseurs OpenAI-compatibles derrière l'enum `LlmProvider` :
      DeepSeek (défaut), OpenRouter, Gemini. Modèle configurable, jamais en dur.
      (Un seul client paramétré plutôt que trois fichiers : même API.)
- [x] Réglages : sélecteur de fournisseur + modèle (`AgentConfig`) ; clé par
      fournisseur dans le secure storage. Clé absente = désactivation propre.
- [x] `lib/agent/graph.dart` : 5 nœuds de `reference/graph.py` en async
      (analyze, research, accroche, judge, validate) + boucle d'auto-correction.
      `research` = grounding INSEE réel (`recherche-entreprises.api.gouv.fr`,
      sans clé), `lib/agent/research.dart`.
- [x] `lib/agent/guards.dart` : `no_dash`, `check_accroche`,
      `sanitize_personnalisation` (garde-fous **non négociables**)
- [x] Tests des garde-fous + du graphe + du client + du grounding (33 tests
      d'agent) : cliché rejeté et régénéré, masquage borné, tiret cadratin retiré.
- [x] Plafond d'appels quotidien (`AgentConfig`, défaut 5/jour), **visible**
      dans l'écran de détail (« x/5 appels aujourd'hui »).
- [x] Brancher : bouton « Générer la candidature » sur l'offre → CV ciblé
      (personnalisation appliquée au rendu) + lettre à accroche réelle.

**Acceptation :** sur une offre réelle, la lettre passe les garde-fous (rien
d'inventé, aucun tiret cadratin) et l'accroche cite un fait vérifiable sur
l'entreprise.
⏳ Partiellement vérifié sur appareil (Oppo, 20/07) : UI branchée, plafond
affiché (« 0/5 »), dégradation propre sans clé (« Aucune clé pour DeepSeek »),
sélecteur de fournisseur fonctionnel. **Le bout-en-bout avec un vrai appel LLM
reste à faire** : il exige une clé DeepSeek/OpenRouter/Gemini (étape 0). Les
garde-fous, le graphe, le grounding et le client sont couverts par 33 tests, et
l'API INSEE a été confirmée en direct.

## Étape 5 : suivi

- [x] `lib/data/applications_repository.dart` : créer une candidature depuis une
      offre (idempotent, sort l'offre de la boîte), suivre la liste, changer
      statut/dates/notes. Testé (6 tests).
- [x] `lib/ui/tracking_screen.dart` : onglet Suivi, une carte par candidature,
      statut (draft, sent, interview, rejected, accepted) via liste déroulante,
      dates, note et relance dans le menu ⋮.
- [x] Marquer « Envoyée » date `appliedAt` ; une réponse date `responseAt`.
      L'envoi reste manuel : dater n'envoie rien.
- [x] Rappel de relance (sélecteur de date par candidature).
- [x] Bouton « Suivre cette candidature » sur l'écran de détail de l'offre.
- [x] Export JSON (offres + candidatures) partagé via `share_plus`
      (`lib/data/export_service.dart`), action dans la barre de l'onglet Suivi.
      Tout l'historique vit sur le téléphone : cet export le protège.

**Acceptation :** le cycle complet, du partage de l'offre à « envoyée », tient
sans quitter l'application.
✅ Vérifié sur appareil (Oppo, 20/07) : partage → offre → « Suivre » → l'offre
quitte la boîte et la candidature apparaît dans Suivi → passage à « Envoyée »
daté automatiquement → export JSON valide (offres + candidatures) proposé au
partage (Drive, Gmail, fichiers).

## Étape 6 : collecte automatique

- [ ] `lib/sources/france_travail.dart` : OAuth client_credentials, recherche
- [ ] **Résolution d'URL partagée** : une URL `francetravail.fr` reçue par
      partage porte l'identifiant de l'offre (ex. `.../detail/211FDFG`). Une fois
      les identifiants FT en place ici, résoudre cet id via l'API pour remplir
      titre/entreprise/description dans l'écran de réception, au lieu de laisser
      l'utilisateur tout retaper (constat 20/07 : LinkedIn et FT ne partagent
      qu'une URL nue). Voir PLAN « La cible de partage ».
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
