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

    test('le nom « passion » est un cliché autant que l\'adjectif', () {
      // Constaté en production le 23/07/2026 : « fait écho à ma passion pour
      // les pipelines » passait le juge, alors que « je suis passionné » était
      // rejeté. Le motif ne couvrait que l'adjectif.
      expect(checkAccroche('Votre projet fait écho à ma passion pour la data.'),
          isNotEmpty);
      expect(checkAccroche('Une passion pour les pipelines de données.'),
          isNotEmpty);
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
      expect(checkAccroche('Un fait \u2014 vérifiable.'),
          contains('tiret cadratin (marqueur IA)'));
    });

    test('une plage de nombres ne fait pas rejeter l\u2019accroche', () {
      // Le juge doit appliquer la même règle que noDash, sinon il rejette une
      // accroche que le nettoyage laisserait pourtant intacte : la boucle de
      // régénération tournerait pour rien, trois fois.
      const ok = 'Votre équipe a doublé ses effectifs entre 2016\u20132019. '
          'Vos travaux sur les pipelines recoupent mes projets ETL.';
      expect(checkAccroche(ok), isEmpty);
    });

    test('une accroche trop longue (> 4 phrases) est rejetée', () {
      const long = 'Un. Deux. Trois. Quatre. Cinq.';
      expect(checkAccroche(long).any((p) => p.contains('trop long')), isTrue);
    });
  });

  group('noDash et les plages de nombres', () {
    test('le tiret de ponctuation devient une virgule', () {
      expect(noDash('Python, 3 ans d\u2019expérience \u2014 en autonomie'),
          'Python, 3 ans d\u2019expérience, en autonomie');
      expect(noDash('mot\u2014mot'), 'mot, mot');
    });

    test('une plage de nombres est préservée', () {
      // « 80–100 » et « 2016–2019 » sont une écriture correcte en français,
      // pas un tic d'IA. Les transformer en « 80, 100 » changerait le sens.
      expect(noDash('score 80\u2013100'), 'score 80\u2013100');
      expect(noDash('CAF du Nord, 2016\u20132019'), 'CAF du Nord, 2016\u20132019');
    });

    test('les deux cas dans la même phrase', () {
      expect(noDash('de 2016\u20132019 \u2014 six mois cumulés'),
          'de 2016\u20132019, six mois cumulés');
    });

    test('des dates séparées par des espaces restent de la ponctuation', () {
      // Espaces autour : c'est un tiret de ponctuation, pas une plage collée.
      expect(noDash('mai 2016 \u2013 mai 2019'), 'mai 2016, mai 2019');
    });

    test('le trait d\u2019union ordinaire n\u2019est jamais touché', () {
      expect(noDash('mini-projet, bien-être'), 'mini-projet, bien-être');
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
