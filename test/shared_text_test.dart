/// Le parseur de partage travaille sur du texte non structuré : ces tests
/// fixent ce qu'il sait faire, et surtout ce qu'il admet ne pas savoir.
library;

import 'package:candid/sources/shared_text.dart';
import 'package:flutter_test/flutter_test.dart';

/// Une capture réelle : le texte exactement tel qu'une application l'a partagé
/// (bouton « Partager » → Candid, puis copié depuis l'écran de réception via
/// « Texte partagé »), et ce que le parseur doit en tirer.
class CaptureReelle {
  const CaptureReelle({
    required this.nom,
    required this.brut,
    this.titre,
    this.entreprise,
    required this.source,
  });

  final String nom;
  final String brut;

  /// Nul si même un humain ne peut pas le déduire du texte : le parseur doit
  /// alors admettre l'inconnue (`needsReview`), pas deviner.
  final String? titre;
  final String? entreprise;
  final String source;
}

/// À REMPLIR AVEC DES CAPTURES RÉELLES, pas avec des exemples imaginés : les
/// regex de `shared_text.dart` sont des suppositions tant que cette liste est
/// vide, et chaque application (LinkedIn, Indeed, WTTJ, HelloWork) formate son
/// partage différemment. Une entrée par application, plus si les formats
/// varient. Voir la tâche dédiée de l'étape 2 dans TASKS.md.
const capturesReelles = <CaptureReelle>[
  // Capturé le 19/07/2026 sur l'app LinkedIn officielle (Android 13), offre
  // « Développeur Python H/F » chez NEXTON, extrait de la base de l'appareil.
  // L'app ne partage QUE l'URL : aucun titre, aucune entreprise. Le parseur
  // doit l'admettre (needsReview) et laisser l'utilisateur compléter ; aucune
  // regex de titre ne sauvera ce cas.
  CaptureReelle(
    nom: 'LinkedIn, app officielle : URL seule',
    brut: 'https://www.linkedin.com/jobs/view/4435206974/',
    titre: null,
    entreprise: null,
    source: 'linkedin',
  ),
];

void main() {
  group('captures réelles', () {
    for (final c in capturesReelles) {
      test(c.nom, () {
        final o = parseSharedText(c.brut);
        expect(o.title, c.titre);
        expect(o.company, c.entreprise);
        expect(o.source, c.source);
        expect(o.rawText, c.brut.trim(),
            reason: 'le texte brut doit rester intact pour l\'agent');
      });
    }
  });

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
