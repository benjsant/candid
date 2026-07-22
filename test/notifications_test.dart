/// Le texte de la notification est une fonction pure : c'est la seule partie
/// de la chaîne de fond qui se teste sans appareil, et c'est aussi celle qui
/// décide si l'utilisateur garde l'application ou la désinstalle.
library;

import 'package:candid/core/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rien de neuf : aucune notification', () {
    // Une notification « 0 nouvelle offre » chaque matin est une nuisance.
    expect(collectNotification(saved: 0, notable: 0), isNull);
  });

  test('des offres, dont des notables', () {
    final n = collectNotification(saved: 12, notable: 3);
    expect(n!.title, '12 nouvelles offres');
    expect(n.body, contains('3 dépassent'));
    expect(n.body, contains('$kNotableScore/100'));
  });

  test('une seule offre : le singulier est respecté', () {
    final n = collectNotification(saved: 1, notable: 1);
    expect(n!.title, '1 nouvelle offre');
    expect(n.body, '1 dépasse $kNotableScore/100.');
  });

  test('des offres mais aucune notable : on le dit quand même', () {
    // L'utilisateur doit pouvoir décider de ne pas ouvrir l'application.
    final n = collectNotification(saved: 5, notable: 0);
    expect(n!.title, '5 nouvelles offres');
    expect(n.body, contains('Aucune ne dépasse'));
  });

  test('panne persistante : on prévient plutôt que de rester muet', () {
    // Sinon l'utilisateur croit que la collecte tourne alors qu'elle échoue
    // tous les jours en silence.
    final n = collectNotification(
      saved: 0,
      notable: 0,
      errors: const ['Identifiants France Travail refusés.'],
    );
    expect(n, isNotNull);
    expect(n!.title, 'Collecte interrompue');
    expect(n.body, contains('refusés'));
  });

  test('des offres malgré une source en panne : on annonce les offres', () {
    // Le positif prime : l'erreur n'a pas empêché la collecte d'aboutir.
    final n = collectNotification(
      saved: 4,
      notable: 1,
      errors: const ['La Bonne Alternance injoignable.'],
    );
    expect(n!.title, '4 nouvelles offres');
  });
}
