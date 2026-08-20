/// Assemblage déterministe d'une lettre à partir d'un template « quasi-complet »
/// de `assets/letters/`. Port fidèle de `reference/letter-template.mjs`.
///
/// Le corps de la lettre est FIGÉ (validé par le candidat) : l'agent ne produit
/// QUE l'accroche (cf. prompt système §5/§6). Ici on ne fait que coller
/// l'accroche dans le template et résoudre les `{{placeholders}}`, jamais le
/// LLM. C'est un garde-fou : le corps n'est jamais réécrit, la seule zone de
/// texte libre est l'accroche. La substitution est pure et testée.
library;

/// Variables résolues dans les `{{placeholders}}` du template.
class LetterVars {
  const LetterVars({
    this.poste = '',
    this.company = '',
    this.titre = '',
    this.nom = '',
    this.email = '',
    this.telephone = '',
    this.formation = '',
    this.rythmeAlternance = '',
    this.dateDebut = '',
  });

  final String poste;
  final String company;
  final String titre;
  final String nom;
  final String email;
  final String telephone;
  final String formation;
  final String rythmeAlternance;
  final String dateDebut;

  Map<String, String> get _map => {
        'poste.intitule': poste,
        'entreprise.nom': company,
        'candidat.titre': titre,
        'candidat.nom': nom,
        'candidat.email': email,
        'candidat.telephone': telephone,
        'formation': formation,
        'rythme_alternance': rythmeAlternance,
        'date_debut': dateDebut,
      };
}

/// Une lettre assemblée : objet et corps, prêts pour la mise en page PDF.
class AssembledLetter {
  const AssembledLetter({required this.subject, required this.body});

  final String subject;
  final String body;
}

final _commentRe = RegExp(r'<!--.*?-->', dotAll: true);
final _signatureRe = RegExp(r'\n*\{\{\s*candidat\.nom\s*\}\}.*$', dotAll: true);
final _accrocheRe = RegExp(r'\[Accroche.*?\]', dotAll: true);
final _subjectRe = RegExp(r'^\s*Objet\s*:\s*(.+)$', multiLine: true);
final _subjectLineRe = RegExp(r'^\s*Objet\s*:.*$', multiLine: true);
final _placeholderRe = RegExp(r'\{\{\s*([\w.]+)\s*\}\}');
/// Plage de nombres collée entre deux chiffres (« 2016–2019 ») : écriture
/// correcte en français, préservée telle quelle.
final _numRangeRe = RegExp(r'(?<=[0-9])[—–](?=[0-9])');

/// Tiret employé comme ponctuation : c'est celui-là qui trahit une IA.
final _dashRe = RegExp(r'\s*[—–]\s*');

/// Sentinelle interne, absente de tout texte rédigé.
const _rangeMark = '￿';
final _blankLinesRe = RegExp(r'\n{3,}');

/// Retire les blocs de commentaire HTML (entête + « ton de référence »).
String stripComments(String md) => md.replaceAll(_commentRe, '');

/// Extrait l'objet (« Objet : … ») après résolution des placeholders.
String extractSubject(String text) =>
    _subjectRe.firstMatch(text)?.group(1)?.trim() ?? '';

/// Substitue les `{{placeholders}}` connus ; laisse intacts les inconnus.
String substitute(String text, LetterVars vars) {
  final map = vars._map;
  return text.replaceAllMapped(_placeholderRe, (m) {
    final key = m.group(1)!;
    return map.containsKey(key) ? map[key]! : m.group(0)!;
  });
}

/// Garde-fou anti-IA : remplace les tirets cadratin (—) et demi-cadratin (–)
/// par « , ». On ne touche PAS au trait d'union simple « - ».
String noDash(String s) => s
    .replaceAll(_numRangeRe, _rangeMark)
    .replaceAll(_dashRe, ', ')
    .replaceAll(_rangeMark, '–');

/// Assemble le template en objet + corps.
///
/// - remplace le bloc `[Accroche …]` par l'accroche de l'agent ;
/// - extrait la ligne « Objet : … » comme `subject` (retirée du corps) ;
/// - retire le bloc signature final : la mise en page ajoute déjà expéditeur et
///   signature depuis le profil.
AssembledLetter fillTemplate(
  String md, {
  String accroche = '',
  LetterVars vars = const LetterVars(),
}) {
  var t = stripComments(md);
  // 1. Retire le bloc signature final ({{candidat.nom}} … {{candidat.telephone}}).
  t = t.replaceFirst(_signatureRe, '\n');
  // 2. L'accroche (seule zone rédigée par l'agent) remplace le bloc [Accroche …].
  t = t.replaceFirst(_accrocheRe, accroche.trim());
  // 3. Résolution des placeholders restants.
  t = substitute(t, vars);
  // 4. Sujet = la ligne « Objet : … » (retirée ensuite du corps).
  final subject = extractSubject(t);
  t = t.replaceFirst(_subjectLineRe, '');
  // 5. Anti-dash puis compactage des lignes vides.
  final body = noDash(t).replaceAll(_blankLinesRe, '\n\n').trim();
  return AssembledLetter(subject: noDash(subject).trim(), body: body);
}
