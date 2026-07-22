---
title: L'agent
---

# L'agent

[← Retour](index.html)

L'agent transforme une offre en dossier de candidature. C'est la partie où le
risque d'invention est le plus élevé, donc celle qui porte le plus de
garde-fous.

Port de `graph.py` (LangGraph) du projet Docker vers du Dart asynchrone.

## Le graphe

```
  analyze ──► research ──► accroche ──► judge ──┐
  (LLM,       (INSEE,      (LLM,         (règles)│
   t=0.2)      sans LLM)    t=0.7)               │
                              ▲                  │
                              └── problèmes ─────┤ (max 3 tours)
                                                 ▼
                                             validate
                                          (déterministe)
```

| Nœud | Nature | Ce qu'il produit |
|---|---|---|
| `analyze` | LLM, température 0.2 | score, recommandation, conseils, personnalisation du CV |
| `research` | **HTTP, sans LLM** | faits vérifiables sur l'entreprise |
| `accroche` | LLM, température 0.7 | les 2-3 phrases d'ouverture de la lettre |
| `judge` | **code pur** | liste de problèmes dans l'accroche |
| `validate` | **code pur** | fusion finale + garde-fous |

Deux nœuds sur cinq n'utilisent aucun LLM. C'est voulu : **tout ce qui peut être
décidé par des règles l'est par des règles**, parce qu'une règle ne dérive pas.

## Le grounding : des faits, pas des souvenirs

`research` interroge `recherche-entreprises.api.gouv.fr` — le registre officiel,
**sans clé** — et rend des faits bruts : date de création, activité, effectifs,
commune du siège.

Si l'API ne répond pas, le champ reste vide et l'accroche s'écrit sans. Elle
n'invente pas pour combler.

> **Vérifié le 21/07/2026.** Sur une offre Doctolib, l'agent a produit :
> *« Doctolib révolutionne l'accès aux soins depuis 2013… »*. Recoupé au
> registre : `date_creation: 2013-07-15`. Le fait est vérifiable, pas
> hallucinatoire.

## Les garde-fous

Ils sont dans `lib/agent/guards.dart`, **couverts par 18 tests**, et non
négociables.

### `noDash`

Retire les tirets cadratins des textes générés. Ils signent le texte de machine,
et le projet Docker les bannissait déjà.

### `checkAccroche`

Rend la **liste des problèmes** d'une accroche : clichés (« fort de mon
expérience », « c'est avec un grand intérêt »), longueur aberrante, tiret
cadratin. Une accroche fautive **déclenche une régénération**, jusqu'à trois
tours, avec les problèmes renvoyés au modèle.

### `sanitizePersonnalisation`

Le plus important. Le modèle choisit quoi mettre en avant et quoi masquer dans
le CV — mais il ne choisit **que parmi ce qui existe déjà** :

- rien qui soit à la fois mis en avant et masqué ;
- au plus un tiers des compétences masquées ;
- **au moins trois projets visibles** ;
- **un projet cité dans l'accroche n'est jamais masqué du CV**.

Cette dernière règle vient d'un défaut trouvé en conditions réelles.

> **Le 21/07/2026**, la lettre générée vantait le projet *InfiniDex*… que la
> personnalisation avait masqué du CV joint. Rien n'était inventé — le projet
> existe bien — mais le recruteur suivait une piste absente du document.
>
> La cause est structurelle : la personnalisation est décidée au nœud `analyze`,
> **avant** que l'accroche existe. Les garde-fous vérifiaient « rien d'inventé »,
> mais pas « les deux documents se tiennent ». La règle de cohérence a été
> ajoutée, avec son test.

## Le coût, tenu court

Un bouton se presse vite sur un téléphone. Deux mesures :

- **Plafond quotidien** (5 appels par défaut), **affiché** dans l'écran de
  détail : « 1/5 appels aujourd'hui ». Un plafond invisible ne protège personne.
- **Messages conçus pour le cache de préfixe** : le prompt système (17 158
  caractères, stable) vient en premier, l'offre variable ensuite. DeepSeek
  facture les tokens en cache environ dix fois moins.

## Multi-fournisseurs

Trois fournisseurs derrière une seule interface, tous compatibles OpenAI :

| Fournisseur | Position | Réserve |
|---|---|---|
| **DeepSeek** | par défaut | — |
| **OpenRouter** | alternative | mode gratuit, entraînement désactivable |
| **Gemini** | optionnel | **son offre gratuite entraîne sur les requêtes** : à réserver au non sensible |

Le modèle est configurable, jamais codé en dur. **Sans clé, l'agent se désactive
proprement** avec un message clair — l'application ne plante pas, elle se réduit
à une liste d'offres.

> Anthropic n'est pas un fournisseur : l'abonnement Pro ne donne pas d'accès API.
> Claude a servi à *construire* Candid, pas à le faire tourner.

[← Modèle de données](donnees.html) · [Les sources →](sources.html)
