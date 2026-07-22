/// Rapprochement d'offres quasi identiques venues de **sources différentes**.
///
/// Le problème réel, constaté le 21/07/2026 : une même offre remonte par France
/// Travail et par La Bonne Alternance (qui rediffuse les offres FT). Le hash
/// porte sur titre + entreprise + lieu, et l'entreprise est nommée d'un côté,
/// vide de l'autre : deux entrées pour une seule offre.
///
/// **Pourquoi la règle est aussi étroite.** L'examen des 125 offres réellement
/// collectées montre que « même titre » ne veut pas dire « même offre » :
///
/// ```
/// Data manager (H/F) | NEW NET 3D   | Lille
/// Data manager (H/F) | ADECCO       | Villeneuve-d'Ascq
/// Data manager (H/F) | LE CABRH     | Croix
/// ```
///
/// Trois entreprises, trois vraies offres. Une déduplication « sémantique »
/// large les fusionnerait et **cacherait des offres auxquelles postuler**.
/// C'est le même contrat que partout ailleurs : on préfère montrer deux fois
/// que masquer une fois. La règle exige donc, simultanément :
///
///  1. des **sources différentes** (deux offres d'une même source sont deux
///     annonces distinctes, même homonymes) ;
///  2. le **même titre** canonicalisé ;
///  3. la **même ville** ;
///  4. des entreprises **compatibles** : identiques, ou l'une non renseignée
///     (le cas des offres partenaires anonymisées).
///
/// Aucun modèle embarqué, aucun vecteur : la logique tient en quelques
/// comparaisons, se teste, et n'ajoute pas trente mégaoctets à l'application.
library;

import 'hash.dart' show canonCompany, canonTitle, norm;

/// Extrait le nom de ville d'un libellé de lieu.
///
/// Les sources écrivent la même ville de façons très différentes :
/// « 59 - Roubaix » (France Travail), « 59100 Roubaix » (La Bonne Alternance),
/// « Roubaix (59) ». On retire codes postaux, numéros de département et
/// séparateurs pour ne garder que le nom.
String canonCity(String? location) {
  var s = norm(location);
  if (s.isEmpty) return '';
  // Codes postaux (5 chiffres) et numéros de département isolés.
  s = s.replaceAll(RegExp(r'\b\d{5}\b'), ' ');
  s = s.replaceAll(RegExp(r'\b\d{2,3}\b'), ' ');
  // Séparateurs devenus orphelins, et parenthèses vidées.
  s = s.replaceAll(RegExp(r'[-–—/,()]'), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Une offre réduite à ce qui sert au rapprochement.
class DedupCandidate {
  const DedupCandidate({
    required this.source,
    required this.title,
    this.company,
    this.location,
  });

  final String source;
  final String title;
  final String? company;
  final String? location;
}

/// Vrai si [a] et [b] sont très probablement **la même offre**, rediffusée
/// d'une source à l'autre.
///
/// Volontairement conservateur : en cas de doute, on répond `false`, quitte à
/// laisser un doublon visible. Masquer une offre réelle coûte plus cher que
/// d'en afficher une en trop.
bool isCrossSourceDuplicate(DedupCandidate a, DedupCandidate b) {
  // 1. Sources différentes. Deux annonces d'une même source sont deux offres,
  //    même quand tout se ressemble (constat : quatre « Développeur web » à
  //    Lille chez France Travail, publiées par des agences différentes).
  if (a.source == b.source) return false;

  // 2. Même titre, une fois canonicalisé (« (H/F) », accents, casse).
  final titleA = canonTitle(a.title);
  final titleB = canonTitle(b.title);
  if (titleA.isEmpty || titleA != titleB) return false;

  // 3. Même ville. Sans lieu des deux côtés, on n'a pas assez pour trancher.
  final cityA = canonCity(a.location);
  final cityB = canonCity(b.location);
  if (cityA.isEmpty || cityB.isEmpty || cityA != cityB) return false;

  // 4. Entreprises compatibles. Le cas qui motive tout ceci : l'une des deux
  //    sources anonymise l'employeur. Deux entreprises nommées et différentes
  //    signent en revanche deux offres distinctes.
  final compA = canonCompany(a.company ?? '');
  final compB = canonCompany(b.company ?? '');
  if (compA.isNotEmpty && compB.isNotEmpty && compA != compB) return false;

  return true;
}
