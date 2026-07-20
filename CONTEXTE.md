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

## État au 20/07/2026

- **Étapes 1 et 2 faites et validées sur appareil réel** (Oppo CPH2195,
  Android 13). 35 tests verts, `flutter analyze` propre.
- **Testé pour de vrai** : partager une offre depuis l'app LinkedIn ET depuis
  France Travail (Parcours Emploi) ouvre bien Candid sur l'écran de réception,
  la source est détectée, et le garde-fou anti-invention fonctionne (« je n'ai
  pas tout reconnu » quand l'app ne partage qu'une URL).
- **Prochaine étape : 3 (rendu PDF)**. Puis 4 (agent), 5 (suivi), 6 (collecte).

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
- **`capturesReelles`** : LinkedIn et France Travail figés (URL seule). Manque
  Indeed, WTTJ, HelloWork, à capturer quand l'occasion se présente.
- **`linux/`** : scaffolding desktop généré par Flutter, commité le 20/07.
  Inoffensif (permet de lancer l'UI sur PC), à retirer si on veut Android pur.

## Environnement de vérification sur appareil

Outils présents sur la machine : `adb` et `scrcpy` (`/usr/bin`), SDK Flutter
(`~/distrobox/flutter_sdk`), SDK Android en place (Candid est installé et a
tourné). Protocole : **scrcpy pour l'humain** (miroir), **`adb exec-out
screencap -p > capture.png` pour Claude** (lit le PNG et valide chaque écran).
Téléphone en USB + débogage activé + mode « Transfert de fichiers » (pas MIDI).

## Prochaines actions concrètes

1. Attaquer l'étape 3 : rendu PDF en widgets Dart (`pdf`/`printing`), sans
   viser la parité pixel avec l'Astro.
2. Compléter `capturesReelles` (Indeed, WTTJ, HelloWork) à l'occasion.

## Journal

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
