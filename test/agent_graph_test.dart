/// Le graphe enchaîne analyze → research → accroche → judge → validate avec un
/// faux fournisseur LLM (aucun réseau). On vérifie l'orchestration : la boucle
/// d'auto-correction régénère une accroche à cliché, le grounding est injecté,
/// et les garde-fous finaux s'appliquent.
library;

import 'package:candid/agent/graph.dart';
import 'package:candid/agent/llm.dart';
import 'package:candid/agent/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux LLM scénarisé : renvoie des réponses préprogrammées, dans l'ordre des
/// appels, et enregistre les messages reçus.
class _ScriptedLlm implements LlmGateway {
  _ScriptedLlm(this.responses);
  final List<Map<String, dynamic>> responses;
  final List<String> userMessages = [];
  int _i = 0;

  @override
  Future<Map<String, dynamic>> completeJson({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.2,
  }) async {
    userMessages.add(userMessage);
    final r = responses[_i.clamp(0, responses.length - 1)];
    _i++;
    return r;
  }
}

const _offer = AgentOffer(
  title: 'Développeur IA Junior',
  company: 'ACME',
  description: 'Python, LLM, FastAPI.',
);

const _cvIndex =
    '{"skills":["Python","FastAPI","PHP"],"projects":[{"id":"a"},{"id":"b"}]}';

Future<String> _noGrounding(String company) async => '';

void main() {
  test('un passage nominal produit un dossier complet', () async {
    final llm = _ScriptedLlm([
      // analyze
      {
        'score': 78,
        'recommandation': 'postuler',
        'matching_skills': ['Python'],
        'personnalisation_cv': {'cv_title': 'Dev IA'},
      },
      // accroche (sobre, passe le juge du premier coup)
      {
        'lettre': {
          'template': 'ia-junior',
          'accroche':
              'Vos travaux sur les agents LLM recoupent mes projets déployés.',
        },
      },
    ]);
    final run = await runAgent(
      offer: _offer,
      systemPrompt: 'SYS',
      cvIndex: _cvIndex,
      llm: llm,
      research: _noGrounding,
    );
    expect(run.output.score, 78);
    expect(run.output.recommandation, 'postuler');
    expect(run.output.lettre.accroche, contains('agents LLM'));
    expect(run.attempts, 1);
    expect(run.error, isNull);
  });

  test('une accroche à cliché est régénérée (boucle d\'auto-correction)',
      () async {
    final llm = _ScriptedLlm([
      {'score': 50}, // analyze
      // 1re accroche : cliché rejeté par le juge
      {
        'lettre': {'template': 'backend', 'accroche': 'Je suis passionné.'},
      },
      // 2e accroche : propre
      {
        'lettre': {
          'template': 'backend',
          'accroche': 'Votre stack Python m\'a convaincu de vous écrire.',
        },
      },
    ]);
    final run = await runAgent(
      offer: _offer,
      systemPrompt: 'SYS',
      cvIndex: _cvIndex,
      llm: llm,
      research: _noGrounding,
    );
    expect(run.attempts, 2);
    expect(run.output.lettre.accroche, isNot(contains('passionné')));
  });

  test('le grounding INSEE est injecté dans le message d\'accroche', () async {
    final llm = _ScriptedLlm([
      {'score': 60},
      {
        'lettre': {'template': 'ia-junior', 'accroche': 'Une accroche sobre ici.'},
      },
    ]);
    await runAgent(
      offer: _offer,
      systemPrompt: 'SYS',
      cvIndex: _cvIndex,
      llm: llm,
      research: (c) async => 'Faits officiels : Nom : ACME ; Siège : Lille.',
    );
    // Le 2e appel (accroche) doit contenir les faits officiels.
    expect(llm.userMessages[1], contains('FAITS OFFICIELS'));
    expect(llm.userMessages[1], contains('ACME'));
  });

  test('l\'accroche finale est nettoyée du tiret cadratin (garde-fou)', () async {
    final llm = _ScriptedLlm([
      {'score': 40},
      // Le juge rejette le tiret cadratin ; après 3 tentatives identiques, on
      // valide quand même, mais validate retire le tiret.
      {
        'lettre': {'template': 'ia-junior', 'accroche': 'Un fait — vérifiable.'},
      },
    ]);
    final run = await runAgent(
      offer: _offer,
      systemPrompt: 'SYS',
      cvIndex: _cvIndex,
      llm: llm,
      research: _noGrounding,
    );
    expect(run.output.lettre.accroche, isNot(contains('—')));
    expect(run.output.lettre.accroche, contains('Un fait, vérifiable.'));
    expect(run.attempts, maxAccrocheAttempts); // a épuisé les tentatives
  });

  test('une erreur LLM n\'empêche pas un dossier (défauts prudents)', () async {
    final llm = _ThrowingLlm();
    final run = await runAgent(
      offer: _offer,
      systemPrompt: 'SYS',
      cvIndex: _cvIndex,
      llm: llm,
      research: _noGrounding,
    );
    expect(run.error, isNotNull);
    expect(run.output.recommandation, 'ne_pas_postuler');
  });
}

class _ThrowingLlm implements LlmGateway {
  @override
  Future<Map<String, dynamic>> completeJson({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.2,
  }) async =>
      throw LlmException('réseau coupé');
}
