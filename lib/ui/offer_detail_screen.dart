/// Détail d'une offre, et point d'accès aux documents de candidature.
///
/// « Générer la candidature » lance l'agent (étape 4) : jugement, grounding
/// INSEE, accroche ancrée sur un fait réel, personnalisation du CV. Le résultat
/// alimente les aperçus CV et lettre. Tant que l'agent n'a pas tourné, on rend
/// le CV maître et une lettre à accroche générique : rien n'est inventé.
///
/// Aucun envoi : l'application produit des PDF, l'utilisateur relit et envoie.
library;

import 'package:flutter/material.dart';

import '../agent/agent_config.dart';
import '../agent/agent_service.dart';
import '../agent/graph.dart';
import '../agent/models.dart';
import '../core/assets.dart';
import '../core/secrets.dart';
import '../data/database.dart';
import '../render/cv_document.dart';
import '../render/letter_document.dart';
import '../render/letter_template.dart';
import '../render/pdf_theme.dart';
import 'document_preview_screen.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.secrets,
    this.assets = const AppAssets(),
  });

  final Offer offer;
  final Secrets secrets;
  final AppAssets assets;

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  late final AgentService _agent =
      AgentService(secrets: widget.secrets, assets: widget.assets);

  bool _busy = false;
  AgentRun? _run;
  int _usedToday = 0;

  @override
  void initState() {
    super.initState();
    _agent.usedToday().then((n) {
      if (mounted) setState(() => _usedToday = n);
    });
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final run = await _agent.generate(AgentOffer(
        title: widget.offer.title,
        company: widget.offer.company ?? '',
        location: widget.offer.location ?? '',
        description: widget.offer.description ?? '',
        url: widget.offer.url ?? '',
      ));
      final used = await _agent.usedToday();
      if (!mounted) return;
      setState(() {
        _run = run;
        _usedToday = used;
      });
      if (run.error != null) {
        _snack('Généré, mais un appel a échoué : ${run.error}');
      }
    } on AgentUnavailable catch (e) {
      _snack(e.reason);
    } catch (e) {
      _snack('L\'agent a échoué : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _previewCv() async {
    await _guarded(() async {
      final theme = await loadPdfTheme();
      final data = await loadCvData(widget.assets);
      final doc = buildCvDocument(data,
          theme: theme, perso: _run?.output.personnalisationCv);
      if (!mounted) return;
      await _open('Aperçu du CV', doc, 'CV_${_slug(data.profile['name'])}');
    });
  }

  Future<void> _previewLetter() async {
    await _guarded(() async {
      final theme = await loadPdfTheme();
      final profile = await widget.assets.profile();
      // Avec l'agent : le template et l'accroche qu'il a produits. Sans lui :
      // le template par défaut et une accroche marquée « à générer ».
      final out = _run?.output;
      final template = LetterTemplate.fromSlug(out?.lettre.template ?? '') ??
          LetterTemplate.iaJunior;
      final accroche = (out?.lettre.accroche.isNotEmpty ?? false)
          ? out!.lettre.accroche
          : '[Accroche personnalisée : lancez « Générer la candidature » pour '
              'l\'ancrer sur un fait vérifiable de l\'entreprise.]';
      final md = await widget.assets.letter(template);
      final letter = fillTemplate(
        md,
        accroche: accroche,
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
      await _open('Aperçu de la lettre', doc, 'Lettre_${_slug(profile['name'])}');
    });
  }

  Future<void> _open(String title, doc, String file) => Navigator.of(context)
      .push(MaterialPageRoute(
          builder: (_) =>
              DocumentPreviewScreen(title: title, document: doc, fileName: file)));

  Future<void> _guarded(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _snack('Impossible de générer le PDF : $e');
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
    final run = _run;
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

          // Générer la candidature (l'agent).
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_outlined),
            label: Text(run == null
                ? 'Générer la candidature'
                : 'Regénérer la candidature'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Agent : $_usedToday/$kDefaultDailyCap appels aujourd\'hui',
                style: Theme.of(context).textTheme.bodySmall),
          ),

          if (run != null) _resultCard(run),

          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _previewCv,
            icon: const Icon(Icons.description_outlined),
            label: Text(run == null ? 'Aperçu du CV maître' : 'Aperçu du CV ciblé'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy ? null : _previewLetter,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Aperçu de la lettre'),
          ),

          const SizedBox(height: 20),
          Text(
            'Rien n\'est envoyé : vous relisez le CV et la lettre, puis vous '
            'partagez le PDF vous-même, depuis votre messagerie.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _resultCard(AgentRun run) {
    final out = run.output;
    final reco = switch (out.recommandation) {
      'postuler' => 'À postuler',
      'postuler_si_peu_options' => 'À postuler si peu d\'options',
      _ => 'Plutôt à éviter',
    };
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Score agent : ${out.score}/100',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Chip(
                label: Text(reco),
                visualDensity: VisualDensity.compact,
              ),
            ]),
            if (out.justificationScore.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(out.justificationScore,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 10),
            Text('Accroche', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(
              out.lettre.accroche.isEmpty
                  ? '(aucune accroche produite)'
                  : out.lettre.accroche,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(
                run.grounding.isEmpty
                    ? Icons.info_outline
                    : Icons.verified_outlined,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  run.grounding.isEmpty
                      ? 'Aucun fait officiel trouvé au registre : accroche non ancrée.'
                      : 'Accroche ancrée sur le registre officiel (INSEE).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
            if (out.missingSkills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('À anticiper : ${out.missingSkills.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
