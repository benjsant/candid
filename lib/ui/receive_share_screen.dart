/// Écran de réception d'une offre partagée.
///
/// Le parseur propose, l'utilisateur dispose. Rien n'est enregistré sans qu'il
/// ait vu ce qu'on a compris du texte partagé : c'est la même règle que pour
/// l'agent, on n'invente pas en silence.
library;

import 'package:flutter/material.dart';

import '../data/offers_repository.dart';
import '../sources/france_travail.dart';
import '../sources/normalize.dart';
import '../sources/shared_text.dart';

class ReceiveShareScreen extends StatefulWidget {
  const ReceiveShareScreen({
    super.key,
    required this.shared,
    required this.repository,
    this.franceTravail,
  });

  final SharedOffer shared;
  final OffersRepository repository;

  /// Facultatif : permet de résoudre une URL France Travail partagée en offre
  /// complète. Absent (ou sans identifiants), l'écran fonctionne comme avant.
  final FranceTravailClient? franceTravail;

  @override
  State<ReceiveShareScreen> createState() => _ReceiveShareScreenState();
}

class _ReceiveShareScreenState extends State<ReceiveShareScreen> {
  late final _title = TextEditingController(text: widget.shared.title ?? '');
  late final _company =
      TextEditingController(text: widget.shared.company ?? '');
  late final _location = TextEditingController();
  bool _saving = false;

  /// Résolution en cours auprès de France Travail.
  bool _resolving = false;

  /// Ce que l'API a rendu, s'il y a eu résolution. Fournit une description bien
  /// plus riche que le texte partagé, qui n'est souvent qu'une URL.
  NormalizedOffer? _resolved;

  @override
  void initState() {
    super.initState();
    _resolveIfPossible();
  }

  /// Les applications officielles ne partagent qu'une URL nue. Quand cette URL
  /// est une offre France Travail et que les identifiants sont là, on remplit
  /// les champs au lieu de tout faire retaper.
  ///
  /// Silencieux en cas d'échec : c'est un confort, pas une étape obligatoire.
  Future<void> _resolveIfPossible() async {
    final client = widget.franceTravail;
    final id = franceTravailOfferId(widget.shared.url);
    if (client == null || id == null) return;
    if (!await client.isConfigured) return;

    if (mounted) setState(() => _resolving = true);
    NormalizedOffer? offer;
    try {
      offer = await client.offerById(id);
    } on FranceTravailUnavailable {
      offer = null;
    }
    if (!mounted) return;

    setState(() {
      _resolving = false;
      _resolved = offer;
      if (offer != null) {
        // On ne remplace jamais ce que le parseur avait correctement extrait,
        // ni ce que l'utilisateur a déjà saisi.
        if (_title.text.trim().isEmpty) _title.text = offer.title;
        if (_company.text.trim().isEmpty) _company.text = offer.company;
        if (_location.text.trim().isEmpty) _location.text = offer.location;
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre du poste est nécessaire.')),
      );
      return;
    }

    setState(() => _saving = true);
    final result = await widget.repository.save(
      source: widget.shared.source,
      title: title,
      company: _company.text.trim().isEmpty ? null : _company.text.trim(),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      // La description résolue vaut infiniment mieux que le texte partagé,
      // qui n'est souvent qu'une URL. C'est elle que lira l'agent.
      description: (_resolved?.description.isNotEmpty ?? false)
          ? _resolved!.description
          : widget.shared.rawText,
      contractType: _resolved?.contractType,
      salary: _resolved?.salary,
      sourceId: _resolved?.sourceId,
      url: widget.shared.url,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    final message = switch (result.outcome) {
      SaveOutcome.saved => 'Offre enregistrée, score ${result.score}/100.',
      SaveOutcome.duplicate => 'Vous aviez déjà cette offre.',
      SaveOutcome.excluded => 'Offre écartée : elle tombe sous une exclusion.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final shared = widget.shared;
    return Scaffold(
      appBar: AppBar(title: const Text('Offre partagée')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_resolving)
            const Card(
              child: ListTile(
                leading: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text('Récupération de l\'offre chez France Travail…'),
              ),
            )
          else if (_resolved != null)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Offre récupérée chez France Travail. Les champs viennent de '
                  'l\'annonce officielle : vérifiez, puis enregistrez.',
                ),
              ),
            )
          else if (shared.needsReview)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Je n\'ai pas tout reconnu dans ce partage. Vérifiez les '
                  'champs ci-dessous, et complétez ce qui manque.',
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Intitulé du poste',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _company,
            decoration: const InputDecoration(
              labelText: 'Entreprise',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: const InputDecoration(
              labelText: 'Lieu (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (shared.url != null)
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(shared.url!, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('Source : ${shared.source}'),
              contentPadding: EdgeInsets.zero,
            ),
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('Texte partagé'),
            subtitle: const Text('Conservé tel quel, et transmis à l\'agent'),
            tilePadding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  shared.rawText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Enregistrer l\'offre'),
          ),
        ],
      ),
    );
  }
}
