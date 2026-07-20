/// Rendu PDF du CV. Port du template ATS `reference/template-ats.astro` :
/// une colonne, texte à plat, sobre, pour un parsing ATS maximal.
///
/// À ce stade (étape 3), on rend le CV maître tel quel, sans l'agent : pas de
/// personnalisation, pas de masquage de sections. L'étape 4 branchera la sortie
/// de l'agent (`highlight_*`, `hidden_*`, résumé sur mesure) sur ce même rendu.
///
/// Garde-fou repris du template : aucun tiret cadratin dans le rendu, et rien
/// n'est inventé — on n'affiche que ce que portent les `assets/cv/*.json`.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/assets.dart';

/// Charge toutes les données du CV depuis `assets/cv/*.json`.
Future<CvData> loadCvData([AppAssets assets = const AppAssets()]) async {
  final results = await Future.wait([
    assets.profile(),
    assets.skills(),
    assets.projects(),
    assets.experiences(),
    assets.education(),
    assets.certifications(),
    assets.languages(),
    assets.interests(),
  ]);
  return CvData(
    profile: results[0],
    skills: results[1],
    projects: results[2],
    experiences: results[3],
    education: results[4],
    certifications: results[5],
    languages: results[6],
    interests: results[7],
  );
}

/// Palette sobre du template ATS.
class _C {
  static final ink = PdfColor.fromHex('111827');
  static final muted = PdfColor.fromHex('374151');
  static final faint = PdfColor.fromHex('4b5563');
  static final indigo = PdfColor.fromHex('3730a3');
  static final rule = PdfColor.fromHex('c7d2fe');
}

/// Anti-IA : tiret cadratin/demi-cadratin -> trait d'union ; point médian -> virgule.
String _clean(Object? s) => (s ?? '')
    .toString()
    .replaceAll(RegExp(r'[—–]'), '-')
    .replaceAll(RegExp(r'\s*·\s*'), ', ');

String _strip(Object? url) => (url ?? '')
    .toString()
    .replaceAll(RegExp(r'^https?://(www\.)?'), '')
    .replaceAll(RegExp(r'/$'), '');

/// Les données du CV, telles que chargées depuis `assets/cv/*.json`.
class CvData {
  const CvData({
    required this.profile,
    required this.skills,
    required this.projects,
    required this.experiences,
    required this.education,
    required this.certifications,
    required this.languages,
    required this.interests,
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic> skills;
  final Map<String, dynamic> projects;
  final Map<String, dynamic> experiences;
  final Map<String, dynamic> education;
  final Map<String, dynamic> certifications;
  final Map<String, dynamic> languages;
  final Map<String, dynamic> interests;
}

List<Map<String, dynamic>> _list(Map<String, dynamic> m, String key) =>
    ((m[key] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();

/// Construit le document PDF du CV.
///
/// [theme] porte la police embarquée (voir `pdf_theme.dart`) ; sans lui, les
/// glyphes « • » et « œ » s'affichent en tofu. Optionnel pour les tests de
/// fumée, toujours fourni par l'application.
pw.Document buildCvDocument(CvData data, {pw.ThemeData? theme}) {
  final doc = pw.Document(theme: theme);
  final p = data.profile;

  final name = _clean(p['name']).isEmpty ? '[Nom]' : _clean(p['name']);
  final title = _clean(p['title']);
  final summary = _clean(p['summary']);
  final links = (p['links'] as Map?)?.cast<String, dynamic>() ?? const {};

  final contacts = <List<String>>[
    if (_clean(p['email']).isNotEmpty) ['Email', _clean(p['email'])],
    if (_strip(links['portfolio']).isNotEmpty)
      ['Portfolio', _strip(links['portfolio'])],
    if (_strip(links['linkedin']).isNotEmpty)
      ['LinkedIn', _strip(links['linkedin'])],
    if (_strip(links['github']).isNotEmpty) ['GitHub', _strip(links['github'])],
  ];
  final meta = <List<String>>[
    if (_clean(p['permis']).isNotEmpty) ['Permis', _clean(p['permis'])],
    if (_clean(p['location']).isNotEmpty || _clean(p['mobility_label']).isNotEmpty)
      [
        'Mobilité',
        _clean(p['location']).isNotEmpty
            ? _clean(p['location'])
            : _clean(p['mobility_label']),
      ],
  ];

  final skillRows = _buildSkillRows(data);
  final projects = _list(data.projects, 'projects')
      .where((e) => _clean(e['name']).isNotEmpty)
      .toList();
  final experiences = _list(data.experiences, 'experiences')
      .where((e) => _clean(e['role']).isNotEmpty || _clean(e['company']).isNotEmpty)
      .toList();
  final education = _list(data.education, 'education')
      .where((e) => _clean(e['degree']).isNotEmpty || _clean(e['school']).isNotEmpty)
      .toList();
  final certifications = _list(data.certifications, 'certifications')
      .where((e) => _clean(e['name']).isNotEmpty)
      .toList();
  final interests = _list(data.interests, 'interests')
      .where((e) => _clean(e['title']).isNotEmpty)
      .toList();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 14 * PdfPageFormat.mm / 10, vertical: 8 * PdfPageFormat.mm / 10),
      build: (context) => [
        // En-tête.
        pw.Text(name,
            style: pw.TextStyle(
                fontSize: 22, fontWeight: pw.FontWeight.bold, color: _C.ink)),
        if (title.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(title,
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _C.indigo)),
          ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3),
          child: pw.Text('Disponible, démarrage immédiat',
              style: pw.TextStyle(fontSize: 9, color: _C.muted)),
        ),
        if (summary.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(summary,
                style: pw.TextStyle(fontSize: 9.5, color: _C.muted)),
          ),
        if (contacts.isNotEmpty)
          _contactLine(contacts),
        if (meta.isNotEmpty) _contactLine(meta),

        if (skillRows.isNotEmpty)
          _section('Compétences', [
            for (final row in skillRows) _skillLine(row),
          ]),

        if (projects.isNotEmpty)
          _section('Projets réalisés', [
            for (final pr in projects) _projectItem(pr),
          ]),

        if (experiences.isNotEmpty)
          _section('Expérience professionnelle', [
            for (final e in experiences) _experienceItem(e),
          ]),

        if (education.isNotEmpty)
          _section('Formation', [
            for (final e in education) _educationLine(e),
          ]),

        if (certifications.isNotEmpty)
          _section('Certifications', [
            for (final c in certifications) _certificationLine(c),
          ]),

        if (interests.isNotEmpty)
          _section('Centres d\'intérêt', [
            for (final i in interests) _interestLine(i),
          ]),
      ],
    ),
  );

  return doc;
}

/// Lignes de compétences par catégorie, plus la ligne « Langues ».
List<_SkillRow> _buildSkillRows(CvData data) {
  final rows = <_SkillRow>[];
  for (final cat in _list(data.skills, 'categories')) {
    final items = ((cat['items'] as List?) ?? const [])
        .whereType<Map>()
        .where((s) => _clean(s['name']).isNotEmpty)
        .map((s) {
          final level = _clean(s['level']);
          final name = _clean(s['name']);
          return level.isNotEmpty ? '$name ($level)' : name;
        })
        .toList();
    if (items.isNotEmpty) {
      rows.add(_SkillRow(_clean(cat['name']), items));
    }
  }
  final langs = _list(data.languages, 'languages')
      .where((l) => _clean(l['name']).isNotEmpty)
      .map((l) {
        final level = _clean(l['level']);
        final name = _clean(l['name']);
        return level.isNotEmpty ? '$name ($level)' : name;
      })
      .toList();
  if (langs.isNotEmpty) rows.add(_SkillRow('Langues', langs));
  return rows;
}

class _SkillRow {
  const _SkillRow(this.name, this.items);
  final String name;
  final List<String> items;
}

pw.Widget _section(String heading, List<pw.Widget> children) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 7),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 4),
        padding: const pw.EdgeInsets.only(bottom: 2),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _C.rule, width: 1.5)),
        ),
        child: pw.Text(
          heading.toUpperCase(),
          style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: _C.indigo,
              letterSpacing: 0.6),
        ),
      ),
      ...children,
    ]),
  );
}

pw.Widget _contactLine(List<List<String>> pairs) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 4),
    child: pw.Text(
      pairs.map((c) => '${c[0]} : ${c[1]}').join('  |  '),
      style: pw.TextStyle(fontSize: 9, color: _C.muted),
    ),
  );
}

pw.Widget _skillLine(_SkillRow row) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    child: pw.RichText(
      text: pw.TextSpan(children: [
        pw.TextSpan(
          text: '${row.name} : ',
          style: pw.TextStyle(
              fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _C.ink),
        ),
        pw.TextSpan(
          text: row.items.join(', '),
          style: pw.TextStyle(fontSize: 9.5, color: _C.muted),
        ),
      ]),
    ),
  );
}

pw.Widget _projectItem(Map<String, dynamic> p) {
  final period = _clean(p['period']);
  final tech = ((p['tech'] as List?) ?? const []).map(_clean).where((t) => t.isNotEmpty);
  final desc = _clean(p['description']);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: _clean(p['name']),
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold, color: _C.ink)),
          if (period.isNotEmpty)
            pw.TextSpan(
                text: ' ($period)',
                style: pw.TextStyle(fontSize: 10, color: _C.ink)),
        ]),
      ),
      if (tech.isNotEmpty)
        pw.Text(tech.join(', '),
            style: pw.TextStyle(fontSize: 8.5, color: _C.faint)),
      if (desc.isNotEmpty)
        pw.Text(desc, style: pw.TextStyle(fontSize: 9, color: _C.muted)),
    ]),
  );
}

pw.Widget _experienceItem(Map<String, dynamic> e) {
  final company = _clean(e['company']);
  final role = _clean(e['role']);
  final date = _clean(e['date']);
  final bullets = ((e['bullets'] as List?) ?? const []).map(_clean).toList();
  // La ligne « Stack : … » devient une ligne « Environnement ».
  final stackLine = bullets.firstWhere(
    (b) => RegExp(r'^stack\s*:', caseSensitive: false).hasMatch(b),
    orElse: () => '',
  );
  final tasks = bullets.where((b) => b != stackLine).toList();
  final stack = stackLine.isEmpty
      ? ''
      : stackLine.replaceFirst(RegExp(r'^stack\s*:\s*', caseSensitive: false), '');

  final head = StringBuffer(company.isNotEmpty ? company : role);
  if (company.isNotEmpty && role.isNotEmpty) head.write(', $role');
  if (date.isNotEmpty) head.write(', $date');

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(head.toString(),
          style: pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold, color: _C.ink)),
      for (final t in tasks)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 1, left: 6),
          child: pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                  text: '• ', style: pw.TextStyle(fontSize: 9, color: _C.muted)),
              pw.TextSpan(
                  text: t, style: pw.TextStyle(fontSize: 9, color: _C.muted)),
            ]),
          ),
        ),
      if (stack.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 1),
          child: pw.Text('Environnement : $stack',
              style: pw.TextStyle(fontSize: 8.5, color: _C.faint)),
        ),
    ]),
  );
}

pw.Widget _educationLine(Map<String, dynamic> e) {
  final degree = _clean(e['degree']);
  final school = _clean(e['school']);
  final location = _clean(e['location']);
  final date = _clean(e['date']);
  final details = _clean(e['details']);
  final tail = StringBuffer();
  if (school.isNotEmpty) tail.write(', $school');
  if (location.isNotEmpty) tail.write(', $location');
  if (date.isNotEmpty) tail.write(' ($date)');
  if (details.isNotEmpty) tail.write(' : $details');
  return _boldLead(degree, tail.toString());
}

pw.Widget _certificationLine(Map<String, dynamic> c) {
  final name = _clean(c['name']);
  final issuer = _clean(c['issuer']);
  final year = _clean(c['year']);
  final tail = StringBuffer();
  if (issuer.isNotEmpty) tail.write(', $issuer');
  if (year.isNotEmpty) tail.write(' ($year)');
  return _boldLead(name, tail.toString());
}

pw.Widget _interestLine(Map<String, dynamic> i) {
  final title = _clean(i['title']);
  final desc = _clean(i['description']);
  return _boldLead(title, desc.isNotEmpty ? ' : $desc' : '');
}

pw.Widget _boldLead(String lead, String tail) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.RichText(
      text: pw.TextSpan(children: [
        pw.TextSpan(
            text: lead,
            style: pw.TextStyle(
                fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _C.ink)),
        if (tail.isNotEmpty)
          pw.TextSpan(
              text: tail, style: pw.TextStyle(fontSize: 9.5, color: _C.muted)),
      ]),
    ),
  );
}
