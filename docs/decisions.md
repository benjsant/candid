---
title: Décisions
---

# Décisions structurantes

[← Retour](index.html)

Chaque décision est datée et porte sa raison. Une décision dont on a oublié le
motif finit toujours par être défaite par erreur.

---

## Candid n'est pas un client du projet Docker
**15/07/2026**

**Décision.** Application autonome, pas un client de l'API de `job_hunter`.

**Pourquoi.** Un client dépendrait d'un PC allumé. Surtout, le mobile a une
force que la version Docker ne peut pas avoir : **la cible de partage Android**.

**Conséquence assumée.** Moins de sources (pas de scraping LinkedIn/Indeed).
Viser la parité coûterait des semaines pour un résultat qui en ferait moins.

---

## Le profil candidat ne va pas en base
**15/07/2026**

**Décision.** Le CV maître vit dans `assets/cv/*.json`, embarqué. La table
`profile` du schéma d'origine n'est pas portée.

**Pourquoi.** Ces données ne changent pas au fil de l'usage. Une table serait de
la complexité sans contrepartie.

---

## LLM multi-fournisseurs derrière une interface
**16/07/2026**

**Décision.** DeepSeek par défaut, OpenRouter et Gemini en option, tous derrière
`LlmClient`. Modèle configurable, jamais codé en dur.

**Pourquoi.** Les tarifs et les conditions changent vite. Surtout, **le choix du
fournisseur est un choix de confidentialité** : l'offre gratuite de Gemini
entraîne sur les requêtes, ce que l'écran de réglages dit explicitement.

---

## Aucune clé dans le dépôt, aucune dans l'APK
**15/07/2026**

**Décision.** Pas de `.env`, pas de clé en dur, pas de clé dans les assets.
L'utilisateur saisit les siennes, elles vont dans le Keystore.

**Pourquoi.** Tout ce qui est compilé dans un APK est extractible en quelques
minutes.

**Corollaire.** Une clé absente **désactive proprement** la fonctionnalité. Elle
ne plante pas. C'est testé pour chaque source.

---

## La collecte de fond est désactivée par défaut
**22/07/2026**

**Décision.** Collecte quotidienne et digest hebdomadaire : deux réglages, tous
deux à l'arrêt au départ.

**Pourquoi.** Ils consomment batterie et réseau sans que l'utilisateur l'ait
demandé. Et sur beaucoup d'appareils, ils ne partiront pas.

> **Constaté dans les journaux, sur ColorOS :**
> ```
> OplusHansManager: freeze uid: 10267 com.benjsant.candid
> ```
> Le processus est **gelé dix secondes après son réveil**. Par ailleurs,
> « forcer l'arrêt » annule le travail planifié jusqu'à réouverture de
> l'application. C'est le mécanisme exact des tueurs de tâches.

**Conséquence.** Un bouton « Tester maintenant » a été ajouté : sur une
fonctionnalité dont la fiabilité dépend du constructeur, l'utilisateur doit
pouvoir vérifier **sur son appareil**, sans attendre un lendemain incertain.
L'écran affiche l'avertissement en clair.

---

## Pas d'embeddings pour la déduplication
**22/07/2026**

**Décision.** Le modèle MiniLM quantifié en ONNX prévu au plan **n'a pas été
embarqué**. Le rapprochement se fait par une règle étroite, en Dart pur.

**Pourquoi.** Les données réelles ont tranché. Sur 125 offres collectées :

```
Data manager (H/F) | NEW NET 3D | Lille
Data manager (H/F) | ADECCO     | Villeneuve-d'Ascq
Data manager (H/F) | LE CABRH   | Croix
```

Trois entreprises, trois vraies offres. Une similarité sémantique large les
aurait fusionnées et **aurait caché des offres auxquelles postuler**.

**Le principe.** Le coût d'une erreur est asymétrique : afficher deux fois gêne,
masquer une fois nuit. À incertitude égale, on montre.

**Résultat.** La règle rapproche exactement une paire sur 125 offres : le
doublon documenté. Zéro dépendance, zéro mégaoctet, neuf tests.

---

## Les entreprises à démarcher ne sont pas des offres
**22/07/2026**

**Décision.** Les `recruiters` de La Bonne Alternance vont dans `companies`,
jamais dans `offers`.

**Pourquoi.** Ce sont des entreprises **sans poste publié**. Leur fabriquer un
intitulé serait exactement ce que le projet s'interdit.

**Vérification.** 194 fiches collectées, **aucune avec description**, rien dans
la boîte aux offres. L'écran le dit en toutes lettres : « il n'y a donc pas de
poste à consulter ».

---

## Une requête par mot-clé, pas une requête par liste
**21/07/2026**

**Décision.** La collecte France Travail envoie un appel par terme, puis fusionne.

**Pourquoi.** `motsCles` fait un **ET**, limité à trois mots. Quatre mots
renvoyaient `HTTP 204`, soit zéro résultat, là où « python » seul en donnait sept.

**Affinement.** Sans virgule dans la saisie, on sépare sur les espaces : celui
qui tape « développeur python ia » attend trois recherches, pas une offre
contenant les trois mots. Sans ce repli, il obtenait zéro résultat sans
explication.

---

## Plusieurs communes, sans changement de schéma
**21/07/2026**

**Décision.** Les codes INSEE sont stockés en liste dans la colonne existante.

**Pourquoi.** `commune` de France Travail accepte plusieurs codes séparés par
des virgules, et c'est une **vraie union** (vérifié avec `59606,31555`). Le
format de stockage est donc exactement celui de la requête.

**Bénéfice.** Aucune migration à écrire alors que des installations réelles
tournaient déjà.

---

## Un projet cité dans la lettre n'est jamais masqué du CV
**21/07/2026**

**Décision.** `sanitizePersonnalisation` reçoit l'accroche et protège les
projets qu'elle nomme.

**Pourquoi.** Un défaut constaté en production : la lettre vantait un projet que
le CV joint masquait. Rien n'était inventé, mais le recruteur suivait une piste
absente du document.

**La leçon.** Les garde-fous vérifiaient « rien d'inventé » mais pas « les deux
documents se tiennent ». Une cohérence entre nœuds qui ne se voient pas doit
être imposée à la fin, au nœud de validation.

---

## Vérifier sur appareil, pas sur émulateur
**Depuis le début**

**Décision.** Une étape n'est cochée qu'après vérification sur un téléphone réel,
capture à l'appui.

**Pourquoi.** Les quatre pièges les plus coûteux du projet étaient **invisibles
en test unitaire** : les simulacres répondaient ce qu'on leur avait dit de
répondre. Il a fallu appeler les vraies API, sur le vrai appareil, pour les voir.

[← Qualité et tests](qualite.html) · [Retour à l'accueil](index.html)
