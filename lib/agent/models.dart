/// Modèles d'entrée/sortie de l'agent. Port de `reference/schema.py`.
///
/// Le contrat de sortie (`AgentOutput`) est IDENTIQUE au §6 du prompt système :
/// c'est ce que produisait DeepSeek dans le pipeline Docker. On le reprend tel
/// quel pour que le comportement (scoring, personnalisation, lettre) soit le
/// même sur mobile. `coerce` est tolérant, comme le parser d'origine.
library;

/// Les 7 templates de lettres. Doit rester aligné avec `assets/letters/` et
/// l'enum `LetterTemplate` de `core/assets.dart`.
const kTemplates = [
  'ia-junior',
  'backend',
  'frontend',
  'alternance',
  'candidature-spontanee',
  'employe-numerique',
  'php-symfony',
];

const kRecommandations = [
  'postuler',
  'postuler_si_peu_options',
  'ne_pas_postuler',
];

/// L'offre telle que l'agent la reçoit.
class AgentOffer {
  const AgentOffer({
    this.title = '',
    this.company = '',
    this.location = '',
    this.description = '',
    this.companyInfo = '',
    this.url = '',
    this.spontaneous = false,
  });

  final String title;
  final String company;
  final String location;
  final String description;
  final String companyInfo;
  final String url;
  final bool spontaneous;
}

/// La lettre : template choisi + accroche (seule zone rédigée par le LLM).
class Lettre {
  const Lettre({this.template = 'ia-junior', this.accroche = ''});

  final String template;
  final String accroche;

  factory Lettre.fromJson(Map<String, dynamic> j) => Lettre(
        template:
            kTemplates.contains(j['template']) ? j['template'] as String : 'ia-junior',
        accroche: (j['accroche'] ?? '').toString(),
      );

  Lettre copyWith({String? template, String? accroche}) => Lettre(
        template: template ?? this.template,
        accroche: accroche ?? this.accroche,
      );

  Map<String, dynamic> toJson() => {'template': template, 'accroche': accroche};
}

/// La personnalisation du CV : mise en avant et masquage, jamais d'invention.
/// L'agent ne choisit QUE parmi les valeurs réelles du CV (cv-index.json).
class PersonnalisationCv {
  const PersonnalisationCv({
    this.cvTitle = '',
    this.summary = '',
    this.highlightSkills = const [],
    this.highlightProjects = const [],
    this.highlightExperiences = const [],
    this.hiddenSections = const [],
    this.hiddenSkills = const [],
    this.hiddenProjects = const [],
  });

  final String cvTitle;
  final String summary;
  final List<String> highlightSkills;
  final List<String> highlightProjects;
  final List<String> highlightExperiences;
  final List<String> hiddenSections;
  final List<String> hiddenSkills;
  final List<String> hiddenProjects;

  static List<String> _strList(Object? v) =>
      (v is List) ? v.whereType<String>().toList() : const [];

  factory PersonnalisationCv.fromJson(Map<String, dynamic> j) => PersonnalisationCv(
        cvTitle: (j['cv_title'] ?? '').toString(),
        summary: (j['summary'] ?? '').toString(),
        highlightSkills: _strList(j['highlight_skills']),
        highlightProjects: _strList(j['highlight_projects']),
        highlightExperiences: _strList(j['highlight_experiences']),
        hiddenSections: _strList(j['hidden_sections']),
        hiddenSkills: _strList(j['hidden_skills']),
        hiddenProjects: _strList(j['hidden_projects']),
      );

  PersonnalisationCv copyWith({
    List<String>? hiddenSkills,
    List<String>? hiddenProjects,
  }) =>
      PersonnalisationCv(
        cvTitle: cvTitle,
        summary: summary,
        highlightSkills: highlightSkills,
        highlightProjects: highlightProjects,
        highlightExperiences: highlightExperiences,
        hiddenSections: hiddenSections,
        hiddenSkills: hiddenSkills ?? this.hiddenSkills,
        hiddenProjects: hiddenProjects ?? this.hiddenProjects,
      );

  Map<String, dynamic> toJson() => {
        'cv_title': cvTitle,
        'summary': summary,
        'highlight_skills': highlightSkills,
        'highlight_projects': highlightProjects,
        'highlight_experiences': highlightExperiences,
        'hidden_sections': hiddenSections,
        'hidden_skills': hiddenSkills,
        'hidden_projects': hiddenProjects,
      };
}

class CompetenceAAmeliorer {
  const CompetenceAAmeliorer({this.competence = '', this.conseil = ''});
  final String competence;
  final String conseil;

  factory CompetenceAAmeliorer.fromJson(Map<String, dynamic> j) =>
      CompetenceAAmeliorer(
        competence: (j['competence'] ?? '').toString(),
        conseil: (j['conseil'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'competence': competence, 'conseil': conseil};
}

/// La sortie complète de l'agent (§6). Défauts prudents : si le LLM renvoie
/// n'importe quoi, on retombe sur « ne pas postuler » plutôt que d'inventer.
class AgentOutput {
  const AgentOutput({
    this.score = 0,
    this.skillsScore = 0,
    this.experienceScore = 0,
    this.locationScore = 0,
    this.salaryScore = 0,
    this.recommandation = 'ne_pas_postuler',
    this.justificationScore = '',
    this.matchingSkills = const [],
    this.missingSkills = const [],
    this.competencesAAmeliorer = const [],
    this.conseils = '',
    this.lettre = const Lettre(),
    this.adaptationCv = '',
    this.personnalisationCv = const PersonnalisationCv(),
    this.objetEmail = '',
    this.langue = 'fr',
  });

  final int score;
  final int skillsScore;
  final int experienceScore;
  final int locationScore;
  final int salaryScore;
  final String recommandation;
  final String justificationScore;
  final List<String> matchingSkills;
  final List<String> missingSkills;
  final List<CompetenceAAmeliorer> competencesAAmeliorer;
  final String conseils;
  final Lettre lettre;
  final String adaptationCv;
  final PersonnalisationCv personnalisationCv;
  final String objetEmail;
  final String langue;

  AgentOutput copyWith({
    String? conseils,
    Lettre? lettre,
    PersonnalisationCv? personnalisationCv,
  }) =>
      AgentOutput(
        score: score,
        skillsScore: skillsScore,
        experienceScore: experienceScore,
        locationScore: locationScore,
        salaryScore: salaryScore,
        recommandation: recommandation,
        justificationScore: justificationScore,
        matchingSkills: matchingSkills,
        missingSkills: missingSkills,
        competencesAAmeliorer: competencesAAmeliorer,
        conseils: conseils ?? this.conseils,
        lettre: lettre ?? this.lettre,
        adaptationCv: adaptationCv,
        personnalisationCv: personnalisationCv ?? this.personnalisationCv,
        objetEmail: objetEmail,
        langue: langue,
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'skills_score': skillsScore,
        'experience_score': experienceScore,
        'location_score': locationScore,
        'salary_score': salaryScore,
        'recommandation': recommandation,
        'justification_score': justificationScore,
        'matching_skills': matchingSkills,
        'missing_skills': missingSkills,
        'competences_a_ameliorer':
            competencesAAmeliorer.map((c) => c.toJson()).toList(),
        'conseils': conseils,
        'lettre': lettre.toJson(),
        'adaptation_cv': adaptationCv,
        'personnalisation_cv': personnalisationCv.toJson(),
        'objet_email': objetEmail,
        'langue': langue,
      };

  static int _int(Object? v) {
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static List<String> _strList(Object? v) =>
      (v is List) ? v.whereType<String>().toList() : const [];

  /// Parser tolérant (comme `coerce_output`) : chaque champ retombe sur son
  /// défaut si absent ou mal typé. `recommandation` et `langue` sont bornés.
  factory AgentOutput.coerce(Object? data) {
    if (data is! Map) return const AgentOutput();
    final j = data.cast<String, dynamic>();

    final reco = j['recommandation'];
    final langue = j['langue'];
    final lettre = j['lettre'] is Map
        ? Lettre.fromJson((j['lettre'] as Map).cast<String, dynamic>())
        : const Lettre();
    final perso = j['personnalisation_cv'] is Map
        ? PersonnalisationCv.fromJson(
            (j['personnalisation_cv'] as Map).cast<String, dynamic>())
        : const PersonnalisationCv();
    final ameliorer = (j['competences_a_ameliorer'] is List)
        ? (j['competences_a_ameliorer'] as List)
            .whereType<Map>()
            .map((m) => CompetenceAAmeliorer.fromJson(m.cast<String, dynamic>()))
            .toList()
        : const <CompetenceAAmeliorer>[];

    return AgentOutput(
      score: _int(j['score']),
      skillsScore: _int(j['skills_score']),
      experienceScore: _int(j['experience_score']),
      locationScore: _int(j['location_score']),
      salaryScore: _int(j['salary_score']),
      recommandation:
          kRecommandations.contains(reco) ? reco as String : 'ne_pas_postuler',
      justificationScore: (j['justification_score'] ?? '').toString(),
      matchingSkills: _strList(j['matching_skills']),
      missingSkills: _strList(j['missing_skills']),
      competencesAAmeliorer: ameliorer,
      conseils: (j['conseils'] ?? '').toString(),
      lettre: lettre,
      adaptationCv: (j['adaptation_cv'] ?? '').toString(),
      personnalisationCv: perso,
      objetEmail: (j['objet_email'] ?? '').toString(),
      langue: (langue == 'fr' || langue == 'en') ? langue as String : 'fr',
    );
  }
}
