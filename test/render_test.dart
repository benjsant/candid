/// Tests de fumée du rendu PDF : on construit réellement les documents et on
/// vérifie qu'ils produisent des octets. Ça attrape les erreurs d'arbre de
/// widgets `pdf` (une police manquante, un enfant nul), invisibles à l'analyse.
library;

import 'package:candid/render/cv_document.dart';
import 'package:candid/render/letter_document.dart';
import 'package:candid/render/letter_template.dart';
import 'package:flutter_test/flutter_test.dart';

CvData _sampleCv() => const CvData(
      profile: {
        'name': 'Benjamin Santrisse',
        'title': 'Développeur Backend Python',
        'email': 'x@y.fr',
        'summary': 'Développeur Python spécialisé en IA appliquée.',
        'residence': 'Marly (59)',
        'permis': 'B + véhicule',
        'location': 'Valenciennes / Lille',
        'links': {'github': 'https://github.com/x', 'portfolio': 'https://x.dev'},
      },
      skills: {
        'categories': [
          {
            'name': 'IA & Données',
            'items': [
              {'name': 'Machine Learning', 'level': ''},
              {'name': 'Java', 'level': 'notions'},
            ],
          },
        ],
      },
      projects: {
        'projects': [
          {
            'name': 'InfiniDex',
            'period': 'Avril 2026 - en cours',
            'description': 'Agent LLM multi-provider.',
            'tech': ['Python', 'FastAPI'],
          },
        ],
      },
      experiences: {
        'experiences': [
          {
            'role': 'Développeur Web Symfony',
            'company': 'CAF du Nord',
            'date': 'Mai 2016 - Mai 2019',
            'bullets': [
              'Développement d\'interfaces web',
              'Stack : PHP, Symfony, Git',
            ],
          },
        ],
      },
      education: {
        'education': [
          {'degree': 'Certification Développeur IA', 'school': 'Simplon', 'date': '2025-26'},
        ],
      },
      certifications: {
        'certifications': [
          {'name': 'Méthodes agiles', 'year': '2025'},
        ],
      },
      languages: {
        'languages': [
          {'name': 'Français', 'level': 'Courant'},
        ],
      },
      interests: {
        'interests': [
          {'title': 'Veille technologique', 'description': 'IA, open source'},
        ],
      },
    );

void main() {
  test('le CV se construit et produit un PDF non vide', () async {
    final doc = buildCvDocument(_sampleCv());
    final bytes = await doc.save();
    expect(bytes.length, greaterThan(1000));
  });

  test('la lettre se construit et produit un PDF non vide', () async {
    const md = '''
Objet : Candidature au poste de {{poste.intitule}}

Madame, Monsieur,

[Accroche : à rédiger sur {{entreprise.nom}}.]

Le corps figé de la lettre, avec une puce :
• InfiniDex : agent LLM multi-provider.

{{candidat.nom}}
''';
    final letter = fillTemplate(md,
        accroche: 'Votre mission IA me parle.',
        vars: const LetterVars(poste: 'Développeur IA', company: 'ACME'));
    final doc = buildLetterDocument(letter,
        senderName: 'Benjamin Santrisse',
        senderEmail: 'x@y.fr',
        senderLocation: 'Marly (59)',
        date: DateTime(2026, 7, 20));
    final bytes = await doc.save();
    expect(bytes.length, greaterThan(1000));
    expect(letter.subject, 'Candidature au poste de Développeur IA');
  });
}
