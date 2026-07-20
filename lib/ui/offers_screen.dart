/// Liste des offres reçues, les mieux notées d'abord.
library;

import 'package:flutter/material.dart';

import '../core/secrets.dart';
import '../data/database.dart';
import '../data/offers_repository.dart';
import 'offer_detail_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key, required this.repository, required this.secrets});

  final OffersRepository repository;
  final Secrets secrets;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Offer>>(
      stream: repository.watchInbox(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final offers = snapshot.data!;
        if (offers.isEmpty) {
          return const _Empty();
        }
        return ListView.separated(
          itemCount: offers.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) => _OfferTile(
            offer: offers[i],
            onIgnore: () =>
                repository.setStatus(offers[i].id, OfferStatus.ignored),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => OfferDetailScreen(offer: offers[i], secrets: secrets),
            )),
          ),
        );
      },
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.offer,
    required this.onIgnore,
    required this.onTap,
  });

  final Offer offer;
  final VoidCallback onIgnore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final score = offer.score ?? 0;
    return Dismissible(
      key: ValueKey(offer.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.visibility_off_outlined),
      ),
      onDismissed: (_) => onIgnore(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: score >= 75
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text('$score'),
        ),
        title: Text(offer.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [offer.company, offer.location, offer.source]
              .where((s) => s != null && s.isNotEmpty)
              .join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
            const Icon(Icons.ios_share, size: 48),
            const SizedBox(height: 16),
            Text('Aucune offre pour l\'instant',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Depuis LinkedIn, Indeed ou votre navigateur : appuyez sur '
              '« Partager », puis choisissez Candid.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
