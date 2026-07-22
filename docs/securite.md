---
title: Sécurité et vie privée
---

# Sécurité et vie privée

[← Retour](index.html)

Audit complet mené le **22 juillet 2026**. Les résultats ci-dessous ont été
mesurés sur le dépôt, sur l'APK installé et sur l'appareil, pas déduits.

## Résumé

| Vérification | Résultat |
|---|---|
| Secrets en dur (code, assets, Gradle) | **aucun** |
| Secrets dans l'historique git (194 blobs, tous commits) | **aucun** |
| Secrets dans les journaux (`print` / `debugPrint`) | **aucun** |
| Trafic sortant | **8 hôtes, tous HTTPS** |
| Trafic en clair | bloqué (aucune dérogation) |
| Fichiers produits | `-rw-------`, stockage privé |
| Injection SQL | impossible (requêtes paramétrées) |
| Sauvegarde Android | **désactivée** |
| Permissions dangereuses | **aucune** |

## Les clés API

**Aucune clé n'est versionnée, et aucune ne doit l'être.** Tout ce qui est
compilé dans un APK est extractible en quelques minutes.

L'utilisateur les saisit lui-même, elles vont dans `flutter_secure_storage`
(Keystore Android, chiffrement AES-SIV via Tink, clé maîtresse non exportable).

### Ce qu'une extraction donne réellement

Testé sur l'appareil, en conditions d'attaquant :

```
$ adb shell run-as com.benjsant.candid cat shared_prefs/FlutterSecureStorage.xml
<string name="…_deepseek_api_key">EHRzjCpcp1Sa8sAK0lLUXQSIBhiB7e/KMCK7…</string>
```

Le fichier est lisible, **son contenu ne l'est pas**. La clé de déchiffrement
est dans le Keystore matériel, non exportable : le fichier copié ailleurs est
inexploitable.

Deux réserves honnêtes :

1. **`run-as` n'a fonctionné que parce que l'APK installé est un build debug.**
   Sur un build release, la commande est refusée.
2. Le scénario exige un **accès physique au téléphone déverrouillé, avec le
   débogage USB actif**. Quiconque réunit ces conditions a de plus gros leviers
   qu'une clé DeepSeek.

## Ce qui sort de l'appareil

C'est le point qui mérite le plus de franchise.

### Vers le fournisseur LLM (DeepSeek par défaut)

Mesuré, pas supposé :

| Donnée | Envoyée ? |
|---|---|
| Noms des compétences, projets, expériences (1 163 caractères) | **oui** |
| Texte de l'offre | **oui** |
| **Nom et prénom du candidat** (dans le prompt système) | **oui** |
| Adresse email | non |
| Numéro de téléphone | non |
| Adresse postale | non |

C'est raisonnable, mais ce n'est pas rien : **le nom et le parcours transitent
chez un tiers**. Le choix du fournisseur est donc un choix de confidentialité,
et l'écran de réglages le dit, notamment pour Gemini, dont l'offre gratuite
entraîne sur les requêtes.

### Vers les API publiques

Registre des entreprises, découpage administratif, France Travail, La Bonne
Alternance. Ce qui part : un nom d'entreprise, un nom de ville, des mots-clés.
**Aucune donnée personnelle.**

### Nulle part ailleurs

Pas de télémétrie, pas d'analytics, pas de crash reporting, pas de compte.
L'historique de candidatures **ne quitte l'appareil que si l'utilisateur
l'exporte lui-même**.

## Permissions Android

Sept, relevées sur l'APK installé :

| Permission | Pourquoi |
|---|---|
| `INTERNET` | les API |
| `ACCESS_NETWORK_STATE` | contrainte réseau des tâches de fond |
| `POST_NOTIFICATIONS` | notifications (Android 13+) |
| `FOREGROUND_SERVICE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED` | `workmanager` |
| `VIBRATE` | notifications |

**Aucune permission dangereuse** : ni localisation, ni contacts, ni stockage
externe, ni caméra, ni téléphone.

## Sauvegarde désactivée

```xml
android:allowBackup="false"
android:dataExtractionRules="@xml/data_extraction_rules"
android:fullBackupContent="@xml/backup_rules"
```

Par défaut, Android sauvegarde les `shared_prefs` : le fichier chiffré des clés
et l'historique quitteraient l'appareil. Le fichier resterait indéchiffrable
sans le Keystore, mais il n'y a aucune raison de l'exposer.

> Vérifié sur l'appareil : `ALLOW_BACKUP` a disparu des `pkgFlags`.

La sauvegarde voulue passe par l'**export JSON** de l'onglet Suivi, qui ne
contient aucun secret.

## Correctifs apportés par l'audit

**Export temporaire persistant.** L'export contient tout l'historique de
candidatures et restait indéfiniment dans le cache : un export du 20/07 y dormait
encore. Il est désormais effacé après le partage, avec les exports d'anciennes
versions. Le nettoyage est en `finally` et ne fait jamais échouer un export
réussi.

## Ce qui reste ouvert

### Le build release est signé avec la clé de debug

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

Sans conséquence pour un usage personnel. **Bloquant pour toute distribution** :
n'importe qui pourrait signer une mise à jour. Il faut créer un keystore, ce
qui suppose un mot de passe que seul l'utilisateur doit choisir.

### L'application installée est un build debug

Elle est `debuggable`, donc `adb run-as` accède à ses données. Un build release
ferme cette porte, et divise la taille par huit :

```bash
flutter build apk --release --split-per-abi   # ~22 Mo arm64
```

## Surface d'attaque

Un seul composant exporté : l'activité principale, cible de partage. Elle
n'accepte que du `text/plain`, qui est **analysé puis présenté à l'utilisateur
avant tout enregistrement**. Une application malveillante ne peut donc, au pire,
que proposer une fausse offre, que l'utilisateur voit et refuse.

Aucun `Service`, `Receiver` ni `Provider` exporté.

[← Les sources](sources.html) · [Qualité et tests →](qualite.html)
