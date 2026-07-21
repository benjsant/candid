/// Écran du profil de recherche : ce qu'on cherche, et surtout **où**.
///
/// Sans lui, la collecte part sans filtre géographique et remonte des offres à
/// l'autre bout de la France, mieux notées que les offres locales (constat du
/// 21/07/2026 : Toulouse et Lyon à 92). C'est le préalable à toute collecte
/// périodique, sinon les notifications ne seraient que du bruit.
library;

import 'package:flutter/material.dart';

import '../data/profile_repository.dart';
import '../sources/geo.dart';

class SearchProfileScreen extends StatefulWidget {
  const SearchProfileScreen({super.key, required this.repository});

  final ProfileRepository repository;

  @override
  State<SearchProfileScreen> createState() => _SearchProfileScreenState();
}

class _SearchProfileScreenState extends State<SearchProfileScreen> {
  final _keywords = TextEditingController();
  final _mustHave = TextEditingController();
  final _exclusions = TextEditingController();
  final _contracts = TextEditingController();
  final _commune = TextEditingController();

  String _seniority = '';
  int? _radiusKm = 30;

  /// Communes retenues. Tant que la liste est vide, la recherche n'est pas
  /// bornée géographiquement, et on le dit clairement à l'écran. France Travail
  /// accepte plusieurs codes INSEE en une requête, donc en ajouter ne coûte
  /// aucun appel supplémentaire.
  final List<Commune> _selected = [];
  List<Commune> _suggestions = const [];
  bool _searching = false;
  bool _loading = true;

  static const _seniorities = {
    '': 'Peu importe',
    'junior': 'Junior / débutant',
    'alternance': 'Alternance',
    'senior': 'Confirmé / senior',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await widget.repository.active();
    if (!mounted) return;
    setState(() {
      _keywords.text =
          p?.keywords ?? 'développeur, python, intelligence artificielle';
      _mustHave.text = p?.mustHave ?? '';
      _exclusions.text = p?.exclusions ?? '';
      _contracts.text = p?.contractTypes ?? '';
      _seniority = _seniorities.containsKey(p?.seniority ?? '')
          ? (p?.seniority ?? '')
          : '';
      _radiusKm = p?.radiusKm ?? 30;
      _commune.clear();
      final stored =
          ProfileCommunes.parse(p?.locationLabel, p?.locationInsee);
      _selected
        ..clear()
        ..addAll([
          for (var i = 0; i < stored.codes.length; i++)
            Commune(name: stored.labels[i], inseeCode: stored.codes[i]),
        ]);
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in [_keywords, _mustHave, _exclusions, _contracts, _commune]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lookup(String query) async {
    setState(() => _searching = true);
    final results = await searchCommunes(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _searching = false;
    });
  }

  Future<void> _save() async {
    final communes = ProfileCommunes(
      _selected.map((c) => c.label).toList(),
      _selected.map((c) => c.inseeCode).toList(),
    );
    await widget.repository.save(
      keywords: _keywords.text,
      locationLabel: communes.storedLabels,
      locationInsee: communes.storedCodes,
      radiusKm: communes.isEmpty ? null : _radiusKm,
      contractTypes: _contracts.text,
      seniority: _seniority,
      mustHave: _mustHave.text,
      exclusions: _exclusions.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil de recherche enregistré.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil de recherche')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Ce profil sert à deux choses : ce qu\'on demande aux '
                      'sources, et comment les offres sont notées. Sans '
                      'commune, la collecte ratisse toute la France.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text('Où', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _commune,
                  decoration: InputDecoration(
                    labelText: 'Ajouter une ville',
                    hintText: 'Valenciennes, puis Lille, Douai…',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Chercher la commune',
                            onPressed: () => _lookup(_commune.text),
                          ),
                  ),
                  onSubmitted: _lookup,
                ),
                if (_suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._suggestions.map(
                    (c) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(c.label),
                      subtitle: Text('Code INSEE ${c.inseeCode}'),
                      onTap: () => setState(() {
                        if (!_selected.any((x) => x.inseeCode == c.inseeCode)) {
                          _selected.add(c);
                        }
                        _commune.clear();
                        _suggestions = const [];
                      }),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (_selected.isEmpty)
                  Row(
                    children: [
                      Icon(Icons.warning_amber_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aucune commune retenue : la collecte remontera des '
                          'offres de toute la France.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  )
                else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in _selected)
                        InputChip(
                          avatar: const Icon(Icons.place_outlined, size: 18),
                          label: Text(c.label),
                          onDeleted: () =>
                              setState(() => _selected.remove(c)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selected.length == 1
                        ? 'Une commune retenue.'
                        : '${_selected.length} communes retenues, '
                            'interrogées ensemble.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _radiusKm,
                    decoration: const InputDecoration(
                      labelText: 'Rayon autour de chaque commune',
                      border: OutlineInputBorder(),
                    ),
                    items: const [10, 20, 30, 50, 100]
                        .map((km) => DropdownMenuItem(
                              value: km,
                              child: Text('$km km'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _radiusKm = v),
                  ),
                ],

                const Divider(height: 40),
                Text('Quoi', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _keywords,
                  decoration: const InputDecoration(
                    labelText: 'Mots-clés',
                    helperText: 'Séparés par des virgules : une recherche par '
                        'terme. France Travail exige que TOUS les mots d\'un '
                        'même terme figurent dans l\'offre.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _seniority,
                  decoration: const InputDecoration(
                    labelText: 'Niveau visé',
                    border: OutlineInputBorder(),
                  ),
                  items: _seniorities.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _seniority = v ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contracts,
                  decoration: const InputDecoration(
                    labelText: 'Types de contrat (facultatif)',
                    hintText: 'CDI, alternance',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _mustHave,
                  decoration: const InputDecoration(
                    labelText: 'Indispensables (facultatif)',
                    helperText: 'Séparés par des virgules. Comptent double.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _exclusions,
                  decoration: const InputDecoration(
                    labelText: 'Exclusions (facultatif)',
                    helperText:
                        'Une offre qui en contient une est écartée, pas juste '
                        'mal notée.',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer le profil'),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
