/// Thème PDF partagé par le CV et la lettre.
///
/// Charge Liberation Sans (embarquée dans `assets/fonts/`) et en fait la police
/// par défaut des documents. Sans ça, la Helvetica intégrée du paquet `pdf`
/// affiche en tofu les glyphes « • », « œ » et les guillemets français, pourtant
/// bien présents dans les données (« mise en œuvre », puces d'expérience).
library;

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Interligne supplémentaire, en points, ajouté entre deux lignes de texte.
///
/// Le paquet `pdf` colle les lignes par défaut. Sur un CV dense, cela produit
/// des paragraphes en bloc, pénibles à parcourir en diagonale, ce que fait
/// pourtant tout recruteur. 1,8 pt suffit à aérer sans coûter une page.
const kPdfLineSpacing = 1.8;

/// Le thème, chargé une seule fois par session.
///
/// Les deux polices pèsent ~800 ko et leur décodage n'est pas gratuit. Le
/// résultat étant identique à chaque rendu, on mémorise le `Future` : le
/// premier aperçu paie la lecture, les suivants la retrouvent instantanément.
/// On garde le `Future` (et non la valeur résolue) pour que deux aperçus
/// lancés coup sur coup partagent la même lecture au lieu d'en déclencher deux.
Future<pw.ThemeData>? _cachedTheme;

/// Charge le thème PDF (police embarquée + interligne). Mémorisé : un seul
/// décodage de police pour toute la session, quel que soit le nombre d'aperçus.
Future<pw.ThemeData> loadPdfTheme() => _cachedTheme ??= _buildPdfTheme();

Future<pw.ThemeData> _buildPdfTheme() async {
  final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/LiberationSans-Regular.ttf'));
  final bold =
      pw.Font.ttf(await rootBundle.load('assets/fonts/LiberationSans-Bold.ttf'));
  // Pas d'italique embarqué : ni le CV ni la lettre n'en utilisent. À rajouter
  // (LiberationSans-Italic.ttf) le jour où un rendu en aura besoin.
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);

  // L'interligne est posé sur le style par défaut : les styles locaux
  // (`pw.TextStyle(fontSize: …)`) en héritent sans avoir à le répéter partout.
  return theme.copyWith(
    defaultTextStyle:
        theme.defaultTextStyle.copyWith(lineSpacing: kPdfLineSpacing),
    paragraphStyle:
        theme.paragraphStyle.copyWith(lineSpacing: kPdfLineSpacing),
    bulletStyle: theme.bulletStyle.copyWith(lineSpacing: kPdfLineSpacing),
  );
}
