/// Écran de suivi des candidatures (étape 5).
///
/// Le cycle complet, du partage de l'offre à « envoyée », tient ici : chaque
/// candidature porte son statut, ses dates, une note et une relance. L'envoi
/// reste manuel : marquer « Envoyée » ne fait que dater, ça n'envoie rien.
library;

import 'package:flutter/material.dart';

import '../data/applications_repository.dart';
import '../data/database.dart';

/// Libellés et couleurs des statuts.
const _statusLabels = {
  ApplicationStatus.draft: 'Brouillon',
  ApplicationStatus.sent: 'Envoyée',
  ApplicationStatus.interview: 'Entretien',
  ApplicationStatus.rejected: 'Refusée',
  ApplicationStatus.accepted: 'Acceptée',
};

String _fmtDate(DateTime? d) =>
    d == null ? '' : '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.repository});

  final ApplicationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Application>>(
      stream: repository.watchAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final apps = snapshot.data!;
        if (apps.isEmpty) return const _Empty();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: apps.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, i) =>
              _ApplicationCard(app: apps[i], repository: repository),
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.app, required this.repository});

  final Application app;
  final ApplicationsRepository repository;

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (app.status) {
      ApplicationStatus.accepted => scheme.primary,
      ApplicationStatus.interview => scheme.tertiary,
      ApplicationStatus.rejected => scheme.error,
      ApplicationStatus.sent => scheme.secondary,
      _ => scheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dates = <String>[
      if (app.appliedAt != null) 'Envoyée le ${_fmtDate(app.appliedAt)}',
      if (app.responseAt != null) 'Réponse le ${_fmtDate(app.responseAt)}',
      if (app.remindedAt != null) 'Relance le ${_fmtDate(app.remindedAt)}',
    ];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.poste ?? '(poste inconnu)',
                          style: Theme.of(context).textTheme.titleSmall),
                      if ((app.entreprise ?? '').isNotEmpty)
                        Text(app.entreprise!,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                _menu(context),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              _StatusChip(
                label: _statusLabels[app.status] ?? app.status,
                color: _statusColor(context),
              ),
              const Spacer(),
              _StatusDropdown(
                value: app.status,
                onChanged: (s) => repository.setStatus(app.id, s),
              ),
            ]),
            if (dates.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(dates.join('  ·  '),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            if ((app.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(app.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) => switch (v) {
        'note' => _editNote(context),
        'reminder' => _pickReminder(context),
        'delete' => _confirmDelete(context),
        _ => null,
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'note', child: Text('Note')),
        PopupMenuItem(value: 'reminder', child: Text('Relance')),
        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
      ],
    );
  }

  Future<void> _editNote(BuildContext context) async {
    final controller = TextEditingController(text: app.notes ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Relancer, contact, points à préparer...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (result != null) await repository.setNotes(app.id, result.trim());
  }

  Future<void> _pickReminder(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: app.remindedAt ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) await repository.setReminder(app.id, date);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette candidature ?'),
        content: const Text('Le suivi sera perdu. L\'offre, elle, reste.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok ?? false) await repository.delete(app.id);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      isDense: true,
      borderRadius: BorderRadius.circular(12),
      items: [
        for (final s in ApplicationStatus.all)
          DropdownMenuItem(value: s, child: Text(_statusLabels[s] ?? s)),
      ],
      onChanged: (s) {
        if (s != null && s != value) onChanged(s);
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timeline_outlined, size: 48),
            const SizedBox(height: 16),
            Text('Aucune candidature suivie',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Ouvrez une offre, puis « Suivre cette candidature » pour la '
              'retrouver ici et gérer son statut.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
