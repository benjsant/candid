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

  /// Commune retenue. Tant qu'elle est nulle, la recherche n'est pas bornée
  /// géographiquement, et on le dit clairement à l'écran.
  Commune? _selected;
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
      _commune.text = p?.locationLabel ?? '';
      if (p?.locationInsee != null && p?.locationLabel != null) {
        _selected = Commune(
          name: p!.locationLabel!,
          inseeCode: p.locationInsee!,
        );
      }
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
    await widget.repository.save(
      keywords: _keywords.text,
      locationLabel: _selected?.label,
      locationInsee: _selected?.inseeCode,
      radiusKm: _selected == null ? null : _radiusKm,
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
                    labelText: 'Ville',
                    hintText: 'Valenciennes, Lille…',
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
                        _selected = c;
                        _commune.text = c.label;
                        _suggestions = const [];
                      }),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (_selected == null)
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
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_selected!.label} · code INSEE '
                          '${_selected!.inseeCode}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _selected = null;
                          _commune.clear();
                        }),
                        child: const Text('Retirer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _radiusKm,
                    decoration: const InputDecoration(
                      labelText: 'Rayon',
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
