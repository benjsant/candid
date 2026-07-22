/// Rapprochement inter-sources.
///
/// Les cas viennent des **125 offres réellement collectées** le 22/07/2026.
/// C'est important : la tentation d'une déduplication « intelligente » est
/// forte, et ces données montrent qu'elle masquerait de vraies offres.
library;

import 'package:candid/domain/dedup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('canonCity', () {
    test('rapproche les écritures des différentes sources', () {
      // France Travail écrit « 59 - Roubaix », La Bonne Alternance
      // « 59100 Roubaix ». C'est la même ville.
      expect(canonCity('59 - Roubaix'), canonCity('59100 Roubaix'));
      expect(canonCity('59 - Roubaix'), 'roubaix');
      expect(canonCity('Roubaix (59)'), 'roubaix');
      expect(canonCity("59 - Villeneuve-d'Ascq"), "villeneuve d'ascq");
    });

    test('lieu absent ou vide', () {
      expect(canonCity(null), '');
      expect(canonCity('  '), '');
      expect(canonCity('59'), '');
    });
  });

  group('isCrossSourceDuplicate', () {
    test('LE cas réel : la même offre via France Travail et LBA', () {
      // Constat du 21/07/2026 : LBA rediffuse les offres France Travail, mais
      // sans le nom de l'employeur. Deux entrées pour une seule offre.
      const ft = DedupCandidate(
        source: 'france_travail',
        title: 'Développeur / Développeuse informatique (H/F)',
        company: '',
        location: '59 - Roubaix',
      );
      const lba = DedupCandidate(
        source: 'la_bonne_alternance',
        title: 'Développeur / Développeuse informatique (H/F)',
        company: '',
        location: '59100 Roubaix',
      );
      expect(isCrossSourceDuplicate(ft, lba), isTrue);
    });

    test('une entreprise nommée d\'un seul côté reste compatible', () {
      const anonyme = DedupCandidate(
        source: 'france_travail',
        title: 'Développeur web',
        company: '',
        location: 'Lille',
      );
      const nommee = DedupCandidate(
        source: 'la_bonne_alternance',
        title: 'Développeur web',
        company: 'ACME',
        location: 'Lille',
      );
      expect(isCrossSourceDuplicate(anonyme, nommee), isTrue);
    });

    test('MÊME SOURCE : jamais fusionnées, même si tout se ressemble', () {
      // Cas réel : quatre « Développeur / Développeuse web (H/F) » à Lille,
      // tous chez France Travail, publiés par des agences différentes. Ce sont
      // quatre annonces distinctes.
      const a = DedupCandidate(
        source: 'france_travail',
        title: 'Développeur / Développeuse web (H/F)',
        company: '',
        location: '59 - Lille',
      );
      const b = DedupCandidate(
        source: 'france_travail',
        title: 'Développeur / Développeuse web (H/F)',
        company: 'MANPOWER FRANCE',
        location: '59 - Lille',
      );
      expect(isCrossSourceDuplicate(a, b), isFalse);
    });

    test('entreprises nommées et différentes : deux vraies offres', () {
      // Cas réel : trois « Data manager (H/F) » chez NEW NET 3D, ADECCO et
      // LE CABRH. Les fusionner cacherait des offres auxquelles postuler.
      const a = DedupCandidate(
        source: 'france_travail',
        title: 'Data manager (H/F)',
        company: 'NEW NET 3D',
        location: '59 - Lille',
      );
      const b = DedupCandidate(
        source: 'la_bonne_alternance',
        title: 'Data manager (H/F)',
        company: 'ADECCO FRANCE',
        location: '59 - Lille',
      );
      expect(isCrossSourceDuplicate(a, b), isFalse);
    });

    test('villes différentes : pas la même offre', () {
      const a = DedupCandidate(
        source: 'france_travail',
        title: 'Développeur Javascript (H/F)',
        company: '',
        location: '59 - Roubaix',
      );
      const b = DedupCandidate(
        source: 'la_bonne_alternance',
        title: 'Développeur Javascript (H/F)',
        company: '',
        location: '59 - Lille',
      );
      expect(isCrossSourceDuplicate(a, b), isFalse);
    });

    test('lieu inconnu : on refuse de trancher', () {
      // Sans lieu, il reste trop peu pour affirmer que c'est la même offre.
      const a = DedupCandidate(
        source: 'linkedin',
        title: 'Développeur IA Junior',
        company: '',
      );
      const b = DedupCandidate(
        source: 'wttj',
        title: 'Développeur IA Junior',
        company: '',
      );
      expect(isCrossSourceDuplicate(a, b), isFalse);
    });

    test('titre vide : jamais un motif de fusion', () {
      const a = DedupCandidate(source: 'a', title: '', location: 'Lille');
      const b = DedupCandidate(source: 'b', title: '', location: 'Lille');
      expect(isCrossSourceDuplicate(a, b), isFalse);
    });
  });
}
