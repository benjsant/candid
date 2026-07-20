/// Grounding de l'entreprise par le registre officiel (INSEE), via l'API
/// publique `recherche-entreprises.api.gouv.fr` : sans clé, sans OAuth.
///
/// C'est le nœud `research` porté depuis `reference/graph.py`. Il fournit des
/// FAITS OFFICIELS et vérifiables (raison sociale, siège, création, taille) que
/// l'agent utilise pour ancrer l'accroche. On ne fait pas de recherche web sur
/// mobile : pas d'API fiable sans clé, et le registre suffit à ancrer un fait
/// réel. Règle du projet : ces faits ne sont JAMAIS inventés ; si le registre ne
/// répond rien, on renvoie une chaîne vide et l'agent s'en passe.
library;

import 'package:dio/dio.dart';

const _endpoint = 'https://recherche-entreprises.api.gouv.fr/search';

/// Traduit la catégorie INSEE en libellé lisible.
const _categorieLabels = {
  'PME': 'PME',
  'ETI': 'entreprise de taille intermédiaire (ETI)',
  'GE': 'grande entreprise',
};

/// Interroge le registre pour [company] et renvoie un texte de faits officiels,
/// ou '' si rien de fiable (aucun résultat, réseau, réponse inattendue).
///
/// Tolérant par conception : le grounding est un bonus, jamais un bloquant. Une
/// panne réseau ne doit pas empêcher de générer la candidature.
Future<String> companyRegistryGrounding(String company, {Dio? dio}) async {
  final name = company.trim();
  if (name.isEmpty) return '';
  final client = dio ?? Dio();

  try {
    final resp = await client.get<dynamic>(
      _endpoint,
      queryParameters: {'q': name, 'per_page': 1},
      options: Options(validateStatus: (_) => true),
    );
    if (resp.statusCode != 200 || resp.data is! Map) return '';
    final results = (resp.data as Map)['results'];
    if (results is! List || results.isEmpty) return '';
    final first = results.first;
    if (first is! Map) return '';
    return _format(first.cast<String, dynamic>());
  } catch (_) {
    return '';
  }
}

String _format(Map<String, dynamic> r) {
  final facts = <String>[];

  final nom = (r['nom_complet'] ?? r['nom_raison_sociale'] ?? '').toString().trim();
  if (nom.isEmpty) return ''; // sans nom, le résultat n'est pas exploitable.
  facts.add('Nom : $nom');

  final cat = _categorieLabels[r['categorie_entreprise']];
  if (cat != null) facts.add('Taille : $cat');

  final siege = (r['siege'] is Map) ? (r['siege'] as Map) : const {};
  final commune = (siege['libelle_commune'] ?? '').toString().trim();
  final cp = (siege['code_postal'] ?? '').toString().trim();
  if (commune.isNotEmpty) {
    facts.add('Siège : $commune${cp.isNotEmpty ? ' ($cp)' : ''}');
  }

  final annee = _year(r['date_creation']);
  if (annee != null) facts.add('Création : $annee');

  final naf = (r['activite_principale'] ?? '').toString().trim();
  if (naf.isNotEmpty) facts.add('Code d\'activité (NAF) : $naf');

  if (facts.length <= 1) return ''; // juste le nom : trop peu pour ancrer.
  return 'Faits officiels (registre des entreprises, INSEE) :\n'
      '${facts.map((f) => '- $f').join('\n')}';
}

String? _year(Object? date) {
  final s = (date ?? '').toString();
  final m = RegExp(r'^(\d{4})').firstMatch(s);
  return m?.group(1);
}
