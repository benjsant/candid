/// Écran de réglages : saisie des clés API, stockées dans le Keystore Android.
///
/// C'est le seul endroit où une clé est saisie. Elles ne transitent jamais par
/// un fichier du dépôt.
library;

import 'package:flutter/material.dart';

import '../core/secrets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.secrets});

  final Secrets secrets;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<SecretKey, TextEditingController> _controllers = {
    for (final key in SecretKey.values) key: TextEditingController(),
  };

  /// On ne réaffiche jamais une clé enregistrée en clair : on indique seulement
  /// qu'elle est là. Le champ reste vide, et le rester ne l'efface pas.
  final Set<SecretKey> _stored = {};

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
    if (mounted) setState(() => _loading = false);
  }

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
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed == 0 ? 'Rien à enregistrer.' : '$changed clé(s) enregistrée(s).',
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
