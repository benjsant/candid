/// Détail d'une offre, et point d'accès aux documents de candidature.
///
/// À l'étape 3, on rend le CV maître et une lettre à accroche encore
/// générique : l'agent (étape 4) remplira l'accroche et personnalisera le CV.
/// Le bouton « Générer la candidature » qui déclenchera l'agent viendra se
/// greffer ici.
library;

import 'package:flutter/material.dart';

import '../core/assets.dart';
import '../data/database.dart';
import '../render/cv_document.dart';
import '../render/letter_document.dart';
import '../render/letter_template.dart';
import '../render/pdf_theme.dart';
import 'document_preview_screen.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({super.key, required this.offer, this.assets = const AppAssets()});

  final Offer offer;
  final AppAssets assets;

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  bool _busy = false;

  Future<void> _previewCv() async {
    await _guarded(() async {
      final theme = await loadPdfTheme();
      final data = await loadCvData(widget.assets);
      final doc = buildCvDocument(data, theme: theme);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
          title: 'Aperçu du CV',
          document: doc,
          fileName: 'CV_${_slug(data.profile['name'])}',
        ),
      ));
    });
  }

  Future<void> _previewLetter() async {
    await _guarded(() async {
      final theme = await loadPdfTheme();
      final profile = await widget.assets.profile();
      // Sans agent (étape 4), on assemble le template par défaut avec une
      // accroche marquée comme à générer : rien n'est inventé, l'utilisateur
      // voit clairement ce qui reste à personnaliser.
      final md = await widget.assets.letter(LetterTemplate.iaJunior);
      final letter = fillTemplate(
        md,
        accroche:
            '[Accroche personnalisée : générée à l\'étape suivante, à partir '
            'd\'un fait vérifiable sur l\'entreprise.]',
        vars: LetterVars(
          poste: widget.offer.title,
          company: widget.offer.company ?? '',
          nom: (profile['name'] ?? '').toString(),
          email: (profile['email'] ?? '').toString(),
        ),
      );
      final doc = buildLetterDocument(
        letter,
        senderName: (profile['name'] ?? '').toString(),
        senderEmail: (profile['email'] ?? '').toString(),
        senderLocation: (profile['residence'] ?? '').toString(),
        theme: theme,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
          title: 'Aperçu de la lettre',
          document: doc,
          fileName: 'Lettre_${_slug(profile['name'])}',
        ),
      ));
    });
  }

  Future<void> _guarded(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de générer le PDF : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _slug(Object? name) =>
      (name ?? 'candidat').toString().replaceAll(RegExp(r'\s+'), '_');

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    final subtitle = [o.company, o.location, o.source]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');
    return Scaffold(
      appBar: AppBar(title: const Text('Offre')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: (o.score ?? 0) >= 75
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text('${o.score ?? 0}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _previewCv,
            icon: const Icon(Icons.description_outlined),
            label: const Text('Aperçu du CV'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy ? null : _previewLetter,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Aperçu de la lettre'),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 20),
          Text('Candidature',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Le CV maître et la lettre sont prêts. La personnalisation par '
            'l\'agent (accroche fondée sur un fait réel, mise en avant ciblée) '
            'arrive à l\'étape suivante. Rien n\'est envoyé : vous relisez, puis '
            'vous partagez le PDF vous-même.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (o.description != null && o.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Texte de l\'offre',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(o.description!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
