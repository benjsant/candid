/// Thème PDF partagé par le CV et la lettre.
///
/// Charge Liberation Sans (embarquée dans `assets/fonts/`) et en fait la police
/// par défaut des documents. Sans ça, la Helvetica intégrée du paquet `pdf`
/// affiche en tofu les glyphes « • », « œ » et les guillemets français, pourtant
/// bien présents dans les données (« mise en œuvre », puces d'expérience).
library;

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Charge le thème une fois ; à réutiliser pour tous les rendus d'une session.
Future<pw.ThemeData> loadPdfTheme() async {
  final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/LiberationSans-Regular.ttf'));
  final bold =
      pw.Font.ttf(await rootBundle.load('assets/fonts/LiberationSans-Bold.ttf'));
  final italic = pw.Font.ttf(
      await rootBundle.load('assets/fonts/LiberationSans-Italic.ttf'));
  return pw.ThemeData.withFont(
    base: regular,
    bold: bold,
    italic: italic,
  );
}
