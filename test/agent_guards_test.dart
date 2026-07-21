/// Les garde-fous de l'agent sont NON NÉGOCIABLES : ces tests fixent leur
/// comportement, repris de l'intention de `reference/graph.py`. Une accroche qui
/// invente ou tombe dans un cliché doit être rejetée ; une personnalisation qui
/// masque trop doit être bornée.
library;

import 'package:candid/agent/guards.dart';
import 'package:candid/agent/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('noDash', () {
    test('remplace les tirets cadratin et demi-cadratin par une virgule', () {
      expect(noDash('bout — en — bout'), 'bout, en, bout');
      expect(noDash('a – b'), 'a, b');
    });
    test('ne touche pas au trait d\'union simple', () {
      expect(noDash('bout-en-bout'), 'bout-en-bout');
    });
    test('tolère le null', () => expect(noDash(null), ''));
  });

  group('checkAccroche', () {
    test('une accroche vide est rejetée', () {
      expect(checkAccroche(''), ['accroche vide']);
      expect(checkAccroche(null), ['accroche vide']);
    });

    test('une accroche spécifique et sobre passe', () {
      const ok =
          'Votre travail sur les pipelines de données ouverts recoupe mes '
          'projets ETL. Contribuer à vos outils open source m\'intéresse.';
      expect(checkAccroche(ok), isEmpty);
    });

    test('les clichés sont détectés', () {
      expect(checkAccroche('Je suis dynamique et motivé.'),
          contains('formule creuse « dynamique et motivé »'));
      expect(checkAccroche('Passionné depuis toujours par l\'IA.'),
          isNotEmpty);
      expect(checkAccroche('Vous êtes le leader du marché.'),
          contains('superlatif non vérifié (leader/n°1/meilleur)'));
    });

    test('le tiret cadratin est un défaut (marqueur IA)', () {
      expect(checkAccroche('Un fait — vérifiable.'),
          contains('tiret cadratin (marqueur IA)'));
    });

    test('une accroche trop longue (> 4 phrases) est rejetée', () {
      const long = 'Un. Deux. Trois. Quatre. Cinq.';
      expect(checkAccroche(long).any((p) => p.contains('trop long')), isTrue);
    });
  });

  group('sanitizePersonnalisation', () {
    test('ne masque jamais ce qui est mis en avant', () {
      const pc = PersonnalisationCv(
        highlightSkills: ['Python'],
        hiddenSkills: ['Python', 'PHP'],
      );
      final s = sanitizePersonnalisation(pc, cvIndexSkillsCount: 30);
      expect(s.hiddenSkills, isNot(contains('Python')));
      expect(s.hiddenSkills, contains('PHP'));
    });

    test('borne le masquage à un tiers des compétences', () {
      // 6 masquées demandées, index de 9 compétences -> au plus 3.
      const pc = PersonnalisationCv(
        hiddenSkills: ['a', 'b', 'c', 'd', 'e', 'f'],
      );
      final s = sanitizePersonnalisation(pc, cvIndexSkillsCount: 9);
      expect(s.hiddenSkills, hasLength(3));
    });

    test('garde au moins 3 projets visibles', () {
      // 4 projets au total, on ne peut en masquer qu'un (4 - 3).
      const pc = PersonnalisationCv(
        hiddenProjects: ['p1', 'p2', 'p3', 'p4'],
      );
      final s = sanitizePersonnalisation(pc, cvIndexProjectsCount: 4);
      expect(s.hiddenProjects, hasLength(1));
    });

    test('un projet cité dans l\'accroche n\'est jamais masqué', () {
      // Cas réel (Doctolib, 21/07/2026) : l'accroche citait InfiniDex alors que
      // la personnalisation le masquait du CV. Le recruteur suivait une piste
      // absente du document joint.
      const pc = PersonnalisationCv(
        hiddenProjects: ['InfiniDex - Pokédex augmenté par IA', 'Audiomancy'],
      );
      final s = sanitizePersonnalisation(
        pc,
        cvIndexProjectsCount: 4,
        accroche: 'des projets concrets comme Job Hunter ou InfiniDex.',
      );
      expect(s.hiddenProjects, ['Audiomancy']);
    });

    test('index illisible (0) : seule la contradiction s\'applique', () {
      const pc = PersonnalisationCv(
        highlightSkills: ['Python'],
        hiddenSkills: ['Python', 'PHP', 'Java'],
      );
      final s = sanitizePersonnalisation(pc);
      expect(s.hiddenSkills, ['PHP', 'Java']);
    });
  });

  group('AgentOutput.coerce', () {
    test('un JSON vide donne les défauts prudents', () {
      final o = AgentOutput.coerce(<String, dynamic>{});
      expect(o.recommandation, 'ne_pas_postuler');
      expect(o.langue, 'fr');
      expect(o.lettre.template, 'ia-junior');
    });

    test('une entrée non-map retombe sur le défaut', () {
      expect(AgentOutput.coerce('nope').score, 0);
    });

    test('un template inconnu est ramené à ia-junior', () {
      final o = AgentOutput.coerce({
        'lettre': {'template': 'inexistant', 'accroche': 'x'},
      });
      expect(o.lettre.template, 'ia-junior');
      expect(o.lettre.accroche, 'x');
    });

    test('une recommandation hors liste est bornée', () {
      final o = AgentOutput.coerce({'recommandation': 'peut-etre'});
      expect(o.recommandation, 'ne_pas_postuler');
    });

    test('les champs valides sont lus', () {
      final o = AgentOutput.coerce({
        'score': 82,
        'recommandation': 'postuler',
        'matching_skills': ['Python', 'FastAPI'],
        'lettre': {'template': 'backend', 'accroche': 'Bonjour.'},
      });
      expect(o.score, 82);
      expect(o.recommandation, 'postuler');
      expect(o.matchingSkills, ['Python', 'FastAPI']);
      expect(o.lettre.template, 'backend');
    });
  });
}
