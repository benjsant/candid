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

import 'core/app_prefs.dart';
import 'core/secrets.dart';
import 'data/applications_repository.dart';
import 'data/database.dart';
import 'data/export_service.dart';
import 'data/offers_repository.dart';
import 'sources/shared_text.dart';
import 'ui/offers_screen.dart';
import 'ui/receive_share_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/tracking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final prefs = AppPrefs();
  // Charge le thème choisi avant le premier rendu, pour éviter un flash.
  final themeMode = ValueNotifier<ThemeMode>(await prefs.themeMode());
  runApp(
    CandidApp(
      repository: OffersRepository(db),
      applications: ApplicationsRepository(db),
      export: ExportService(db),
      secrets: Secrets(),
      prefs: prefs,
      themeMode: themeMode,
    ),
  );
}

class CandidApp extends StatelessWidget {
  const CandidApp({
    super.key,
    required this.repository,
    required this.applications,
    required this.export,
    required this.secrets,
    required this.prefs,
    required this.themeMode,
  });

  final OffersRepository repository;
  final ApplicationsRepository applications;
  final ExportService export;
  final Secrets secrets;
  final AppPrefs prefs;
  final ValueNotifier<ThemeMode> themeMode;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F6F4E);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Candid',
        themeMode: mode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: HomeScreen(
          repository: repository,
          applications: applications,
          export: export,
          secrets: secrets,
          prefs: prefs,
          themeMode: themeMode,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.applications,
    required this.export,
    required this.secrets,
    required this.prefs,
    required this.themeMode,
  });

  final OffersRepository repository;
  final ApplicationsRepository applications;
  final ExportService export;
  final Secrets secrets;
  final AppPrefs prefs;
  final ValueNotifier<ThemeMode> themeMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  // Construits UNE fois : avec un IndexedStack, chaque onglet garde son état
  // (l'écran Réglages ne relit pas le secure storage à chaque bascule).
  late final List<Widget> _pages = [
    OffersScreen(
      repository: widget.repository,
      applications: widget.applications,
      secrets: widget.secrets,
    ),
    TrackingScreen(repository: widget.applications),
    SettingsScreen(
      secrets: widget.secrets,
      prefs: widget.prefs,
      themeMode: widget.themeMode,
    ),
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

  Future<void> _export() async {
    try {
      await widget.export.shareExport();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export impossible : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['Offres', 'Suivi', 'Réglages'][_tab]),
        actions: [
          // Export sur l'onglet Suivi : sauvegarder offres + candidatures.
          if (_tab == 1)
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Exporter mes données',
              onPressed: _export,
            ),
        ],
      ),
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
