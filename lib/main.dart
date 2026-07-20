/// Candid : l'assistant de candidature qui ne brode jamais.
///
/// Étapes couvertes (voir TASKS.md) :
///  - 1 : base locale, coffre-fort des clés, réglages ;
///  - 2 : cible de partage, normalisation, hash, scoring local ;
///  - 3 : rendu PDF du CV et de la lettre (aperçu, partage) ;
///  - 4 : l'agent (jugement, grounding INSEE, accroche, personnalisation CV).
/// Le suivi (5) et la collecte automatique (6) viennent ensuite.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'core/secrets.dart';
import 'data/database.dart';
import 'data/offers_repository.dart';
import 'sources/shared_text.dart';
import 'ui/offers_screen.dart';
import 'ui/receive_share_screen.dart';
import 'ui/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(
    CandidApp(
      repository: OffersRepository(db),
      secrets: Secrets(),
    ),
  );
}

class CandidApp extends StatelessWidget {
  const CandidApp({
    super.key,
    required this.repository,
    required this.secrets,
  });

  final OffersRepository repository;
  final Secrets secrets;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F4E));
    return MaterialApp(
      title: 'Candid',
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F4E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(repository: repository, secrets: secrets),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.secrets,
  });

  final OffersRepository repository;
  final Secrets secrets;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  // Construits UNE fois : avec un IndexedStack, chaque onglet garde son état
  // (l'écran Réglages ne relit pas le secure storage à chaque bascule).
  late final List<Widget> _pages = [
    OffersScreen(repository: widget.repository, secrets: widget.secrets),
    const _Placeholder(
      icon: Icons.timeline_outlined,
      title: 'Suivi',
      detail: 'Vos candidatures et leurs réponses (étape 5).',
    ),
    SettingsScreen(secrets: widget.secrets),
  ];

  @override
  void initState() {
    super.initState();
    // Deux cas à couvrir : l'application était fermée quand on a partagé
    // (getInitialMedia), ou elle tournait déjà en fond (getMediaStream).
    ReceiveSharingIntent.instance.getInitialMedia().then((media) {
      _handleShare(media);
      ReceiveSharingIntent.instance.reset();
    });
    _shareSub =
        ReceiveSharingIntent.instance.getMediaStream().listen(_handleShare);
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  void _handleShare(List<SharedMediaFile> media) {
    // Une offre est du texte ou un lien. Le reste (image, vidéo) ne nous
    // concerne pas : on l'ignore plutôt que d'échouer bruyamment.
    final text = media
        .where((m) =>
            m.type == SharedMediaType.text || m.type == SharedMediaType.url)
        .map((m) => m.path)
        .join('\n')
        .trim();
    if (text.isEmpty || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiveShareScreen(
          shared: parseSharedText(text),
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(['Offres', 'Suivi', 'Réglages'][_tab])),
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Offres',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Suivi',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
