/// Écran de réglages : saisie des clés API, stockées dans le Keystore Android.
///
/// C'est le seul endroit où une clé est saisie. Elles ne transitent jamais par
/// un fichier du dépôt.
library;

import 'package:flutter/material.dart';

import '../agent/agent_config.dart';
import '../agent/llm.dart';
import '../core/app_prefs.dart';
import '../core/secrets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.secrets,
    required this.prefs,
    required this.themeMode,
    this.agentConfig,
  });

  final Secrets secrets;
  final AppPrefs prefs;
  final ValueNotifier<ThemeMode> themeMode;
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
