/// Scoring local d'une offre (0 à 100). Port fidèle de
/// `reference/offer-utils.mjs`, mêmes pondérations et mêmes termes.
///
/// Ce score est un pré-tri, rapide et gratuit : il ne consomme pas d'appel LLM.
/// Le scoring fin, lui, est le travail de l'agent (étape 4).
library;

import 'hash.dart';

/// Préférences par défaut, quand le profil de recherche ne dit rien.
class Prefs {
  const Prefs({
    this.keywords = defaultKeywords,
    this.exclusions = const [],
    this.contractTypes = defaultContracts,
    this.seniority = '',
    this.remoteTerms = defaultRemoteTerms,
    this.juniorTerms = defaultJuniorTerms,
    this.seniorTerms = defaultSeniorTerms,
  });

  final List<String> keywords;
  final List<String> exclusions;
  final List<String> contractTypes;
  final String seniority;
  final List<String> remoteTerms;
  final List<String> juniorTerms;
  final List<String> seniorTerms;

  static const defaultKeywords = [
    'ia', 'intelligence artificielle', 'ml', 'machine learning', 'data',
    'llm', 'python', 'développeur', 'developpeur', 'backend', 'api',
  ];
  static const defaultJuniorTerms = [
    'junior', 'débutant', 'debutant', 'alternance', 'apprenti', 'stage',
    'stagiaire', 'entry level',
  ];
  static const defaultSeniorTerms = [
    'senior', 'confirmé', 'confirme', 'lead', 'principal', '5 ans',
    'expérimenté', 'experimente', '10 ans',
  ];
  static const defaultRemoteTerms = [
    'télétravail', 'teletravail', 'remote', 'hybride', 'distanciel',
  ];
  static const defaultContracts = [
    'cdi', 'alternance', 'cdd', 'apprentissage', 'freelance',
  ];

  /// Construit les préférences depuis un profil de recherche stocké en base.
  /// C'est ce qui aligne le scoring sur le multi-profils, au lieu de constantes
  /// figées dans le code.
  factory Prefs.fromProfile({
    String? keywords,
    String? mustHave,
    String? exclusions,
    String? contractTypes,
    String? seniority,
  }) {
    final kw = [..._splitWords(keywords), ..._splitPhrases(mustHave)];
    final contracts = _splitPhrases(contractTypes);
    return Prefs(
      keywords: kw.isNotEmpty ? kw : defaultKeywords,
      exclusions: _splitPhrases(exclusions),
      contractTypes: contracts.isNotEmpty ? contracts : defaultContracts,
      seniority: norm(seniority),
    );
  }

  static List<String> _splitWords(String? s) =>
      norm(s).split(RegExp(r'[,;\n\s]+')).where((w) => w.isNotEmpty).toList();

  static List<String> _splitPhrases(String? s) => (s ?? '')
      .split(RegExp(r'[,;\n]+'))
      .map(norm)
      .where((p) => p.isNotEmpty)
      .toList();
}

/// L'offre telle que le scoring la voit. Volontairement minimal : le scoring ne
/// doit pas dépendre de la base.
class ScorableOffer {
  const ScorableOffer({
    required this.title,
    this.company,
    this.location,
    this.description,
    this.contractType,
    this.salary,
  });

  final String title;
  final String? company;
  final String? location;
  final String? description;
  final String? contractType;
  final String? salary;
}

/// Une offre tombe-t-elle sous une exclusion du profil ? C'est un filtre dur :
/// une offre exclue n'est pas scorée, elle est écartée.
bool matchesExclusions(ScorableOffer offer, List<String> exclusions) {
  if (exclusions.isEmpty) return false;
  final hay = norm(
    '${offer.title} ${offer.description ?? ''} '
    '${offer.contractType ?? ''} ${offer.location ?? ''}',
  );
  return exclusions.any((x) => x.isNotEmpty && hay.contains(norm(x)));
}

/// Villes frontalières tolérées malgré le pays (moins de 30 km environ de Lille
/// ou Valenciennes).
const borderAllow = [
  'mouscron', 'tournai', 'comines', 'menen', 'menin', 'mons', 'quievrain',
  'estaimpuis', 'kortrijk', 'courtrai', 'dottignies', 'herseaux',
];

final _foreignMarkers = [
  RegExp(r'\bbelgi(?:um|que|e)\b'),
  RegExp(r'brussels|bruxelles'),
  RegExp(r'flemish|vlaams|flandre|flandres'),
  RegExp(r'walloon|wallon(?:ie|ne)?'),
  RegExp(r'\bghent\b|\bgent\b|\bgand\b'),
  RegExp(
    r'anderlecht|uccle|ixelles|schaerbeek|waterloo|merelbeke|erpe|aalst|'
    r'leuven|louvain|antwerp|anvers',
  ),
  RegExp(r'\bluxembourg\b'),
  RegExp(r'\bnetherlands\b|\bpays-bas\b'),
  RegExp(r'\bdeutschland\b|\ballemagne\b|\bgermany\b'),
];

/// `true` si l'offre est clairement hors zone. Un lieu vide est gardé : les
/// sources génériques disent souvent « France » et rien de plus.
bool isOutOfZone(ScorableOffer offer) {
  final loc = norm(offer.location);
  if (loc.isEmpty) return false;
  if (borderAllow.any(loc.contains)) return false;
  return _foreignMarkers.any((re) => re.hasMatch(loc));
}

int _seniorityScore(String hay, Prefs prefs) {
  final isJunior = prefs.juniorTerms.any((t) => hay.contains(norm(t)));
  final isSenior = prefs.seniorTerms.any((t) => hay.contains(norm(t)));
  final want = prefs.seniority;

  if (RegExp(r'junior|alternance|débutant|debutant|apprenti|stage')
      .hasMatch(want)) {
    if (isJunior && !isSenior) return 20;
    return isSenior ? 0 : 10;
  }
  if (RegExp(r'senior|confirm|lead|expérim|experim').hasMatch(want)) {
    if (isSenior && !isJunior) return 20;
    return isJunior ? 5 : 10;
  }
  // Séniorité non précisée : on ne pénalise vraiment que le franchement senior.
  return isSenior && !isJunior ? 5 : 12;
}

/// Score 0 à 100. Pondération, dont la somme fait 100 :
/// mots-clés et must_have 40, séniorité 20, télétravail 15, contrat 15,
/// salaire renseigné 10.
int scoreOffer(ScorableOffer offer, [Prefs prefs = const Prefs()]) {
  final hay = norm(
    '${offer.title} ${offer.description ?? ''} ${offer.contractType ?? ''}',
  );
  final loc = norm(offer.location);
  var score = 0;

  final hits = prefs.keywords.where((k) => hay.contains(norm(k))).length;
  score += (hits * 10).clamp(0, 40);

  score += _seniorityScore(hay, prefs);

  if (prefs.remoteTerms.any((t) => hay.contains(norm(t)) || loc.contains(norm(t)))) {
    score += 15;
  }

  final contractHay = norm(offer.contractType);
  if (prefs.contractTypes
      .any((c) => hay.contains(norm(c)) || contractHay.contains(norm(c)))) {
    score += 15;
  }

  if (norm(offer.salary).isNotEmpty) score += 10;

  return score.clamp(0, 100);
}

/// Résultat de l'annotation : le score et le verdict d'exclusion.
///
/// La clé de déduplication n'est plus portée ici : le dépôt la calcule via
/// `dedupHash` (dédup sur l'URL quand elle existe, repli sur le hash
/// titre+entreprise sinon). Voir `hash.dart`.
class Annotated {
  const Annotated({required this.score, required this.excluded});

  final int score;

  /// `true` si l'offre tombe sous une exclusion du profil : elle doit être
  /// écartée, pas simplement mal notée.
  final bool excluded;
}

Annotated annotate(ScorableOffer offer, [Prefs prefs = const Prefs()]) {
  return Annotated(
    score: scoreOffer(offer, prefs),
    excluded: matchesExclusions(offer, prefs.exclusions),
  );
}
