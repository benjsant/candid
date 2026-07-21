# CONTEXTE.md : mémoire portable de Candid

Ce fichier est la **mémoire de session** : décisions prises, état réel,
ce qui est en attente, journal daté. Il complète (ne remplace pas) :
`CLAUDE.md` (règles), `PLAN.md` (architecture), `TASKS.md` (plan de build).
À lire après eux, en début de session, pour savoir où on en est vraiment.

Convention : dates absolues, pas de « hier ». On ajoute en bas du journal,
on ne réécrit pas l'historique.

## Identité

Candid (`benjsant/candid`, `com.benjsant.candid`) : app Android autonome de
candidature, compagnon du pipeline Docker `job_hunter` (pas un portage à
parité). Contrat central : ne jamais broder, ne rien envoyer sans l'utilisateur.

## État au 21/07/2026

- **Étapes 1 à 5 faites et validées sur appareil réel.** Oppo CPH2195,
  Android 13. 85 tests verts, `flutter analyze` propre. Reste l'étape 6
  (collecte automatique), qui attend les clés France Travail et LBA.
- **Étape 4 close le 21/07** : bout-en-bout avec une vraie clé DeepSeek sur une
  offre Doctolib. Score agent 85/100, accroche ancrée sur un fait recoupable au
  registre (création 2013), lettre et CV ciblé rendus. Voir TASKS pour le détail
  et pour le défaut de cohérence lettre/CV corrigé à cette occasion.
- **Étape 5 (suivi) close** : `ApplicationsRepository` (créer depuis une offre,
  statut/dates/notes/relance), onglet Suivi (`tracking_screen.dart`), bouton
  « Suivre » sur l'offre (l'offre quitte la boîte), export JSON via `share_plus`
  (`export_service.dart`). Cycle offre → suivi → « Envoyée » daté → export
  vérifié sur appareil. Mode clair/sombre manuel + sélecteurs en listes
  déroulantes déjà en place. `pubspec.lock` versionné, `Annotated.hash` retiré.
- **Étape 4 (l'agent) codée** : `lib/agent/` = models (port schema.py), guards
  (no_dash, check_accroche, sanitize — non négociables), llm (client
  multi-fournisseurs OpenAI-compatible, cache-friendly), research (grounding
  INSEE sans clé), graph (analyze→research→accroche→judge→validate + boucle
  d'auto-correction), agent_config (fournisseur, modèle, plafond 5/jour),
  agent_service. UI : bouton « Générer la candidature » → CV ciblé + lettre à
  accroche réelle ; réglages avec sélecteur de fournisseur. Vérifié appareil :
  plafond « 0/5 » affiché, dégradation propre sans clé, sélecteur OK.
  **Reste : un vrai appel LLM (clé requise, étape 0).**
- **Étape 3 (rendu PDF) close** : CV (port du template ATS) et lettre (corps
  figé) rendus en widgets `pdf`, aperçu + partage via `printing`. Police
  Liberation Sans embarquée (la Helvetica intégrée affichait « • » et « œ » en
  tofu). Accès par tap sur une offre → écran de détail.
- **Testé pour de vrai** : partager une offre depuis l'app LinkedIn ET depuis
  France Travail (Parcours Emploi) ouvre bien Candid sur l'écran de réception,
  la source est détectée, et le garde-fou anti-invention fonctionne (« je n'ai
  pas tout reconnu » quand l'app ne partage qu'une URL).
- **Prochaine étape : bout-en-bout de l'agent avec une clé LLM**, puis 5
  (suivi), 6 (collecte).

## Décisions structurantes (avec le pourquoi)

- **Candid ≠ Job Hunter Mobile** (15/07). Pas un client de l'API du pipeline,
  mais une app autonome. Sa force propre est la cible de partage Android, que
  la version Docker ne peut pas avoir. Ne jamais viser la parité fonctionnelle.
- **LLM multi-fournisseurs** derrière `LlmClient` (16/07). DeepSeek par défaut ;
  OpenRouter en mode gratuit et respectueux des données (option d'entraînement
  OFF) ; Gemini réservé au non-sensible (son offre gratuite entraîne sur les
  requêtes) ; Mammouth en option si déjà abonné au chat. Modèle configurable,
  jamais codé en dur. Claude/Anthropic n'est PAS un fournisseur : l'abonnement
  Pro ne donne pas d'accès API ; il sert à construire Candid via Claude Code.
- **Les apps officielles partagent une URL nue** (constat appareil, 20/07).
  LinkedIn et France Travail ne donnent ni titre ni entreprise. Conséquences :
  (1) dédup sur l'URL faite (`dedupHash`), (2) résolution d'URL FT via l'API
  notée pour l'étape 6 (la vraie réponse à la friction).
- **Table `profile` non portée** : le profil candidat vit dans `assets/cv/*.json`
  (statique, embarqué), pas en base.

## Bloquants et points ouverts

- **Étape 2 : critère d'acceptation validé sur appareil (20/07).** Build à jour
  réinstallée sur l'Oppo, `dedupHash` vérifié en conditions réelles : deux
  partages de la même URL France Travail avec des titres saisis différemment
  (« Dev IA » puis « Developpeur IA H/F ») → une seule entrée, « Vous aviez
  déjà cette offre ». Base tirée de l'appareil : hash = `sha256('url:'+canonUrl)`
  confirmé, et les index `idx_offers_*` sont bien présents.
- **`capturesReelles`** : LinkedIn (app), France Travail (app) et WTTJ
  (navigateur) figés — tous URL seule. Indeed = app derrière un mur de connexion
  (non contourné, on ne crée pas de compte). Reste HelloWork.
- **Découverte 20/07 (soir) : `EXTRA_SUBJECT`.** Le partage navigateur affiche
  le titre de page dans la feuille système, mais ce titre part dans
  `EXTRA_SUBJECT` de l'intent, que `receive_sharing_intent` ne remonte pas (il ne
  lit que `EXTRA_TEXT` = l'URL). Piste : le lire en natif pré-remplirait le titre
  depuis les partages navigateur. Notée dans PLAN « La cible de partage ».
- **`linux/`** : scaffolding desktop généré par Flutter, commité le 20/07.
  Inoffensif (permet de lancer l'UI sur PC), à retirer si on veut Android pur.

## Environnement de vérification sur appareil

Outils présents sur la machine : `adb` et `scrcpy` (`/usr/bin`), SDK Flutter
(`~/distrobox/flutter_sdk`), SDK Android en place (Candid est installé et a
tourné). Protocole : **scrcpy pour l'humain** (miroir), **`adb exec-out
screencap -p > capture.png` pour Claude** (lit le PNG et valide chaque écran).
Téléphone en USB + débogage activé + mode « Transfert de fichiers » (pas MIDI).

## Taille de l'app : debug ≠ release

L'écran « Informations sur l'appli » affichait ~180 Mo : c'est l'artefact
**debug** (kernel Dart JIT 88 Mo, 3 moteurs Flutter debug non-strippés, couche
Vulkan). Ce n'est PAS un problème à corriger dans le code. Le livrable réel est
un **build release découpé par architecture** :

```bash
flutter build apk --release --split-per-abi
```

→ ~22 Mo pour l'arm64 (le téléphone). Ne pas s'alarmer du chiffre du build
debug. Pour le Play Store, un `.aab` (`flutter build appbundle`) livrerait encore
un peu moins par appareil.

## Prochaines actions concrètes

1. Bout-en-bout de l'agent avec une clé LLM (voir étape 0).
2. Étape 6 (collecte automatique) : France Travail + LBA, workmanager.
3. Compléter `capturesReelles` (Indeed via login, HelloWork) à l'occasion.

## Journal

- **21/07/2026** : premier appel LLM réel (DeepSeek) depuis le téléphone. Étape
  4 close. Enseignement : les deux nœuds qui écrivent (analyze pour le CV,
  accroche pour la lettre) peuvent se contredire sans que rien ne soit inventé.
  Ici l'accroche vantait un projet que le CV masquait. Les garde-fous
  vérifiaient « rien d'inventé » mais pas « les deux documents se tiennent » :
  règle de cohérence ajoutée. À garder en tête si d'autres nœuds s'ajoutent.
- **20/07/2026 (soir)** : build à jour réinstallée sur l'Oppo, `dedupHash`
  vérifié en vrai (repartage même URL FT, titre retapé → doublon refusé), hash
  et index `idx_offers_*` confirmés depuis la base de l'appareil. Bloquant
  « build en retard » levé. Étape 2 close. Petite scorie notée : `Annotated.hash`
  n'est plus lu par le repository depuis `dedupHash` (calcul SHA256 inutile à
  chaque save) — à nettoyer un jour, sans urgence.
- **20/07/2026** : test de bout en bout de l'étape 2 sur l'Oppo (LinkedIn +
  France Travail). Constat URL-seule confirmé. `dedupHash` ajouté (dédup sur
  l'URL, repli titre+entreprise), fixtures réelles figées, PLAN/TASKS mis à
  jour, docs LLM multi-fournisseurs. Création de ce CONTEXTE.md.
- **17/07/2026** : optimisations structurelles (index SQLite, `INSERT OR
  IGNORE` par hash, `IndexedStack`). CLAUDE.md enrichi (cycle de dev,
  vérification adb, pièges). Push initial vers GitHub (le dépôt n'avait jamais
  été poussé).
- **15/07/2026** : création du projet, étapes 1 (socle drift + coffre-fort des
  clés) et 2 (cible de partage, hash, scoring portés avec leurs tests).
