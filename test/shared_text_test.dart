/// Le parseur de partage travaille sur du texte non structuré : ces tests
/// fixent ce qu'il sait faire, et surtout ce qu'il admet ne pas savoir.
library;

import 'package:candid/sources/shared_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partage LinkedIn : « Titre chez Entreprise » + lien', () {
    final o = parseSharedText(
      'Développeur IA Junior chez ACME\n'
      'https://www.linkedin.com/jobs/view/1234567890',
    );
    expect(o.title, 'Développeur IA Junior');
    expect(o.company, 'ACME');
    expect(o.source, 'linkedin');
    expect(o.url, 'https://www.linkedin.com/jobs/view/1234567890');
    expect(o.needsReview, isFalse);
  });

  test('formulation « Entreprise recrute un Titre »', () {
    final o = parseSharedText('ACME recrute un Développeur Python Junior');
    expect(o.company, 'ACME');
    expect(o.title, 'Développeur Python Junior');
  });

  test('la source se déduit de l\'URL', () {
    expect(parseSharedText('x https://fr.indeed.com/viewjob?jk=1').source,
        'indeed');
    expect(
      parseSharedText('x https://www.welcometothejungle.com/fr/companies/a/jobs/b')
          .source,
      'wttj',
    );
    expect(parseSharedText('Un texte sans lien').source, 'shared');
  });

  test('texte non reconnu : le titre est proposé, l\'entreprise est admise '
      'comme inconnue plutôt que devinée', () {
    final o = parseSharedText(
      'Ingénieur Machine Learning\n'
      'CDI - Lille - 40k\n'
      'Nous cherchons quelqu\'un pour...',
    );
    expect(o.title, 'Ingénieur Machine Learning');
    expect(o.company, isNull);
    expect(o.needsReview, isTrue, reason: 'l\'utilisateur doit compléter');
  });

  test('le texte brut est toujours conservé : l\'agent en saura plus que nous',
      () {
    const raw = 'Dev IA chez ACME\nMissions : LLM, RAG, FastAPI.';
    expect(parseSharedText(raw).rawText, raw);
  });

  test('l\'URL est retirée avant de chercher le titre', () {
    final o = parseSharedText('https://exemple.fr/offre\nDéveloppeur Go');
    expect(o.title, 'Développeur Go');
  });
}
