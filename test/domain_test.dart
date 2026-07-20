/// Les cas de test viennent de `reference/offer-utils.test.mjs` : ils vérifient
/// que le portage Dart se comporte comme le code Node éprouvé du projet Docker.
library;

import 'package:candid/domain/hash.dart';
import 'package:candid/domain/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hash', () {
    test('même offre écrite différemment : même hash', () {
      final a = computeHash(
        title: 'Développeur Python (H/F)',
        company: 'ACME SAS',
        location: 'Lille, France',
      );
      final b = computeHash(
        title: 'Developpeur Python F/H',
        company: 'Acme',
        location: '59 - Lille',
      );
      expect(a, b);
    });

    test('offres différentes : hash différents', () {
      final a = computeHash(title: 'Dev Python', company: 'Acme');
      final b = computeHash(title: 'Dev Java', company: 'Acme');
      expect(a, isNot(b));
    });

    test('canonTitle replie les accents', () {
      expect(canonTitle('Développeur Python'), 'developpeur python');
      expect(canonTitle('Ingénieur Données'), canonTitle('Ingenieur Donnees'));
    });

    test('norm tolère le null', () {
      expect(norm(null), '');
    });
  });

  group('dedupHash', () {
    test('même URL à un slash/fragment près : même clé', () {
      final a = dedupHash(url: 'https://candidat.francetravail.fr/offres/detail/211FDFG');
      final b = dedupHash(url: 'https://candidat.francetravail.fr/offres/detail/211FDFG/');
      final c = dedupHash(url: 'https://candidat.francetravail.fr/offres/detail/211FDFG#top');
      expect(a, b);
      expect(a, c);
    });

    test('URLs différentes : clés différentes, même titre saisi', () {
      final a = dedupHash(url: 'https://ft.fr/1', title: 'Dev IA', company: 'X');
      final b = dedupHash(url: 'https://ft.fr/2', title: 'Dev IA', company: 'X');
      expect(a, isNot(b));
    });

    test('URL présente : le titre tapé n\'influence plus la clé', () {
      final a = dedupHash(url: 'https://ft.fr/1', title: 'Dev IA');
      final b = dedupHash(url: 'https://ft.fr/1', title: 'Développeur IA (H/F)');
      expect(a, b);
    });

    test('sans URL : retombe sur le hash titre+entreprise+lieu', () {
      final viaDedns = dedupHash(title: 'Dev', company: 'ACME', location: 'Lille');
      final direct = computeHash(title: 'Dev', company: 'ACME', location: 'Lille');
      expect(viaDedns, direct);
    });
  });

  group('scoring', () {
    test('une offre alignée sur le profil score haut', () {
      final offer = ScorableOffer(
        title: 'Développeur IA Junior',
        description: 'Python, machine learning, LLM. Télétravail hybride.',
        contractType: 'CDI',
        salary: '38-42k',
        location: 'Lille',
      );
      expect(scoreOffer(offer), greaterThanOrEqualTo(80));
    });

    test('une offre senior hors sujet score bas', () {
      final offer = ScorableOffer(
        title: 'Lead Developer PHP Senior',
        description: '10 ans d\'expérience exigés.',
        contractType: 'Freelance',
      );
      expect(scoreOffer(offer), lessThanOrEqualTo(35));
    });

    test('le score reste dans les bornes', () {
      final offer = ScorableOffer(title: '', description: '');
      final s = scoreOffer(offer);
      expect(s, inInclusiveRange(0, 100));
    });

    test('viser junior favorise une offre junior', () {
      const junior = ScorableOffer(title: 'Développeur Python Junior');
      final wantJunior = Prefs.fromProfile(seniority: 'Junior');
      final wantSenior = Prefs.fromProfile(seniority: 'Senior');
      expect(
        scoreOffer(junior, wantJunior),
        greaterThan(scoreOffer(junior, wantSenior)),
      );
    });
  });

  group('exclusions', () {
    final prefs = Prefs.fromProfile(
      keywords: 'python fastapi',
      contractTypes: 'CDI, Alternance',
      exclusions: '5 ans, PHP',
      seniority: 'Junior',
    );

    test('le profil se lit bien', () {
      expect(prefs.keywords, containsAll(['python', 'fastapi']));
      expect(prefs.contractTypes, ['cdi', 'alternance']);
      expect(prefs.exclusions, ['5 ans', 'php']);
      expect(prefs.seniority, 'junior');
    });

    test('une offre PHP est exclue, pas seulement mal notée', () {
      const php = ScorableOffer(
        title: 'Développeur PHP',
        description: 'Symfony',
      );
      expect(matchesExclusions(php, prefs.exclusions), isTrue);
      expect(annotate(php, prefs).excluded, isTrue);
    });

    test('une offre conforme n\'est pas exclue', () {
      const ok = ScorableOffer(
        title: 'Développeur Python Junior',
        description: 'FastAPI',
      );
      expect(annotate(ok, prefs).excluded, isFalse);
    });
  });

  group('filtre géographique', () {
    test('Bruxelles est hors zone', () {
      expect(isOutOfZone(const ScorableOffer(title: 'Dev', location: 'Bruxelles')),
          isTrue);
    });

    test('Tournai est tolérée : frontalière', () {
      expect(isOutOfZone(const ScorableOffer(title: 'Dev', location: 'Tournai')),
          isFalse);
    });

    test('un lieu vide est gardé : les sources disent souvent juste « France »',
        () {
      expect(isOutOfZone(const ScorableOffer(title: 'Dev')), isFalse);
    });
  });
}
