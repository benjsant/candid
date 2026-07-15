/// Analyse du texte reçu par la cible de partage Android.
///
/// Ce que partagent les applications d'emploi est peu structuré, et varie d'une
/// application à l'autre. On extrait donc au mieux, et surtout **on n'invente
/// rien en silence** : le résultat est présenté à l'utilisateur, qui corrige
/// avant enregistrement. C'est la même règle que pour l'agent.
library;

/// Ce qu'on a pu tirer d'un partage. Chaque champ peut être nul : c'est un
/// résultat honnête, pas une devinette.
class SharedOffer {
  const SharedOffer({
    this.title,
    this.company,
    this.url,
    required this.rawText,
    required this.source,
  });

  final String? title;
  final String? company;
  final String? url;

  /// Le texte partagé, intégral. C'est lui qu'on donne à l'agent : il en sait
  /// toujours plus que nos heuristiques.
  final String rawText;

  /// D'où vient l'offre, déduit de l'URL. `shared` si on ne sait pas.
  final String source;

  /// Vrai si l'essentiel manque et qu'il faudra que l'utilisateur complète.
  bool get needsReview => title == null || company == null;
}

final _urlRe = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

/// Hôte connu (clé) et nom de source stocké en base (valeur).
const _knownSources = {
  'linkedin.': 'linkedin',
  'indeed.': 'indeed',
  'welcometothejungle.': 'wttj',
  'hellowork.': 'hellowork',
  'apec.': 'apec',
  'francetravail.': 'france_travail',
  'pole-emploi.': 'france_travail',
  'glassdoor.': 'glassdoor',
};

/// Motifs d'annonce les plus courants en français, du plus explicite au moins
/// sûr. Le groupe 1 est le titre, le groupe 2 l'entreprise (ou l'inverse pour
/// « recrute »).
final _titleCompanyRe = RegExp(
  r'^(.{3,120}?)\s+(?:chez|at|– chez)\s+(.{2,80}?)\s*$',
  caseSensitive: false,
  multiLine: true,
);
final _companyRecruteRe = RegExp(
  r'^(.{2,80}?)\s+recrute\s*:?\s*(?:un|une|un\(e\))?\s*(.{3,120}?)\s*$',
  caseSensitive: false,
  multiLine: true,
);

/// Analyse le texte brut d'un partage.
SharedOffer parseSharedText(String raw) {
  final text = raw.trim();
  final url = _urlRe.firstMatch(text)?.group(0);

  var source = 'shared';
  if (url != null) {
    final lower = url.toLowerCase();
    for (final entry in _knownSources.entries) {
      if (lower.contains(entry.key)) {
        source = entry.value;
        break;
      }
    }
  }

  // On retire l'URL avant d'analyser : elle pollue la détection du titre.
  final withoutUrl = text.replaceAll(_urlRe, ' ');
  final lines = withoutUrl
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  String? title;
  String? company;

  for (final line in lines) {
    final chez = _titleCompanyRe.firstMatch(line);
    if (chez != null) {
      title = _clean(chez.group(1));
      company = _clean(chez.group(2));
      break;
    }
    final recrute = _companyRecruteRe.firstMatch(line);
    if (recrute != null) {
      company = _clean(recrute.group(1));
      title = _clean(recrute.group(2));
      break;
    }
  }

  // Aucun motif reconnu : la première ligne est le meilleur candidat pour le
  // titre. L'entreprise reste nulle, et l'interface demandera à l'utilisateur.
  title ??= lines.isNotEmpty ? _clean(lines.first) : null;

  return SharedOffer(
    title: title,
    company: company,
    url: url,
    rawText: text,
    source: source,
  );
}

String? _clean(String? s) {
  if (s == null) return null;
  final cleaned = s
      .replaceAll(RegExp(r'^[\s\-–•:|]+'), '')
      .replaceAll(RegExp(r'[\s\-–•:|]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return cleaned.isEmpty ? null : cleaned;
}
