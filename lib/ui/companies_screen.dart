/// Les entreprises à démarcher en candidature spontanée.
///
/// L'écran répète en toutes lettres ce que ces fiches sont, et ce qu'elles ne
/// sont pas : **aucune offre n'est publiée**. C'est le même contrat que partout
/// ailleurs dans Candid : on ne laisse pas croire qu'il y a un poste ouvert.
///
/// Et comme partout, rien n'est envoyé : les boutons ouvrent le composeur mail
/// ou le téléphone, l'utilisateur écrit et envoie lui-même.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/companies_repository.dart';
import '../data/database.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key, required this.repository});

  final CompaniesRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Company>>(
      stream: repository.watchAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final companies = snapshot.data!;
        if (companies.isEmpty) return const _Empty();

        return ListView.separated(
          itemCount: companies.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            if (i == 0) return const _Explainer();
            final c = companies[i - 1];
            return _CompanyTile(
              company: c,
              onDelete: () => repository.delete(c.id),
            );
          },
        );
      },
    );
  }
}

class _Explainer extends StatelessWidget {
  const _Explainer();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Ces entreprises embauchent dans votre domaine, mais n\'ont publié '
          'aucune offre. Il n\'y a donc pas de poste à consulter : c\'est à '
          'vous de les contacter.',
        ),
      ),
    );
  }
}

class _CompanyTile extends StatelessWidget {
  const _CompanyTile({required this.company, required this.onDelete});

  final Company company;
  final VoidCallback onDelete;

  Future<void> _open(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune application pour ouvrir ce lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = [
      if (company.sector != null) company.sector!,
      if (company.location != null) company.location!,
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(company.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.isNotEmpty) Text(details),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (company.email != null)
                ActionChip(
                  avatar: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Écrire'),
                  onPressed: () => _open(
                    context,
                    Uri(scheme: 'mailto', path: company.email),
                  ),
                ),
              if (company.phone != null)
                ActionChip(
                  avatar: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Appeler'),
                  onPressed: () => _open(
                    context,
                    Uri(scheme: 'tel', path: company.phone),
                  ),
                ),
              if (company.applyUrl != null || company.website != null)
                ActionChip(
                  avatar: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Voir'),
                  onPressed: () => _open(
                    context,
                    Uri.parse(company.applyUrl ?? company.website!),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Retirer de la liste',
        onPressed: onDelete,
      ),
      isThreeLine: true,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.domain_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Aucune entreprise pour l\'instant',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'La Bonne Alternance signale les entreprises qui embauchent sans '
              'publier d\'offre. Lancez une collecte pour les voir apparaître.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
