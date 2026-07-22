/// Écran de réglages : saisie des clés API, stockées dans le Keystore Android.
///
/// C'est le seul endroit où une clé est saisie. Elles ne transitent jamais par
/// un fichier du dépôt.
library;

import 'package:flutter/material.dart';

import '../agent/agent_config.dart';
import '../agent/llm.dart';
import '../../background/collect_task.dart';
import '../core/app_prefs.dart';
import '../core/notifications.dart';
import '../core/secrets.dart';
import '../data/database.dart';
import '../data/profile_repository.dart';
import 'search_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.secrets,
    required this.prefs,
    required this.themeMode,
    required this.profiles,
    this.agentConfig,
  });

  final Secrets secrets;
  final AppPrefs prefs;
  final ValueNotifier<ThemeMode> themeMode;
  final ProfileRepository profiles;
  final AgentConfig? agentConfig;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AgentConfig _agentConfig = widget.agentConfig ?? AgentConfig();

  final Map<SecretKey, TextEditingController> _controllers = {
    for (final key in SecretKey.values) key: TextEditingController(),
  };
  final _modelController = TextEditingController();

  /// On ne réaffiche jamais une clé enregistrée en clair : on indique seulement
  /// qu'elle est là. Le champ reste vide, et le rester ne l'efface pas.
  final Set<SecretKey> _stored = {};

  LlmProvider _provider = LlmProvider.deepseek;
  bool _loading = true;

  /// Collecte quotidienne en arrière-plan.
  bool _dailyCollect = false;

  /// Digest hebdomadaire de la recherche.
  bool _weeklyDigest = false;

  /// Permission de notifier (Android 13+). Sans elle, la collecte tournerait
  /// mais resterait muette : autant le dire plutôt que de laisser croire.
  bool _notificationsAllowed = true;

  final _notifications = Notifications();

  Future<void> _setWeeklyDigest(bool enabled) async {
    if (enabled) {
      await _notifications.init();
      if (!await _notifications.isAllowed) {
        await _notifications.requestPermission();
      }
    }
    await widget.prefs.setWeeklyDigest(enabled);
    await syncWeeklyDigest(enabled);
    if (!mounted) return;
    setState(() => _weeklyDigest = enabled);
  }

  Future<void> _setDailyCollect(bool enabled) async {
    if (enabled) {
      // On demande la permission au moment où elle sert, pas au lancement.
      await _notifications.init();
      if (!await _notifications.isAllowed) {
        await _notifications.requestPermission();
      }
    }
    await widget.prefs.setDailyCollect(enabled);
    await syncDailyCollect(enabled);
    if (!mounted) return;
    setState(() => _dailyCollect = enabled);
    _notificationsAllowed = await _notifications.isAllowed;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (final key in SecretKey.values) {
      if (await widget.secrets.has(key)) _stored.add(key);
    }
    _provider = await _agentConfig.provider();
    _modelController.text = await _agentConfig.model();
    _dailyCollect = await widget.prefs.dailyCollect();
    _weeklyDigest = await widget.prefs.weeklyDigest();
    await _notifications.init();
    _notificationsAllowed = await _notifications.isAllowed;
    if (mounted) setState(() => _loading = false);
  }

  /// Change le thème tout de suite (aperçu immédiat) et le persiste.
  Future<void> _setThemeMode(ThemeMode mode) async {
    widget.themeMode.value = mode;
    await widget.prefs.setThemeMode(mode);
    if (mounted) setState(() {});
  }

  static const _themeLabels = {
    ThemeMode.system: 'Système',
    ThemeMode.light: 'Clair',
    ThemeMode.dark: 'Sombre',
  };

  Future<void> _save() async {
    var changed = 0;
    for (final entry in _controllers.entries) {
      final typed = entry.value.text.trim();
      if (typed.isEmpty) continue; // champ laissé vide : on ne touche à rien
      await widget.secrets.write(entry.key, typed);
      _stored.add(entry.key);
      entry.value.clear();
      changed++;
    }
    await _agentConfig.setProvider(_provider);
    await _agentConfig.setModel(_modelController.text);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed == 0 ? 'Réglages enregistrés.' : '$changed clé(s) enregistrée(s).',
        ),
      ),
    );
  }

  Future<void> _delete(SecretKey key) async {
    await widget.secrets.delete(key);
    _stored.remove(key);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Vos clés restent sur cet appareil, dans le coffre-fort Android. '
              'Elles ne sont ni envoyées ailleurs, ni écrites dans le code.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Profil de recherche : ce qui borne la collecte. Placé en premier
        // parce que sans lui, la collecte remonte toute la France.
        Text('Recherche', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        StreamBuilder<SearchProfile?>(
          stream: widget.profiles.watchActive(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final communes = ProfileCommunes.parse(
                profile?.locationLabel, profile?.locationInsee);
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Profil de recherche'),
                subtitle: Text(
                  communes.isEmpty
                      ? 'Aucune commune : la collecte ratisse toute la France.'
                      : '${communes.labels.join(', ')} · '
                          '${profile?.radiusKm ?? 30} km',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SearchProfileScreen(repository: widget.profiles),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.schedule),
                title: const Text('Collecte quotidienne'),
                subtitle: Text(
                  _dailyCollect
                      ? 'Une fois par jour, en arrière-plan, avec une '
                          'notification s\'il y a du nouveau.'
                      : 'Désactivée. Le bouton de l\'onglet Offres reste '
                          'disponible à tout moment.',
                ),
                value: _dailyCollect,
                onChanged: _setDailyCollect,
              ),
              if (_dailyCollect && !_notificationsAllowed)
                ListTile(
                  leading: Icon(Icons.notifications_off_outlined,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text('Notifications refusées'),
                  subtitle: const Text(
                    'La collecte tournera, mais sans vous prévenir. '
                    'Autorisez-les dans les réglages Android.',
                  ),
                ),
              if (_dailyCollect)
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Tester maintenant'),
                  subtitle: const Text(
                    'Lance une collecte en arrière-plan tout de suite, pour '
                    'voir si votre téléphone la laisse passer.',
                  ),
                  onTap: () async {
                    await runCollectOnceInBackground();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Collecte de fond demandée. La notification arrive '
                          'd\'ici une minute si tout va bien.',
                        ),
                      ),
                    );
                  },
                ),
              SwitchListTile(
                secondary: const Icon(Icons.calendar_month_outlined),
                title: const Text('Digest hebdomadaire'),
                subtitle: Text(
                  _weeklyDigest
                      ? 'Une fois par semaine : ce que vous avez collecté, '
                          'envoyé, et les relances à faire.'
                      : 'Désactivé. Le point hebdomadaire sur votre recherche.',
                ),
                value: _weeklyDigest,
                onChanged: _setWeeklyDigest,
              ),
              if (_dailyCollect)
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Selon votre téléphone, ça peut ne pas partir'),
                  subtitle: Text(
                    'Beaucoup de constructeurs (Oppo, Xiaomi, Samsung) tuent '
                    'les tâches de fond. Si rien n\'arrive, retirez Candid des '
                    'optimisations de batterie, ou collectez à la main.',
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 32),

        // Apparence.
        Text('Apparence', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<ThemeMode>(
          initialValue: widget.themeMode.value,
          decoration: const InputDecoration(
            labelText: 'Thème',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final e in _themeLabels.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (m) {
            if (m != null) _setThemeMode(m);
          },
        ),

        const Divider(height: 32),

        // Fournisseur IA actif.
        Text('Fournisseur de l\'agent',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'DeepSeek par défaut. OpenRouter propose un mode gratuit et '
          'respectueux des données. Gemini est à réserver au non-sensible.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<LlmProvider>(
          initialValue: _provider,
          decoration: const InputDecoration(
            labelText: 'Fournisseur',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final p in LlmProvider.values)
              DropdownMenuItem(value: p, child: Text(p.label)),
          ],
          onChanged: (p) {
            if (p != null) setState(() => _provider = p);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _modelController,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Modèle (facultatif)',
            border: const OutlineInputBorder(),
            hintText: 'Défaut : ${_provider.defaultModel}',
            helperText: 'Laisser vide pour le modèle par défaut du fournisseur.',
          ),
        ),

        const Divider(height: 32),

        // Clés API.
        Text('Clés API', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final key in SecretKey.values) _field(key),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _field(SecretKey key) {
    final stored = _stored.contains(key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controllers[key],
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: key.label,
              border: const OutlineInputBorder(),
              helperText: stored ? null : key.consequence,
              helperMaxLines: 3,
              hintText: stored ? 'Enregistrée. Saisir pour remplacer.' : null,
              suffixIcon: stored
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Supprimer cette clé',
                      onPressed: () => _delete(key),
                    )
                  : null,
            ),
          ),
          if (stored)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16),
                  SizedBox(width: 6),
                  Text('Enregistrée sur cet appareil'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
