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
import 'package:workmanager/workmanager.dart';

import 'background/collect_task.dart';
import 'core/app_prefs.dart';
import 'core/secrets.dart';
import 'data/applications_repository.dart';
import 'data/database.dart';
import 'data/export_service.dart';
import 'data/offers_repository.dart';
import 'data/profile_repository.dart';
import 'sources/collect_service.dart';
import 'sources/france_travail.dart';
import 'sources/lba.dart';
import 'sources/shared_text.dart';
import 'ui/offers_screen.dart';
import 'ui/receive_share_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/tracking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final prefs = AppPrefs();
  final secrets = Secrets();
  final repository = OffersRepository(db);
  // Charge le thème choisi avant le premier rendu, pour éviter un flash.
  final themeMode = ValueNotifier<ThemeMode>(await prefs.themeMode());

  // L'isolat de fond doit être déclaré au démarrage, même si aucune tâche n'est
  // planifiée : sans ça, activer la collecte depuis les réglages ne suffirait
  // pas. Une erreur ici (émulateur, appareil bridé) ne doit pas empêcher
  // l'application de démarrer.
  try {
    await Workmanager().initialize(callbackDispatcher);
    await syncDailyCollect(await prefs.dailyCollect());
  } catch (_) {
    // La collecte manuelle reste disponible : on n'insiste pas.
  }
  runApp(
    CandidApp(
      repository: repository,
      applications: ApplicationsRepository(db),
      export: ExportService(db),
      profiles: ProfileRepository(db),
      collect: CollectService(
        db: db,
        repository: repository,
        franceTravail: FranceTravailClient(secrets: secrets),
        lba: LbaClient(secrets: secrets),
      ),
      secrets: secrets,
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
    required this.profiles,
    required this.collect,
    required this.secrets,
    required this.prefs,
    required this.themeMode,
  });

  final OffersRepository repository;
  final ApplicationsRepository applications;
  final ExportService export;
  final ProfileRepository profiles;
  final CollectService collect;
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
          profiles: profiles,
          collect: collect,
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
    required this.profiles,
    required this.collect,
    required this.secrets,
    required this.prefs,
    required this.themeMode,
  });

  final OffersRepository repository;
  final ApplicationsRepository applications;
  final ExportService export;
  final ProfileRepository profiles;
  final CollectService collect;
  final Secrets secrets;
  final AppPrefs prefs;
  final ValueNotifier<ThemeMode> themeMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  /// Partagé avec la collecte : le jeton mis en cache profite aux deux.
  late final FranceTravailClient _franceTravail =
      FranceTravailClient(secrets: widget.secrets);

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
      profiles: widget.profiles,
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
          franceTravail: _franceTravail,
        ),
      ),
    );
  }

  bool _collecting = false;

  Future<void> _collect() async {
    if (_collecting) return;
    setState(() => _collecting = true);
    try {
      final report = await widget.collect.collect();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(report.summary)));
      }
    } catch (e) {
      // Sans ce catch, une erreur inattendue ne produirait AUCUN message :
      // l'utilisateur verrait le bouton s'arrêter de tourner sans savoir si la
      // collecte a marché. Une panne doit se voir.
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Collecte impossible : $e')));
      }
    } finally {
      // Le bouton doit toujours se réarmer, même si une source a échoué de
      // façon inattendue : sinon la collecte reste bloquée jusqu'au relancement.
      if (mounted) setState(() => _collecting = false);
    }
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
          // Collecte manuelle sur l'onglet Offres. Elle reste déclenchée à la
          // main : la version périodique (workmanager) vient ensuite, et n'est
          // de toute façon pas fiable sur toutes les surcouches constructeur.
          if (_tab == 0)
            _collecting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cloud_download_outlined),
                    tooltip: 'Collecter les offres',
                    onPressed: _collect,
                  ),
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
