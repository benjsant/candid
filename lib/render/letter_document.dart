/// Mise en page PDF d'une lettre de motivation.
///
/// Prend une lettre déjà assemblée (`letter_template.dart` : objet + corps figé,
/// accroche insérée) et le profil candidat, et produit le PDF : bloc expéditeur,
/// date, objet, corps, signature. La mise en page régénère l'expéditeur et la
/// signature depuis le profil (le bloc signature du template a été retiré à
/// l'assemblage), exactement comme `reference/letter-template.mjs` le prévoit.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'letter_template.dart';

class _C {
  static final ink = PdfColor.fromHex('111827');
  static final muted = PdfColor.fromHex('374151');
}

/// Nom des mois pour la date en toutes lettres (pas de format ambigu).
const _mois = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String _dateFr(DateTime d) => '${d.day} ${_mois[d.month - 1]} ${d.year}';

/// Construit le document PDF de la lettre.
///
/// [senderName], [senderEmail], [senderLocation] viennent du profil candidat.
/// [date] par défaut aujourd'hui.
pw.Document buildLetterDocument(
  AssembledLetter letter, {
  required String senderName,
  String senderEmail = '',
  String senderPhone = '',
  String senderLocation = '',
  DateTime? date,
  pw.ThemeData? theme,
}) {
  final doc = pw.Document(theme: theme);
  final when = date ?? DateTime.now();

  final contactBits = [
    if (senderEmail.isNotEmpty) senderEmail,
    if (senderPhone.isNotEmpty) senderPhone,
  ].join('  ·  ');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(
          horizontal: 22 * PdfPageFormat.mm / 10, vertical: 20 * PdfPageFormat.mm / 10),
      build: (context) => [
        // Expéditeur.
        pw.Text(senderName,
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: _C.ink)),
        if (contactBits.isNotEmpty)
          pw.Text(contactBits, style: pw.TextStyle(fontSize: 10, color: _C.muted)),
        if (senderLocation.isNotEmpty)
          pw.Text(senderLocation,
              style: pw.TextStyle(fontSize: 10, color: _C.muted)),

        pw.SizedBox(height: 18),

        // Lieu et date, alignés à droite.
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            senderLocation.isNotEmpty
                ? 'Le ${_dateFr(when)}'
                : 'Le ${_dateFr(when)}',
            style: pw.TextStyle(fontSize: 10.5, color: _C.muted),
          ),
        ),

        pw.SizedBox(height: 18),

        // Objet.
        if (letter.subject.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 14),
            child: pw.Text('Objet : ${letter.subject}',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold, color: _C.ink)),
          ),

        // Corps figé : paragraphes et puces.
        ..._body(letter.body),

        pw.SizedBox(height: 22),

        // Signature.
        pw.Text(senderName,
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold, color: _C.ink)),
      ],
    ),
  );

  return doc;
}

/// Rend le corps : chaque ligne « • … » devient une puce, le reste des
/// paragraphes justifiés. Les lignes vides séparent les paragraphes.
List<pw.Widget> _body(String body) {
  final widgets = <pw.Widget>[];
  for (final rawLine in body.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      continue;
    }
    if (line.startsWith('•')) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2, left: 10, bottom: 2),
        child: pw.Text(line,
            style: pw.TextStyle(fontSize: 10.5, color: _C.ink, lineSpacing: 1.5)),
      ));
    } else {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
        child: pw.Text(line,
            textAlign: pw.TextAlign.justify,
            style: pw.TextStyle(fontSize: 10.5, color: _C.ink, lineSpacing: 1.6)),
      ));
    }
  }
  return widgets;
}
