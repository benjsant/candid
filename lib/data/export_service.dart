/// Export de la base : un instantané JSON des offres et des candidatures,
/// partagé via la feuille de partage Android (mail, Drive, etc.).
///
/// Pourquoi : contrairement au PostgreSQL du projet Docker, tout l'historique
/// vit sur un téléphone qui peut se perdre. Un export lisible et portable
/// protège des mois de suivi, et reste ré-importable plus tard.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'database.dart';

class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  /// Construit l'instantané complet (offres + candidatures) avec un en-tête.
  Future<Map<String, dynamic>> snapshot() async {
    final offers = await _db.select(_db.offers).get();
    final applications = await _db.select(_db.applications).get();
    return {
      'app': 'candid',
      'schema_version': _db.schemaVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'offers': offers.map((o) => o.toJson()).toList(),
      'applications': applications.map((a) => a.toJson()).toList(),
    };
  }

  /// Écrit l'export dans un fichier temporaire et ouvre le partage.
  ///
  /// Le fichier est **effacé après le partage**. Il contient tout l'historique
  /// de candidatures ; le laisser traîner dans le cache le rendrait lisible par
  /// une sauvegarde future ou par quiconque obtiendrait un accès au dossier de
  /// l'application. La copie qui compte est celle que l'utilisateur a envoyée
  /// vers Drive ou sa messagerie.
  Future<void> shareExport() async {
    final json = const JsonEncoder.withIndent('  ').convert(await snapshot());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/candid-export-${_stamp()}.json');
    await file.writeAsString(json);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Export Candid',
          text: 'Sauvegarde de vos offres et candidatures Candid.',
        ),
      );
    } finally {
      await _cleanUp(dir, file);
    }
  }

  /// Efface l'export qui vient d'être partagé, et les exports d'anciennes
  /// versions restés dans le cache.
  Future<void> _cleanUp(Directory dir, File current) async {
    try {
      if (await current.exists()) await current.delete();
      await for (final entry in dir.list()) {
        if (entry is File && entry.path.contains('candid-export-')) {
          await entry.delete();
        }
      }
    } catch (_) {
      // Le nettoyage est un confort de sécurité, pas une opération critique :
      // il ne doit jamais faire échouer un export qui a réussi.
    }
  }

  static String _stamp() {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}';
  }
}
