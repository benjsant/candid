/// Aperçu d'un document PDF, avec partage et impression.
///
/// S'appuie sur `printing` (Dart pur, pas de navigateur embarqué). La barre
/// d'actions offre le partage du fichier (mail, etc.) : c'est le point final du
/// produit côté application. L'envoi reste manuel, fait par l'utilisateur.
library;

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DocumentPreviewScreen extends StatelessWidget {
  const DocumentPreviewScreen({
    super.key,
    required this.title,
    required this.document,
    required this.fileName,
  });

  final String title;
  final pw.Document document;

  /// Nom du fichier proposé au partage (sans extension).
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => document.save(),
        pdfFileName: '$fileName.pdf',
        canDebug: false,
        // Le partage est l'action principale ; on garde l'impression, on retire
        // le bouton « page format » qui n'a pas de sens ici (A4 figé).
        canChangePageFormat: false,
        canChangeOrientation: false,
      ),
    );
  }
}
