/// Tests des normaliseurs de sources. Les cas reprennent les formes réelles
/// vérifiées côté projet Docker (`sources.test.mjs`), y compris les cas
/// dégradés : c'est là que se joue la règle « jamais d'invention ».
library;

import 'package:candid/sources/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeFranceTravail', () {
    test('mappe une offre complète', () {
      final offers = normalizeFranceTravail({
        'resultats': [
          {
            'id': '191KTPX',
            'intitule': 'Développeur IA H/F',
            'entreprise': {'nom': 'ACME SAS'},
            'lieuTravail': {'libelle': '59 - VALENCIENNES'},
            'typeContrat': 'CDI',
            'salaire': {'libelle': 'Annuel de 32000,00 Euros'},
            'description': 'Vous développerez des modèles.',
            'origineOffre': {'urlOrigine': 'https://candidat.francetravail.fr/…'},
          },
        ],
      });

      expect(offers, hasLength(1));
      final o = offers.first;
      expect(o.source, 'france_travail');
      expect(o.sourceId, '191KTPX');
      expect(o.title, 'Développeur IA H/F');
      expect(o.company, 'ACME SAS');
      expect(o.location, '59 - VALENCIENNES');
      expect(o.contractType, 'CDI');
      expect(o.salary, 'Annuel de 32000,00 Euros');
      expect(o.url, 'https://candidat.francetravail.fr/…');
    });

    test('un champ absent reste vide, il n\'est pas deviné', () {
      // Cas fréquent : une offre anonymisée, sans entreprise ni salaire.
      final offers = normalizeFranceTravail({
        'resultats': [
          {'id': '1', 'intitule': 'Dev'},
        ],
      });
      expect(offers.first.company, '');
      expect(offers.first.salary, '');
      expect(offers.first.location, '');
      expect(offers.first.url, '');
    });

    test('typeContratLibelle sert de repli à typeContrat', () {
      final offers = normalizeFranceTravail({
        'resultats': [
          {'id': '1', 'intitule': 'Dev', 'typeContratLibelle': 'Contrat à durée indéterminée'},
        ],
      });
      expect(offers.first.contractType, 'Contrat à durée indéterminée');
    });

    test('payload vide ou nul ne casse pas', () {
      expect(normalizeFranceTravail(null), isEmpty);
      expect(normalizeFranceTravail({}), isEmpty);
      expect(normalizeFranceTravail({'resultats': null}), isEmpty);
    });
  });

  group('normalizeLaBonneAlternanceJobs', () {
    test('mappe une offre d\'alternance', () {
      final offers = normalizeLaBonneAlternanceJobs({
        'jobs': [
          {
            'identifier': {'id': 'abc-123'},
            'offer': {
              'title': 'Alternance Développeur',
              'description': 'Au sein de l\'équipe data.',
            },
            'workplace': {
              'brand': 'ACME',
              'location': {'address': '59300 Valenciennes'},
            },
            'contract': {
              'type': ['Apprentissage', 'Professionnalisation'],
            },
            'apply': {'url': 'https://labonnealternance.fr/offre/abc-123'},
          },
        ],
      });

      final o = offers.single;
      expect(o.source, 'la_bonne_alternance');
      expect(o.sourceId, 'abc-123');
      expect(o.company, 'ACME');
      expect(o.contractType, 'Apprentissage, Professionnalisation');
      expect(o.location, '59300 Valenciennes');
    });

    test('offre partenaire sans nom d\'entreprise : company vide, pas inventée',
        () {
      // Constat réel côté Docker : les jobs venus de France Travail ont
      // workplace.{brand,name,legal_name} à null. On dégrade, on ne comble pas.
      final offers = normalizeLaBonneAlternanceJobs({
        'jobs': [
          {
            'identifier': {'partner_job_id': 'ft-999'},
            'offer': {'title': 'Alternance Dev'},
            'workplace': {'brand': null, 'name': null, 'legal_name': null},
          },
        ],
      });
      final o = offers.single;
      expect(o.company, '');
      expect(o.sourceId, 'ft-999', reason: 'repli sur partner_job_id');
      expect(o.contractType, 'Alternance', reason: 'la nature de la source');
    });

    test('cascade brand > name > legal_name', () {
      final offers = normalizeLaBonneAlternanceJobs({
        'jobs': [
          {
            'offer': {'title': 'T'},
            'workplace': {'brand': '', 'name': null, 'legal_name': 'ACME SAS'},
          },
        ],
      });
      expect(offers.single.company, 'ACME SAS');
    });
  });

  group('normalizeLbaRecruiters', () {
    test('mappe une entreprise à contacter', () {
      final recruiters = normalizeLbaRecruiters({
        'recruiters': [
          {
            'identifier': {'id': 'r-1'},
            'workplace': {
              'name': 'ACME',
              'siret': '12345678900011',
              'website': 'https://acme.fr',
              'domain': {
                'naf': {'label': 'Programmation informatique'},
              },
              'location': {'address': 'Lille'},
            },
            'apply': {
              'url': 'https://labonnealternance.fr/r-1',
              'email': 'rh@acme.fr',
            },
          },
        ],
      });

      final r = recruiters.single;
      expect(r.name, 'ACME');
      expect(r.siret, '12345678900011');
      expect(r.sector, 'Programmation informatique');
      expect(r.email, 'rh@acme.fr');
    });

    test('payload sans recruiters ne casse pas', () {
      expect(normalizeLbaRecruiters({'jobs': []}), isEmpty);
      expect(normalizeLbaRecruiters(null), isEmpty);
    });
  });
}
