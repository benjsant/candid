---
title: Les sources
---

# Les sources

[← Retour](index.html)

Quatre voies d'entrée, et un principe commun : **un champ absent reste vide**.
Jamais deviné, jamais comblé.

## 1. Le partage Android — la voie principale

L'application est déclarée cible `ACTION_SEND` / `text/plain`. Depuis LinkedIn,
France Travail ou un navigateur, « Partager » puis « Candid ».

C'est la force propre du mobile : la version Docker ne peut pas l'avoir.

### Le constat qui a tout changé

> **20/07/2026, sur appareil.** LinkedIn, France Travail et Welcome to the
> Jungle ne partagent **qu'une URL nue**. Ni titre, ni entreprise.
>
> Conséquence : les regex « Titre chez Entreprise » du parseur **ne se
> déclenchent sur aucune source réelle testée**. Elles restent en place pour les
> partages manuels, mais ne pas les « améliorer » sans capture réelle.

Découverte annexe : le navigateur envoie bien le titre de la page, mais dans
`EXTRA_SUBJECT` — que le plugin `receive_sharing_intent` ne remonte pas. Piste
notée, non implémentée.

### La réponse : résoudre l'URL

Une URL France Travail porte l'identifiant de l'offre :

```
https://candidat.francetravail.fr/offres/recherche/detail/210RHTN
                                                        └─ id ─┘
```

`franceTravailOfferId()` l'extrait, `offerById()` interroge l'API, et l'écran de
réception se remplit seul : titre, entreprise, lieu, contrat, **et surtout la
description officielle**.

Ce dernier point est le vrai gain : **2 390 caractères d'annonce réelle** au
lieu d'une URL de 64 caractères. C'est ce que lira l'agent, et c'est ce qui rend
le score significatif.

Deux prudences : le pré-remplissage **n'écrase jamais** ce que l'utilisateur a
saisi, et un identifiant périmé rend `null` plutôt que d'interrompre le partage.

## 2. France Travail

OAuth `client_credentials`, puis `/offres/search`. Le jeton vit ~25 minutes et
est **mis en cache** : le redemander à chaque recherche serait un appel gratuit
en plus.

### Piège n° 1 : `motsCles` est un ET

> **Mesuré le 21/07/2026** autour de Valenciennes :
>
> | Requête | Résultat |
> |---|---|
> | `développeur python intelligence artificielle` | **HTTP 204** — zéro |
> | `développeur,python` | 5 offres |
> | `python` | 7 offres |
>
> L'API exige que **tous** les mots figurent dans l'offre, et n'en accepte que
> trois. Envoyer une liste de mots-clés garantit de ne rien trouver.

La collecte envoie donc **une requête par terme**, puis fusionne. La virgule
sépare les recherches ; **sans virgule, on sépare sur les espaces**, parce que
quelqu'un qui tape « développeur python ia » veut trois recherches, pas une
offre contenant les trois mots.

### Piège n° 2 : sans commune, c'est toute la France

Sans profil de recherche, la requête part sans `commune` ni `distance`. Le
filtre de scoring `isOutOfZone` n'écarte que l'étranger, pas les villes
françaises lointaines.

> Résultat mesuré : **150 offres, dont Toulouse, Lyon et Montpellier notées 92**
> — mieux que les offres locales. D'où l'écran de profil de recherche, et son
> avertissement tant qu'aucune commune n'est retenue.

Après correction : Valenciennes + Lille + Douai, 30 km → **114 offres, aucune
hors 59/62**.

Bonne surprise : `commune` accepte **plusieurs codes INSEE** séparés par des
virgules, et c'est une vraie union (vérifié avec `59606,31555`, qui rend des
offres des deux départements). Plusieurs communes ne coûtent donc **aucun appel
supplémentaire**.

## 3. La Bonne Alternance

`/api/job/v1/search`, clé en Bearer, recherche par **latitude/longitude + rayon
+ codes ROME** (défaut `M1805`, études et développement informatique).

La réponse contient **deux listes de nature différente**, et les confondre serait
une faute :

| | Contenu | Traitement |
|---|---|---|
| `jobs` | offres d'alternance publiées | enregistrées comme offres |
| `recruiters` | entreprises qui embauchent, **sans offre publiée** | enregistrées comme **entreprises** |

Une entreprise sans poste publié **ne devient jamais une annonce**. Lui
fabriquer un intitulé serait exactement ce que le projet s'interdit. Elles
apparaissent dans l'onglet « À démarcher », qui le dit en toutes lettres.

> **Mesuré le 22/07/2026** : 194 entreprises collectées, **aucune avec
> description**, et rien dans la boîte aux offres. Contacts réellement
> disponibles : lien 194/194, téléphone 59/194, **email 0/194**. L'écran
> n'affiche que les boutons possibles.

## 4. Géocodage

`geo.api.gouv.fr`, **sans clé**. France Travail filtre par code INSEE, La Bonne
Alternance par coordonnées : l'utilisateur tape « Valenciennes », le reste est
résolu.

> **Piège rencontré.** Le paramètre `code` **n'accepte pas de liste** :
> `code=59606,59350` répond **`200 []`**, sans erreur. Avoir supposé le contraire
> désactivait silencieusement toute la source LBA — le seul indice était le
> message « aucune commune localisable ».
>
> Une API qui répond 200 avec un corps vide est plus dangereuse qu'une qui
> échoue franchement. Un appel par commune, verrouillé par un test.

## Rapprochement inter-sources

La Bonne Alternance rediffuse les offres France Travail sans le nom de
l'employeur : deux entrées pour une seule offre.

**Le modèle d'embeddings prévu au plan n'a pas été embarqué**, et c'est un choix
argumenté. L'examen des 125 offres réellement collectées montre que « même
titre » ne veut pas dire « même offre » :

```
Data manager (H/F) | NEW NET 3D | Lille
Data manager (H/F) | ADECCO     | Villeneuve-d'Ascq
Data manager (H/F) | LE CABRH   | Croix
```

Trois entreprises, trois vraies offres. Une similarité large les aurait
fusionnées et **aurait caché des offres auxquelles postuler**. Le coût d'une
erreur est asymétrique : mieux vaut afficher deux fois que masquer une fois.

La règle exige donc **simultanément** :

1. des **sources différentes** — deux annonces d'une même source sont deux
   offres, même homonymes (quatre « Développeur web » à Lille, agences
   différentes) ;
2. le **même titre** canonicalisé ;
3. la **même ville** — `« 59 - Roubaix »` et `« 59100 Roubaix »` se rejoignent ;
4. des **entreprises compatibles** — identiques, ou l'une non renseignée.

> Passée sur les 125 offres réelles : **une seule paire rapprochée**, exactement
> le doublon documenté. Vérifié sur appareil : version LBA supprimée, collecte
> relancée, non réajoutée.

Zéro dépendance, zéro mégaoctet, neuf tests.

[← L'agent](agent.html) · [Sécurité →](securite.html)
