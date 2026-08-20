# Restauration du profil et des clés

> Ce fichier existe parce que j'ai désinstallé l'application pour tester le
> build release, ce qui a effacé la base et le coffre-fort. Les valeurs
> ci-dessous sont celles qui étaient en place avant. **Aucune clé n'est écrite
> ici** : elles restent dans le `.env` du projet Docker.

## 1. Profil de recherche

Réglages → **Profil de recherche**.

### Communes

Taper le nom, appuyer sur la **loupe**, puis choisir dans la liste proposée.
Les codes INSEE servent à vérifier que la bonne commune est retenue.

| Ville à taper | Code INSEE attendu |
|---|---|
| `Valenciennes` | 59606 |
| `Lille` | 59350 |
| `Douai` | 59178 |

**Rayon** : 30 km.

### Mots-clés

```
développeur, python, intelligence artificielle
```

Les virgules comptent : France Travail fait un **ET** entre les mots d'un même
terme, donc « développeur python » en un seul bloc ne renvoie rien. Une virgule
= une recherche séparée.

### Le reste

| Champ | Valeur |
|---|---|
| Niveau visé | Peu importe |
| Types de contrat | *(vide)* |
| Indispensables | *(vide)* |
| Exclusions | *(vide)* |

## 2. Clés API

Réglages → section **Clés API**. Elles se trouvent déjà dans :

```
/mnt/Data/Dev/n8n_jobs_pipeline/.env
```

| Champ dans Candid | Ligne du `.env` |
|---|---|
| Clé DeepSeek | `DEEPSEEK_API_KEY` |
| France Travail : client id | `FRANCE_TRAVAIL_CLIENT_ID` |
| France Travail : client secret | `FRANCE_TRAVAIL_CLIENT_SECRET` |
| Clé La Bonne Alternance | `LBA_API_KEY` |

> Les quatre ont déjà été ressaisies le 23/07 (« 4 clé(s) enregistrée(s) »).
> À ne refaire que si l'écran ne les montre plus comme « Enregistrée sur cet
> appareil ».

Pour les copier depuis le PC vers le téléphone :

```bash
# affiche une clé pour la copier (attention : elle s'affiche en clair)
grep '^DEEPSEEK_API_KEY=' /mnt/Data/Dev/n8n_jobs_pipeline/.env | cut -d= -f2-
```

## 3. Offres

Rien à ressaisir : le bouton **Collecter** (icône nuage, onglet Offres) les
retrouve toutes en un appui, une fois le profil et les clés en place.

Les entreprises « À démarcher » reviennent par la même collecte.

## 4. Ce qui est perdu pour de bon

La candidature suivie (« Développeur IA Junior chez ACME ») était une entrée de
test que j'avais créée pour vérifier l'onglet Suivi. Rien de réel n'a été perdu
de ce côté.
