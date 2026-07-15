/// Chargement des assets repris tels quels du projet Docker : le prompt système
/// de l'agent, les templates de lettres, et les données du CV maître.
///
/// Ces fichiers sont la source de vérité du comportement de l'agent. Ils ne sont
/// pas dupliqués en Dart : on les lit.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Les 7 templates de lettres, corps figé et validé. L'agent choisit le plus
/// adapté à l'offre.
enum LetterTemplate {
  iaJunior('ia-junior'),
  backend('backend'),
  frontend('frontend'),
  phpSymfony('php-symfony'),
  employeNumerique('employe-numerique'),
  alternance('alternance'),
  candidatureSpontanee('candidature-spontanee');

  const LetterTemplate(this.slug);

  final String slug;

  static LetterTemplate? fromSlug(String slug) {
    for (final t in LetterTemplate.values) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}

class AppAssets {
  const AppAssets();

  /// La source de vérité du comportement de l'agent. Toute évolution passe par
  /// ce fichier, pas par du code dispersé.
  Future<String> systemPrompt() =>
      rootBundle.loadString('assets/prompts/agent-system-prompt.md');

  Future<String> letter(LetterTemplate template) =>
      rootBundle.loadString('assets/letters/${template.slug}.md');

  /// Index condensé du CV : c'est lui qu'on donne à l'agent, pour qu'il ne
  /// puisse mettre en avant que ce qui existe réellement.
  Future<Map<String, dynamic>> cvIndex() async => _json('cv-index');

  Future<Map<String, dynamic>> profile() async => _json('profile');
  Future<Map<String, dynamic>> skills() async => _json('skills');
  Future<Map<String, dynamic>> projects() async => _json('projects');
  Future<Map<String, dynamic>> experiences() async => _json('experiences');
  Future<Map<String, dynamic>> education() async => _json('education');
  Future<Map<String, dynamic>> certifications() async => _json('certifications');
  Future<Map<String, dynamic>> languages() async => _json('languages');
  Future<Map<String, dynamic>> interests() async => _json('interests');

  Future<Map<String, dynamic>> _json(String name) async {
    final raw = await rootBundle.loadString('assets/cv/$name.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
