/// Déduplication par hash. Port fidèle de `reference/offer-utils.mjs`.
///
/// La dédup sémantique (pgvector, similarité cosinus) n'est PAS portée en V1 :
/// elle exigerait un modèle d'embedding embarqué. Le hash attrape déjà la
/// grande majorité des doublons. Voir l'étape 7 de TASKS.md.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:diacritic/diacritic.dart';

/// Minuscules, accents repliés, espaces compactés.
///
/// Le repli des accents est ce qui rend la déduplication accent-insensible :
/// « Développeur » et « Developpeur » doivent donner le même hash. Dart n'a pas
/// de normalisation Unicode dans son cœur, d'où le paquet `diacritic`.
String norm(Object? s) {
  if (s == null) return '';
  return removeDiacritics(s.toString().toLowerCase())
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Canonicalisation du titre : réduit les quasi-doublons entre sources, où le
/// même poste s'écrit « (H/F) », « F/H », avec ou sans ponctuation.
String canonTitle(Object? t) {
  return norm(t)
      .replaceAll(RegExp(r'\(.*?\)'), ' ') // (H/F), (CDI), ...
      .replaceAll(RegExp(r'\b[hf]\s*/\s*[hfx]\b'), ' ')
      .replaceAll(RegExp(r'\bf\s*/\s*h\b'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Canonicalisation de l'entreprise : « ACME SAS » et « Acme » sont la même.
String canonCompany(Object? c) {
  return norm(c)
      .replaceAll(
        RegExp(r'\b(sas|sasu|sarl|sa|eurl|inc|ltd|llc|gmbh|group|groupe)\b'),
        ' ',
      )
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Canonicalisation du lieu : retire « France » et les codes INSEE ou de
/// département (« 59 - Lille »).
String canonLocation(Object? l) {
  return norm(l)
      .replaceAll(RegExp(r'\bfrance\b'), ' ')
      .replaceAll(RegExp(r'[^a-z ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Le hash de déduplication : SHA256 du titre, de l'entreprise et du lieu
/// canonicalisés. Deux offres de même hash sont la même offre.
String computeHash({String? title, String? company, String? location}) {
  final key = [
    canonTitle(title),
    canonCompany(company),
    canonLocation(location),
  ].join('|');
  return sha256.convert(utf8.encode(key)).toString();
}

/// URL canonique pour la déduplication : minuscules, sans fragment (#…), sans
/// slash final. Renvoie null si vide (`.../4435206974` == `.../4435206974/`).
String? canonUrl(String? url) {
  final u = (url ?? '').trim().toLowerCase();
  if (u.isEmpty) return null;
  return u.replaceFirst(RegExp(r'#.*$'), '').replaceFirst(RegExp(r'/+$'), '');
}

/// Clé de déduplication d'une offre.
///
/// Constat vérifié sur appareil (20/07) : les apps officielles (LinkedIn,
/// France Travail) ne partagent qu'une URL. L'utilisateur tape le titre à la
/// main, donc le hash titre+entreprise varie d'un partage à l'autre pour une
/// MÊME offre. Quand une URL est présente, elle EST l'identité de l'offre : on
/// déduplique dessus, robuste à la saisie. Sinon (offre sans URL, collecte
/// future sans lien direct), on retombe sur le hash titre+entreprise+lieu.
///
/// Contrepartie assumée : deux annonces d'une même offre sur deux sites (URLs
/// différentes) ne sont plus fusionnées. Acceptable pour une app pilotée par le
/// partage, où l'utilisateur partage chaque annonce délibérément.
String dedupHash({String? url, String? title, String? company, String? location}) {
  final cu = canonUrl(url);
  if (cu != null) return sha256.convert(utf8.encode('url:$cu')).toString();
  return computeHash(title: title, company: company, location: location);
}
