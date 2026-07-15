/// Candid : l'assistant de candidature qui ne brode jamais.
///
/// Étape 1 (socle) : base locale, coffre-fort des clés, écran de réglages.
/// Les écrans d'offres et de suivi arrivent aux étapes suivantes (voir TASKS.md).
library;

import 'package:flutter/material.dart';

import 'core/secrets.dart';
import 'data/database.dart';
import 'ui/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CandidApp(database: AppDatabase(), secrets: Secrets()));
}

class CandidApp extends StatelessWidget {
  const CandidApp({super.key, required this.database, required this.secrets});

  final AppDatabase database;
  final Secrets secrets;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F4E)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F4E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(database: database, secrets: secrets),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.database, required this.secrets});

  final AppDatabase database;
  final Secrets secrets;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _Placeholder(
        icon: Icons.inbox_outlined,
        title: 'Offres',
        detail:
            'Partagez une offre depuis LinkedIn, Indeed ou votre navigateur : '
            'elle arrivera ici (étape 2).',
      ),
      const _Placeholder(
        icon: Icons.timeline_outlined,
        title: 'Suivi',
        detail: 'Vos candidatures et leurs réponses (étape 5).',
      ),
      SettingsScreen(secrets: widget.secrets),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(['Offres', 'Suivi', 'Réglages'][_tab])),
      body: pages[_tab],
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
