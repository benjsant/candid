/// Le port de l'assemblage de lettre reprend l'intention de
/// `reference/letter-template.mjs` : coller l'accroche, résoudre les
/// placeholders, extraire l'objet, retirer la signature, bannir les tirets
/// cadratin. Le corps figé n'est jamais réécrit.
library;

import 'package:candid/render/letter_template.dart';
import 'package:flutter_test/flutter_test.dart';

const _template = '''
<!--
Bloc de commentaire d'entête, à retirer entièrement.
-->

Objet : Candidature au poste de {{poste.intitule}}

Madame, Monsieur,

[Accroche : 2-3 phrases sur {{entreprise.nom}}. SEULE partie à rédiger.]

Développeur Python spécialisé en IA, je conçois des projets concrets.

{{candidat.nom}}
{{candidat.email}} · {{candidat.telephone}}

<!--
Ton de référence, à retirer aussi.
-->
''';

void main() {
  test('l\'objet est extrait et résolu, retiré du corps', () {
    final r = fillTemplate(_template,
        accroche: 'Bonjour.',
        vars: const LetterVars(poste: 'Développeur IA'));
    expect(r.subject, 'Candidature au poste de Développeur IA');
    expect(r.body, isNot(contains('Objet :')));
  });

  test('l\'accroche remplace le bloc [Accroche …], et lui seul', () {
    final r = fillTemplate(_template,
        accroche: 'Votre produit IA me parle.',
        vars: const LetterVars(company: 'ACME'));
    expect(r.body, contains('Votre produit IA me parle.'));
    expect(r.body, isNot(contains('[Accroche')));
    // Le corps figé reste intact.
    expect(r.body, contains('je conçois des projets concrets'));
  });

  test('la signature finale est retirée (régénérée par la mise en page)', () {
    final r = fillTemplate(_template,
        vars: const LetterVars(nom: 'Benjamin', email: 'b@x.fr'));
    expect(r.body, isNot(contains('b@x.fr')));
    expect(r.body, isNot(contains('{{candidat')));
  });

  test('les commentaires HTML sont retirés', () {
    final r = fillTemplate(_template);
    expect(r.body, isNot(contains('Bloc de commentaire')));
    expect(r.body, isNot(contains('Ton de référence')));
  });

  test('un placeholder inconnu est laissé intact', () {
    final r = fillTemplate('Objet : x\n\n{{inconnu.champ}}');
    expect(r.body, contains('{{inconnu.champ}}'));
  });

  test('noDash remplace les tirets cadratin, pas le trait d\'union', () {
    expect(noDash('bout — en — bout'), 'bout, en, bout');
    expect(noDash('bout-en-bout'), 'bout-en-bout');
  });

  test('l\'accroche à tirets cadratin est nettoyée dans le corps', () {
    final r = fillTemplate(_template, accroche: 'Un fait — vérifiable — ici.');
    expect(r.body, contains('Un fait, vérifiable, ici.'));
    expect(r.body, isNot(contains('—')));
  });
}
