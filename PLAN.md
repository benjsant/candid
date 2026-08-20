# Candid : plan d'architecture (Flutter / Dart, Android)

Compagnon mobile autonome de `n8n_jobs_pipeline`. Aucun serveur : tout tourne sur
le téléphone ou la tablette. Les seuls appels sortants vont vers des API publiques
(France Travail, La Bonne Alternance, DeepSeek), exactement comme aujourd'hui.

**Ce n'est pas un remplaçant.** La version Docker reste en service à la maison :
c'est elle qui ratisse large, avec toutes ses sources. L'application mobile est un
produit différent, qui vise le triage et la génération en mobilité. Elle a le droit
d'avoir moins de sources, et elle le compense par une fonctionnalité que la version
Docker ne peut structurellement pas avoir : la **cible de partage Android** (voir
plus bas). Toute tentative d'atteindre la parité fonctionnelle avec la version
Docker est un piège : elle coûterait des semaines pour aboutir à un produit qui en
fait moins.

## Ce qui disparaît, ce qui reste

| Composant actuel | Devient |
|---|---|
| n8n (8 workflows) | `workmanager` : une tâche périodique de collecte |
| PostgreSQL + pgvector | `drift` (SQLite), même schéma |
| service agent-langgraph (Python) | `lib/agent/` : le graphe en Dart async |
| service render (Astro + Playwright) | package `pdf` : CV et lettre en widgets Dart |
| service embeddings (fastembed) | supprimé en V1 (dédup par hash seulement) |
| service jobspy (LinkedIn/Indeed) | supprimé : non portable sur mobile |
| Discord (2 canaux) + webhooks | notifications Android natives |
| mini-interface web (:8901) | l'application elle-même |
| `.env` | `flutter_secure_storage`, clés saisies par l'utilisateur |

Ce qui se réutilise tel quel, sans réécriture : `prompts/agent-system-prompt.md`,
`assets/letters/*.md` (les 7 templates), et les données CV `cv/*.json`. Ils
deviennent des assets Flutter.

Les sources conservées sont **France Travail** et **La Bonne Alternance**, toutes
deux des API REST officielles. Ce sont déjà celles qui couvrent le mieux le
marché junior. JobSpy est abandonné : c'est une bibliothèque Python qui scrape
LinkedIn, Indeed et Glassdoor, elle ne tourne pas sur Android et les IP mobiles
se font bloquer.

## Arborescence

```
lib/
├── main.dart
├── core/
│   ├── config.dart          # lecture des clés (secure storage)
│   ├── http.dart            # client dio + retry
│   └── notifications.dart   # flutter_local_notifications
├── data/
│   ├── database.dart        # drift : offers, companies, applications,
│   │                        # generated_documents, search_profiles
│   │                        # (le profil candidat vit dans assets/cv/)
│   └── dao/                 # requêtes (offres à trier, suivi, digest)
├── sources/
│   ├── france_travail.dart  # OAuth client_credentials + /offres/search
│   ├── lba.dart             # offres + entreprises à démarcher
│   └── normalize.dart       # port de workflows/lib/sources.mjs
├── domain/
│   ├── hash.dart            # port de norm/canonTitle/canonCompany + SHA256
│   ├── dedup.dart
│   └── scoring.dart         # port de offer-utils.mjs + llm-scoring.mjs
├── agent/
│   ├── llm.dart             # interface LlmClient (multi-fournisseurs)
│   ├── providers/           # deepseek.dart, openrouter.dart, gemini.dart
│   │                        # (tous compatibles OpenAI : même forme d'appel)
│   ├── graph.dart           # analyze → research → accroche → judge → validate
│   └── guards.dart          # no_dash, sanitize_personalisation, check_accroche
├── render/
│   ├── cv_document.dart     # port de cv/template-ats.astro
│   └── letter_document.dart # port de cv/letter-template.mjs
├── jobs/
│   └── collect_task.dart    # workmanager : collecte quotidienne
└── ui/
    ├── offers_screen.dart       # liste triée par score, swipe garder/ignorer
    ├── offer_detail_screen.dart # + bouton « Générer la candidature »
    ├── application_screen.dart  # aperçu PDF, partage, marquer comme envoyée
    ├── tracking_screen.dart     # suivi des candidatures et relances
    └── settings_screen.dart     # clés API, profils de recherche, style de CV

assets/
├── prompts/agent-system-prompt.md   # copié depuis le projet actuel
├── letters/*.md                     # les 7 templates, inchangés
└── cv/*.json                        # profile, skills, projects, experiences…
```

## Le LLM : multi-fournisseurs, un seul contrat

L'agent ne connaît pas son fournisseur. Il parle à une interface `LlmClient`
(une méthode : envoyer un prompt système + un message, recevoir un texte ou un
JSON). Trois implémentations derrière, toutes en HTTP compatible OpenAI, donc
quasi identiques : seuls l'URL de base, la clé et l'identifiant de modèle
changent.

**Ce n'est pas de la sur-ingénierie.** Les fournisseurs de LLM sont volatils
(prix, quotas gratuits, modèles qui vont et viennent). Une seule couche
d'abstraction rend le choix configurable au lieu de le figer dans le code, et
c'est un point d'architecture solide à montrer en portfolio.

| Fournisseur | Rôle | Pourquoi |
|---|---|---|
| **DeepSeek** | moteur par défaut | pas cher, simple, déjà la référence du projet Docker |
| **OpenRouter** | mode gratuit / respectueux | offre gratuite réelle ; ne journalise pas les prompts et ne route pas vers des fournisseurs qui entraînent sur les données, **tant que l'option d'entraînement reste désactivée**. Convient même à la lettre (données perso) |
| **Gemini** | option, données non sensibles | offre gratuite généreuse, mais l'offre gratuite **utilise les requêtes pour entraîner** les modèles Google. À réserver au scoring et à la dédup, jamais au CV ni à la lettre |
| **Mammouth** | option, si déjà abonné | agrégateur français, API compatible OpenAI, bonne confidentialité (pas d'entraînement, non-rétention, RGPD). Mais l'abonnement à 10 €/mois n'inclut que ~2 $ de crédits API puis paiement à l'usage avec marge : intéressant seulement si on paie déjà les 10 € pour le chat, pas comme moteur d'app |

Règles qui découlent de ce choix, à respecter dans le code :

- **L'identifiant de modèle est configurable, jamais codé en dur.** La liste des
  modèles gratuits d'OpenRouter change au fil du temps ; l'utilisateur choisit
  le modèle dans les réglages.
- **Le mode OpenRouter garde l'option d'entraînement désactivée par défaut**, et
  ne propose que des modèles accessibles sans elle. C'est ce qui protège les
  données personnelles.
- **Anthropic (Claude) n'est PAS un fournisseur ici.** L'abonnement Pro ne donne
  pas d'accès API : l'API se facture au token, séparément. Si un jour on l'ajoute,
  ce sera un mode « clé API personnelle » explicitement payant, pas le défaut.
  L'abonnement Pro sert à *construire* Candid (via Claude Code), pas à le faire
  tourner.

Le fournisseur actif et son modèle sont un réglage, au même titre que les clés.
Une clé absente désactive proprement le fournisseur correspondant.

## Le graphe de l'agent

Dans `graph.py` il est linéaire, avec une seule boucle conditionnelle après le
juge. En Dart, pas besoin de LangGraph : c'est une fonction `async` qui enchaîne
cinq appels, avec un `while` borné pour la reprise après un jugement négatif.

```dart
Future<AgentResult> runAgent(Offer offer, Context ctx) async {
  var state = AgentState(offer: offer);
  state = await analyze(state, ctx);      // scoring fin + template de lettre
  state = await research(state, ctx);     // grounding entreprise
  var attempts = 0;
  do {
    state = await accroche(state, ctx);   // accroche de la lettre
    state = await judge(state, ctx);      // relecture critique
    attempts++;
  } while (state.verdict == Verdict.retry && attempts < 3);
  return validate(state, ctx);            // garde-fous anti-invention
}
```

Les garde-fous du projet restent non négociables et se portent tels quels :
`sanitize_personalisation` (aucune compétence ni projet qui ne soit dans le CV),
`no_dash`, et surtout **aucun envoi automatique**. L'application produit des PDF
et s'arrête là ; c'est toi qui les envoies, depuis ta messagerie.

## La cible de partage : le cœur du produit

Sur Android, l'application se déclare comme **cible de partage** (`ACTION_SEND`,
texte et URL). Tu es dans l'application LinkedIn, Indeed, ou sur une offre Welcome
to the Jungle dans le navigateur ; tu appuies sur « Partager », tu choisis Job
Hunter ; l'application reçoit le titre, le texte et l'URL de l'offre, la score,
l'enrichit, et génère le CV et la lettre.

C'est la fonctionnalité qui justifie l'existence de la version mobile, pour deux
raisons.

Elle **récupère l'essentiel de ce que l'abandon de JobSpy fait perdre**. Plus
besoin de scraper LinkedIn ou Indeed : c'est toi qui passes l'offre à
l'application, en un geste, depuis leur application officielle.

Elle **résout le problème des pages dynamiques**. Sur ces sites, l'extraction du
contenu depuis une simple URL revient vide, et il faut aujourd'hui coller le texte
à la main. Le partage Android, lui, transmet directement le contenu.

Le pipeline de collecte automatique reste utile, mais il est secondaire : c'est
lui qui posera le plus de problèmes techniques (voir les points de vigilance) pour
le moins de valeur. Le partage est simple à implémenter et transforme l'usage.

**Constat vérifié sur appareil (20/07/2026)** : les apps officielles LinkedIn ET
France Travail (Parcours Emploi) ne partagent **qu'une URL nue**, sans titre ni
entreprise, et le **partage navigateur** (WTTJ via DuckDuckGo, vérifié aussi le
20/07) fait pareil du point de vue de Candid. Le parseur détecte bien la source
depuis l'URL et, fidèle à la règle « ne brode jamais », admet l'inconnue et
demande à l'utilisateur de compléter titre + entreprise, au lieu d'inventer.
Trois conséquences actées :

1. **Déduplication sur l'URL** (`dedupHash`, fait) : quand une URL est présente,
   elle est l'identité de l'offre. Sans ça, un même partage re-tapé avec un titre
   légèrement différent créait un doublon. Repli sur le hash titre+entreprise
   pour les offres sans URL.
2. **Résolution d'URL France Travail** (piste, étape 6) : une fois les
   identifiants FT en place pour la collecte, une URL `francetravail.fr` partagée
   pourra être résolue via l'API (l'identifiant de l'offre est dans l'URL) pour
   remplir titre/entreprise/description automatiquement. Le geste passe de
   « partager puis tout retaper » à « partager, c'est fait ». C'est la vraie
   réponse à la friction du partage URL seule.
3. **Lire `EXTRA_SUBJECT`** (piste, à évaluer) : le partage navigateur affiche
   pourtant le titre de page (« Jobs | Welcome to the Jungle ») dans la feuille
   système. Ce titre voyage dans l'extra `EXTRA_SUBJECT` de l'intent, que
   `receive_sharing_intent` ne remonte pas (il ne lit que `EXTRA_TEXT`). Le
   récupérer en natif (petit `MethodChannel` côté Android, ou plugin qui l'expose)
   pré-remplirait le titre depuis les partages navigateur : sur une vraie page
   d'offre, le `<title>` porte en général le poste et l'entreprise. Ça ne coûte
   rien côté friction et ne viole pas « ne brode jamais » (c'est une donnée
   réelle fournie par la source, pas une invention).

## Ordre de construction

Chaque étape est utilisable seule, et on ne passe à la suivante qu'une fois la
précédente vérifiée sur l'appareil. L'ordre est délibéré : on construit d'abord la
chaîne « une offre en entrée, un dossier de candidature en sortie », qui est le
cœur du produit. La collecte automatique, qui est la partie la plus fragile, vient
seulement après, quand le reste marche.

1. **Socle et base.** Projet Flutter, drift avec le schéma porté depuis
   `db/schema.sql`, écran de réglages qui enregistre les clés DeepSeek et France
   Travail dans le secure storage.
   *Acceptation :* les clés survivent au redémarrage de l'application.

2. **Entrée par partage.** L'application est déclarée cible de partage. Une offre
   partagée depuis n'importe quelle application arrive en base, normalisée, avec
   son hash et son score local.
   *Acceptation :* partager une offre LinkedIn depuis son application officielle
   crée bien l'entrée, avec un titre et une entreprise corrects.

3. **Rendu PDF.** Les deux documents en widgets Dart via le package `pdf`, avec
   aperçu et partage du fichier. Sans l'agent pour l'instant : on rend le CV
   maître, tel quel.
   *Acceptation :* le PDF s'ouvre et se partage par mail depuis le téléphone.
   Ne pas chercher la parité au pixel près avec `apercus/cv-1.pdf` : un template
   propre suffit, c'est un puits sans fond.

4. **L'agent.** Le graphe complet, alimenté par le prompt système existant. À ce
   stade, la boucle est bouclée : partager une offre produit un dossier complet.
   *Acceptation :* sur une offre réelle, la lettre produite passe les garde-fous
   (rien d'inventé, aucun tiret cadratin) et l'accroche cite un fait vérifiable
   sur l'entreprise.

5. **Suivi.** Candidatures, statuts, relances.
   *Acceptation :* le cycle complet, du partage à « envoyée », tient sans quitter
   l'application.

6. **Collecte automatique.** France Travail + La Bonne Alternance, dédup, écran de
   liste triée par score avec triage au balayage. Puis `workmanager`, une fois par
   jour, avec notification locale.
   *Acceptation :* un second appui sur « Collecter » n'ajoute aucun doublon, et la
   notification arrive sans ouvrir l'application.

7. **Facultatif.** Dédup sémantique embarquée (MiniLM quantifié en ONNX,
   similarité cosinus en Dart sur SQLite), digest hebdomadaire, et candidature
   spontanée depuis les entreprises remontées par La Bonne Alternance.

## Points de vigilance

**Les clés API.** Rien en dur dans le code : tout ce qui est compilé dans un APK
est extractible. L'utilisateur saisit ses clés au premier lancement, elles vont
dans `flutter_secure_storage` (Keystore Android).

**Le coût DeepSeek** est inchangé, puisque c'est le même nombre d'appels. Prévois
juste un garde-fou côté application (par exemple, ne pas lancer l'agent sur plus
de N offres par jour), parce que sur mobile un bouton se presse plus vite.
DeepSeek fait par ailleurs du cache automatique sur les préfixes constants :
construire les messages avec le prompt système et le cv-index toujours en tête,
dans le même ordre, et l'offre à la fin, fait payer le gros du contexte au tarif
« cache hit » sur chacun des 5 nœuds du graphe.

**La collecte en arrière-plan** est soumise aux restrictions de batterie
d'Android, et les intervalles ne sont jamais garantis à la minute près. Pour une
collecte quotidienne c'est sans importance, mais il ne faut pas compter dessus
pour du temps réel.

**La reprise des données existantes.** Le dump PostgreSQL de la migration
(`/mnt/Data/Dev/migration-n8n/db/`) contient tes offres et tes candidatures. Un
petit script d'import ponctuel vers SQLite est possible si tu veux repartir avec
l'historique, mais ce n'est pas indispensable pour démarrer.
