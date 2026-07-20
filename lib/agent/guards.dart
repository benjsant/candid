/// Garde-fous déterministes de l'agent. Port fidèle de `reference/graph.py`.
///
/// NON NÉGOCIABLES (cf. CLAUDE.md, philosophie du projet) : ils protègent le
/// candidat contre l'invention et les tics d'écriture IA. Ils tournent sans LLM,
/// sont purs, et sont testés. Ne pas les affaiblir.
library;

import 'models.dart';

final _dashRe = RegExp(r'\s*[—–]\s*');

/// Anti tiret cadratin (—/–) : virgule à la place. Ne touche pas au « - ».
String noDash(String? text) => (text ?? '').replaceAll(_dashRe, ', ');

/// Motifs rejetés dans l'accroche (§5) : formules creuses, superlatifs gratuits,
/// ouverture banale, exagération géographique. Le tiret cadratin et la longueur
/// sont gérés à part dans [checkAccroche].
final _accrocheCliches = <(RegExp, String)>[
  (RegExp(r'dynamique et motiv'), 'formule creuse « dynamique et motivé »'),
  (RegExp(r'depuis (mon plus jeune âge|toujours)'), 'cliché « depuis toujours »'),
  (RegExp(r'passionn[ée]'), 'cliché « passionné »'),
  (RegExp(r'candidat id[ée]al'), 'formule « candidat idéal »'),
  (RegExp(r"n'h[ée]sitez pas"), 'formule « n\'hésitez pas »'),
  (RegExp(r'je vous [ée]cris pour le poste'),
      'ouverture banale « je vous écris pour le poste »'),
  (RegExp(r'\b(leader|n°\s?1|num[ée]ro 1|meilleur[e]?)\b'),
      'superlatif non vérifié (leader/n°1/meilleur)'),
  (RegExp(r'à quelques minutes'), 'exagération de la proximité géographique'),
];

/// Garde-fous déterministes de l'accroche (§5). Renvoie la liste des problèmes
/// (vide = OK). C'est le « juge » : s'il trouve un défaut, l'accroche est
/// régénérée avec ces défauts en feedback.
List<String> checkAccroche(String? text) {
  final t = (text ?? '').trim();
  if (t.isEmpty) return ['accroche vide'];
  final low = t.toLowerCase();
  final problems = <String>[
    for (final (pat, label) in _accrocheCliches)
      if (pat.hasMatch(low)) label,
  ];
  if (t.contains('—') || t.contains('–')) {
    problems.add('tiret cadratin (marqueur IA)');
  }
  final nSent =
      t.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
  if (nSent > 4) problems.add('trop long ($nSent phrases, vise 2-3)');
  if (t.length > 700) problems.add('accroche trop longue (> 700 caractères)');
  return problems;
}

/// Garde-fous déterministes sur le masquage du CV (le LLM a tendance à
/// sur-masquer) :
///  - jamais masquer ce qui est mis en avant (contradiction highlight/hidden) ;
///  - au plus un tiers des compétences masquées ;
///  - au moins 3 projets visibles (si le profil en compte autant).
///
/// [cvIndexSkillsCount] et [cvIndexProjectsCount] viennent de `cv-index.json`.
/// À 0 (index illisible), seule la règle de contradiction s'applique : tolérant,
/// comme l'original.
PersonnalisationCv sanitizePersonnalisation(
  PersonnalisationCv pc, {
  int cvIndexSkillsCount = 0,
  int cvIndexProjectsCount = 0,
}) {
  // 1. Retire des masqués tout ce qui est aussi mis en avant.
  final hiSkills = pc.highlightSkills.toSet();
  final hiProjects = pc.highlightProjects.toSet();
  var hiddenSkills =
      pc.hiddenSkills.where((x) => !hiSkills.contains(x)).toList();
  var hiddenProjects =
      pc.hiddenProjects.where((x) => !hiProjects.contains(x)).toList();

  // 2. Au plus un tiers des compétences masquées.
  if (cvIndexSkillsCount > 0) {
    hiddenSkills = hiddenSkills.take(cvIndexSkillsCount ~/ 3).toList();
  }
  // 3. Au moins 3 projets visibles (si le profil en compte au moins autant).
  if (cvIndexProjectsCount > 0) {
    final maxHidden =
        (cvIndexProjectsCount - (cvIndexProjectsCount < 3 ? cvIndexProjectsCount : 3))
            .clamp(0, cvIndexProjectsCount);
    hiddenProjects = hiddenProjects.take(maxHidden).toList();
  }

  return pc.copyWith(hiddenSkills: hiddenSkills, hiddenProjects: hiddenProjects);
}
