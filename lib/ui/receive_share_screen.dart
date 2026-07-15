/// Écran de réception d'une offre partagée.
///
/// Le parseur propose, l'utilisateur dispose. Rien n'est enregistré sans qu'il
/// ait vu ce qu'on a compris du texte partagé : c'est la même règle que pour
/// l'agent, on n'invente pas en silence.
library;

import 'package:flutter/material.dart';

import '../data/offers_repository.dart';
import '../sources/shared_text.dart';

class ReceiveShareScreen extends StatefulWidget {
  const ReceiveShareScreen({
    super.key,
    required this.shared,
    required this.repository,
  });

  final SharedOffer shared;
  final OffersRepository repository;

  @override
  State<ReceiveShareScreen> createState() => _ReceiveShareScreenState();
}

class _ReceiveShareScreenState extends State<ReceiveShareScreen> {
  late final _title = TextEditingController(text: widget.shared.title ?? '');
  late final _company =
      TextEditingController(text: widget.shared.company ?? '');
  late final _location = TextEditingController();
  bool _saving = false;

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
      description: widget.shared.rawText,
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
          if (shared.needsReview)
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
