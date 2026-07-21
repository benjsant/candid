/// Le graphe de l'agent. Port de `reference/graph.py` en une fonction `async`.
///
///     analyze → research → accroche → judge → (retry ↺ | validate)
///
/// - analyze  : LLM (temp 0.2) — le jugement : score, sous-scores, matching,
///              personnalisation_cv, conseils, objet (tout le §6 sauf la lettre).
/// - research : grounding INSEE (faits officiels), sans LLM.
/// - accroche : LLM (temp 0.7) — le créatif : template + accroche, ancrée sur
///              les faits du registre.
/// - judge    : garde-fous déterministes (`checkAccroche`), sans LLM.
/// - validate : fusion déterministe + garde-fous anti-invention, sans LLM.
///
/// La boucle accroche→judge se répète (max 3) tant que le juge trouve des
/// défauts, en réinjectant ces défauts comme feedback. Aucun envoi : l'agent
/// produit un dossier, l'utilisateur relit puis envoie.
library;

import 'dart:convert';

import 'guards.dart';
import 'llm.dart';
import 'models.dart';
import 'research.dart';

const _analyzeTask =
    'TÂCHE — ÉVALUATION. Réponds en JSON UNIQUEMENT avec : score, skills_score, '
    'experience_score, location_score, salary_score, recommandation, '
    'justification_score, matching_skills, missing_skills, competences_a_ameliorer, '
    'conseils, adaptation_cv, personnalisation_cv, objet_email, langue (cf. §6). '
    'N\'inclus PAS de champ "lettre" ici.';

const _accrocheTask =
    'TÂCHE — ACCROCHE. Choisis le template le plus adapté et rédige UNIQUEMENT '
    'l\'accroche (2-3 phrases, cf. §5/§6 ; le corps de la lettre est figé hors de '
    'toi). Réponds en JSON UNIQUEMENT : '
    '{"lettre": {"template": "<id>", "accroche": "<texte>"}}.';

const maxAccrocheAttempts = 3;

/// Résultat d'un passage de l'agent, avec de quoi tracer ce qui s'est passé.
class AgentRun {
  const AgentRun({
    required this.output,
    required this.grounding,
    required this.attempts,
    this.error,
  });

  final AgentOutput output;

  /// Le texte de grounding INSEE réellement utilisé ('' si rien).
  final String grounding;

  /// Nombre de tentatives d'accroche (1 à [maxAccrocheAttempts]).
  final int attempts;

  /// Message d'erreur d'un appel LLM, le cas échéant (le run continue quand
  /// même avec des défauts prudents).
  final String? error;
}

/// Construit le message utilisateur (offre + valeurs CV disponibles), commun aux
/// nœuds LLM. Port de `build_user_message`.
String buildUserMessage(AgentOffer offer, String cvIndex) {
  var desc = offer.description;
  if (offer.spontaneous) {
    desc = 'CANDIDATURE SPONTANÉE — aucune offre publiée. Choisis IMPÉRATIVEMENT '
        'le template "candidature-spontanee". Infos connues: $desc';
  }
  return 'Offre: ${offer.title} chez ${offer.company}\n\n'
      'Description:\n$desc\n\n'
      'Infos entreprise:\n${offer.companyInfo.isEmpty ? 'Non fournies' : offer.companyInfo}\n\n'
      'VALEURS DISPONIBLES POUR personnalisation_cv (choisis EXCLUSIVEMENT parmi '
      'elles, ids/noms exacts):\n$cvIndex';
}

/// Exécute l'agent sur une offre. [research] est injectable pour les tests ; par
/// défaut, le grounding INSEE réel.
Future<AgentRun> runAgent({
  required AgentOffer offer,
  required String systemPrompt,
  required String cvIndex,
  required LlmGateway llm,
  Future<String> Function(String company)? research,
}) async {
  String? error;

  // 1. analyze (jugement, température basse).
  Map<String, dynamic> analysis = {};
  try {
    analysis = await llm.completeJson(
      systemPrompt: systemPrompt,
      userMessage: '${buildUserMessage(offer, cvIndex)}\n\n$_analyzeTask',
      temperature: 0.2,
    );
  } catch (e) {
    error = e.toString();
  }

  // 2. research (grounding INSEE, sans LLM ; tolérant).
  final grounding = offer.company.trim().isEmpty
      ? ''
      : await (research ?? companyRegistryGrounding)(offer.company);

  // 3-4. accroche + judge, avec boucle d'auto-correction bornée.
  Lettre lettre = const Lettre();
  var attempts = 0;
  var problems = <String>[];
  while (attempts < maxAccrocheAttempts) {
    try {
      final data = await llm.completeJson(
        systemPrompt: systemPrompt,
        userMessage: _accrocheMessage(offer, cvIndex, grounding, problems),
        temperature: 0.7,
      );
      lettre = _parseLettre(data);
    } catch (e) {
      error ??= e.toString();
    }
    attempts++;
    problems = checkAccroche(lettre.accroche);
    if (problems.isEmpty) break;
  }

  // 5. validate (fusion déterministe + garde-fous).
  final output = _validate(analysis, lettre, cvIndex);
  return AgentRun(
      output: output, grounding: grounding, attempts: attempts, error: error);
}

String _accrocheMessage(
    AgentOffer offer, String cvIndex, String grounding, List<String> problems) {
  final official = grounding.isEmpty
      ? ''
      : '\n\nFAITS OFFICIELS sur l\'entreprise (registre INSEE — AUTORITATIFS ; '
          'ne les contredis pas, appuie l\'accroche dessus) :\n$grounding\n';
  final feedback = problems.isEmpty
      ? ''
      : '\n\n⚠️ Ta tentative précédente a été REJETÉE pour : '
          '${problems.join(' ; ')}. Réécris une accroche concise (2-3 phrases), '
          'spécifique, sans ces défauts.\n';
  return '${buildUserMessage(offer, cvIndex)}$official$feedback\n\n$_accrocheTask';
}

/// Extrait la lettre de la réponse, tolérant aux formes {lettre:{...}} ou plate.
Lettre _parseLettre(Map<String, dynamic> data) {
  if (data['lettre'] is Map) {
    return Lettre.fromJson((data['lettre'] as Map).cast<String, dynamic>());
  }
  if (data.containsKey('template') || data.containsKey('accroche')) {
    return Lettre.fromJson(data);
  }
  return const Lettre();
}

/// Fusion déterministe finale + garde-fous. Port de `validate_node`.
AgentOutput _validate(
    Map<String, dynamic> analysis, Lettre lettre, String cvIndex) {
  final merged = AgentOutput.coerce(analysis);

  // Accroche : anti-dash ; template borné à la liste connue (coerce le fait).
  final cleanLettre = lettre.copyWith(accroche: noDash(lettre.accroche));

  // Comptes du cv-index pour borner le masquage.
  var skillsCount = 0;
  var projectsCount = 0;
  try {
    final idx = jsonDecode(cvIndex);
    if (idx is Map) {
      if (idx['skills'] is List) skillsCount = (idx['skills'] as List).length;
      if (idx['projects'] is List) {
        projectsCount = (idx['projects'] as List).length;
      }
    }
  } catch (_) {
    // index illisible : sanitize applique seulement la règle de contradiction.
  }

  return merged.copyWith(
    conseils: noDash(merged.conseils),
    lettre: cleanLettre,
    personnalisationCv: sanitizePersonnalisation(
      merged.personnalisationCv,
      cvIndexSkillsCount: skillsCount,
      cvIndexProjectsCount: projectsCount,
      accroche: cleanLettre.accroche,
    ),
  );
}
