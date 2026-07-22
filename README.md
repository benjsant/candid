# Candid

> L'assistant de candidature qui ne brode jamais. Il ne vous invente ni
> compétence, ni expérience, et n'envoie rien sans vous.

Application Android **entièrement autonome** : pas de serveur, pas
d'hébergement. Tout tourne sur le téléphone ; les seuls appels sortants vont
vers des API publiques.

```
offre partagée depuis LinkedIn / France Travail / WTTJ
  → normalisation + déduplication + scoring local
  → agent LLM (analyse → grounding INSEE → accroche → juge → validation)
  → CV ciblé + lettre en PDF, sur l'appareil
  → relecture humaine, puis envoi manuel par vous
```

Accessoirement, l'application collecte aussi toute seule (France Travail, La
Bonne Alternance) et notifie.

Compagnon mobile du projet Docker
[job_hunter](https://github.com/benjsant/job_hunter), et **pas un portage à
parité** : le mobile a moins de sources, et compense par la cible de partage
Android que la version Docker ne peut pas avoir.

📖 **[Documentation technique complète](https://benjsant.github.io/candid/)** :
architecture, modèle de données, agent, sources, audit de sécurité, couverture
de tests et journal des décisions.

## Les trois règles qui ne se négocient pas

L'application **assiste**, elle ne se substitue jamais. Elle ne doit **jamais** :

1. inventer une compétence, une expérience, une certification, une mission ;
2. envoyer automatiquement une candidature ou un email ;
3. modifier des données personnelles sans validation.

Elle produit des PDF et s'arrête là. C'est vous qui envoyez, après relecture.
Ces règles sont tenues par du code testé (`lib/agent/guards.dart`,
`lib/domain/dedup.dart`) : si vous les touchez, des tests tombent. C'est voulu.

## Démarrer sur une machine neuve

```bash
git clone https://github.com/benjsant/candid.git
cd candid
flutter pub get
flutter test          # 171 tests, doit être vert
flutter run           # sur un appareil branché en USB
```

C'est tout. Vérifié sur un clone vierge : `flutter pub get` puis
`flutter build apk` produisent un APK sans aucune étape manuelle. Le wrapper
Gradle et `android/local.properties` sont régénérés par Flutter, c'est normal
qu'ils soient absents du dépôt.

### Prérequis

| | Version utilisée | Note |
|---|---|---|
| Flutter | **3.44.6** (stable) | Dart SDK `^3.12.2` |
| SDK Android | plateformes **36 et 37** | `compileSdk = 37` est exigé par `receive_sharing_intent` |
| JDK | **Temurin 21** | un JRE ne suffit pas, Gradle a besoin de `javac` |
| Gradle | 9.1.0 | via le wrapper, rien à installer |

`minSdk` suit Flutter (**24**, soit Android 7.0), donc l'application couvre la
quasi-totalité du parc.

Le SDK Android et le JDK se déclarent **à Flutter**, pas en variables
d'environnement :

```bash
flutter config --android-sdk /chemin/vers/Android/Sdk
flutter config --jdk-dir     /chemin/vers/jdk-21
flutter doctor               # doit être vert
```

Redémarrez l'éditeur après un changement de config, sinon il ne voit pas
l'appareil.

## Les clés API : jamais dans le dépôt

**Aucune clé n'est versionnée, et aucune ne doit l'être.** Tout ce qui est
compilé dans un APK est extractible en quelques minutes.

Vous les saisissez vous-même au premier lancement, dans **Réglages**. Elles
vont dans `flutter_secure_storage` (Keystore Android).

| Clé | Débloque | Sans elle |
|---|---|---|
| DeepSeek *(ou OpenRouter, ou Gemini)* | l'agent : accroche, CV ciblé, jugement | l'application se réduit à une liste d'offres |
| France Travail (client id + secret) | collecte FT **et** résolution des URL partagées | collecte FT désactivée |
| La Bonne Alternance | offres d'alternance + entreprises à démarcher | source LBA désactivée |

Une clé absente **désactive proprement** la fonctionnalité, avec un message
clair. Rien ne plante. C'est testé.

Deux API sont utilisées **sans clé** : le registre des entreprises
(`recherche-entreprises.api.gouv.fr`, qui ancre l'accroche sur des faits
vérifiables) et le découpage administratif (`geo.api.gouv.fr`, qui résout les
villes en codes INSEE).

## Cycle de développement

```bash
flutter analyze     # zéro warning attendu, c'est la règle
flutter test        # toute la suite, quelques secondes

# OBLIGATOIRE après toute modification de lib/data/database.dart :
dart run build_runner build --delete-conflicting-outputs

flutter run         # sur l'appareil branché
```

**Le schéma de base est en version 2.** Des installations réelles existent :
tout changement de schéma exige d'incrémenter `schemaVersion` **et** d'écrire
sa migration dans `lib/data/database.dart`. Le protocole éprouvé : sauvegarder
la base de l'appareil avant, n'ajouter que des colonnes nullables, vérifier les
comptes après.

### Livrable

```bash
flutter build apk --release --split-per-abi   # ~22 Mo pour arm64
```

Le build **debug** pèse ~180 Mo (kernel JIT, moteurs non strippés) : ce n'est
pas un problème à corriger. En revanche il est `debuggable`, donc `adb run-as`
peut lire les données de l'application. Préférez un build release dès que vous
utilisez Candid pour de vrai.

> ⚠️ Le build release est actuellement signé avec la **clé de debug**. Sans
> conséquence pour un usage personnel, bloquant pour toute distribution : il
> faut créer un keystore.

## Vérifier sur un appareil réel

La règle du projet : **on ne coche une étape qu'après vérification sur un
téléphone**, pas sur l'émulateur.

```bash
adb exec-out screencap -p > /tmp/capture.png
```

`scrcpy` sert à l'humain (miroir de l'écran) ; les captures `adb` servent à
vérifier, y compris par un assistant, qui ne voit pas votre écran.

## Où lire quoi

| Fichier | Contenu |
|---|---|
| [CLAUDE.md](CLAUDE.md) | les règles du projet, à lire en premier |
| [PLAN.md](PLAN.md) | l'architecture et le raisonnement derrière l'ordre de construction |
| [TASKS.md](TASKS.md) | le plan de build, coché, avec les critères d'acceptation vérifiés |
| [CONTEXTE.md](CONTEXTE.md) | la mémoire de session : décisions, pièges rencontrés, journal daté |
| `reference/` | les originaux du projet Docker, pour porter sans changer de dépôt |
| [`docs/`](https://benjsant.github.io/candid/) | la documentation technique publiée (GitHub Pages) |

Les **pièges rencontrés en vrai** sont consignés dans TASKS et CONTEXTE, avec
la date et la preuve. Quelques-uns valent d'être lus avant de toucher au code :

- **`motsCles` de France Travail fait un ET**, limité à 3 mots. Une liste de
  mots-clés y renvoie zéro résultat. On envoie une requête par terme.
- **`geo.api.gouv.fr` refuse les listes** sur `code` et répond `200 []` sans
  erreur. Un appel par commune.
- **Les applications officielles ne partagent qu'une URL nue.** Les regex
  « Titre chez Entreprise » ne se déclenchent sur aucune source réelle testée :
  ne pas les « améliorer » sans capture réelle.
- **Les surcouches constructeur tuent les tâches de fond.** Sur ColorOS, le
  processus est gelé dix secondes après son réveil. La collecte manuelle reste
  la voie fiable, et l'interface le dit.

## État

Étapes 1 à 6 **faites et validées sur appareil réel**, étape 7 entamée
(candidature spontanée, rapprochement inter-sources, digest hebdomadaire).
171 tests, `flutter analyze` propre.

## Licence

Voir [LICENSE](LICENSE).
