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
✅ Vérifié de bout en bout sur appareil (Oppo, 21/07/2026), clé DeepSeek réelle,
offre « Developpeur IA Junior chez Doctolib » (score local 82) : l'agent répond
en ~20 s, score 85/100, recommandation « À postuler », compteur passé à 1/5.
L'accroche cite « Doctolib révolutionne l'accès aux soins **depuis 2013** » —
fait recoupé avec le registre (`date_creation: 2013-07-15`), donc vérifiable et
non inventé. Aucun tiret cadratin. La lettre reprend l'accroche et le corps
figé ; le CV ciblé est réordonné (Job Hunter en tête).
**Défaut trouvé et corrigé à cette occasion** : l'accroche citait InfiniDex
alors que la personnalisation le masquait du CV (elle est décidée au nœud
`analyze`, avant que l'accroche existe). Le recruteur suivait une piste absente
du document joint. Règle de cohérence ajoutée dans `sanitizePersonnalisation`
(un projet cité dans l'accroche n'est jamais masqué), avec son test.

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
- [x] `lib/sources/france_travail.dart` **fait** : OAuth client_credentials +
      `/offres/search`. URL du realm, scopes (`api_offresdemploiv2 o2dsoffre`) et
      paramètres repris du workflow n8n, qui les a vérifiés en production. Jeton
      mis en cache jusqu'à expiration (il vit ~25 min).
- [x] `lib/sources/normalize.dart` **fait** : port de `reference/sources.mjs`
      pour France Travail et La Bonne Alternance (volets `jobs` et `recruiters`).
- [x] `lib/sources/collect_service.dart` + bouton « Collecter » **faits**.
      ✅ Vérifié en réel sur appareil (Oppo, 21/07/2026) avec les identifiants
      France Travail : **150 offres collectées**, scores de 12 à 92. Second
      appui : 157 offres en base pour 157 hash distincts, **zéro doublon** —
      critère d'acceptation de l'étape tenu. 72 offres sans entreprise
      (anonymisées à la source) : champ laissé vide, jamais comblé.
- [x] **Profil de recherche fait** (`profile_repository.dart`,
      `search_profile_screen.dart`, `geo.dart`) : ville résolue en code INSEE via
      `geo.api.gouv.fr` (sans clé), rayon, mots-clés, niveau, contrats,
      indispensables, exclusions. L'écran avertit tant qu'aucune commune n'est
      retenue. ✅ Vérifié en réel : Valenciennes → INSEE 59606, rayon 30 km →
      **9 offres, aucune hors 59/62** (contre 150 dans toute la France avant).
- [x] **Piège France Travail : `motsCles` est un ET, limité à 3 mots.**
      « développeur python intelligence artificielle » renvoyait 204 (zéro),
      « python » seul 7 offres. La collecte envoie donc **une requête par
      terme** : virgules si l'utilisateur en met (les expressions restent
      entières), espaces sinon. Résultats fusionnés et dédoublonnés par
      identifiant de source avant enregistrement, pour que le bilan reste
      compréhensible.
- [x] `lib/sources/lba.dart` **fait** : `/api/job/v1/search`, clé en Bearer,
      recherche par latitude/longitude + rayon + codes ROME (défaut M1805).
      Les coordonnées sont résolues à la collecte depuis les codes INSEE du
      profil (`geo.dart`), pour ne pas stocker deux formats de localisation.
      **Les `recruiters` ne sont pas enregistrés comme des offres** : ce sont
      des entreprises sans poste publié, en faire des annonces serait inventer.
      Ils sont comptés et affichés dans le bilan (candidature spontanée = étape 7).
      ✅ Vérifié en réel (21/07) : 2 offres d'alternance enregistrées, ~297
      entreprises à démarcher signalées.
- [ ] **Piège `geo.api.gouv.fr`** : le paramètre `code` n'accepte **pas** de
      liste. `code=59606,59350` répond « 200 [] », sans erreur. Un appel par
      commune. Avoir supposé l'inverse désactivait silencieusement toute la
      source LBA (« aucune commune localisable »). Verrouillé par un test.
- [ ] **Limite connue : la dédup inter-sources est syntaxique.** Une même offre
      arrivée par France Travail et par LBA peut passer deux fois si l'entreprise
      est nommée d'un côté et vide de l'autre (cas vu à Roubaix). Le hash porte
      sur titre + entreprise + lieu. La vraie réponse est la dédup sémantique,
      déjà prévue en étape 7.
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
