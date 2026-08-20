/// Normaliseurs par source : réponse brute d'une API vers le schéma commun des
/// offres. Port de `reference/sources.mjs`, la source de vérité de ce mapping.
///
/// Seules France Travail et La Bonne Alternance sont portées : les autres
/// sources du projet Docker (Adzuna, JobSpy, JSearch…) reposent sur du scraping
/// ou des agrégateurs que le mobile n'a pas, et le PLAN assume de ne pas viser
/// la parité.
///
/// Règle commune : **jamais d'invention**. Un champ absent de la réponse reste
/// vide, il n'est ni deviné ni rempli par défaut. C'est la même règle que pour
/// le parseur de partage et pour l'agent.
library;

/// Une offre normalisée, prête pour `OffersRepository.save`.
class NormalizedOffer {
  const NormalizedOffer({
    required this.source,
    required this.sourceId,
    required this.title,
    this.company = '',
    this.location = '',
    this.contractType = '',
    this.salary = '',
    this.description = '',
    this.url = '',
  });

  final String source;
  final String sourceId;
  final String title;
  final String company;
  final String location;
  final String contractType;
  final String salary;
  final String description;
  final String url;
}

/// Une entreprise à contacter en candidature spontanée (volet `recruiters` de
/// La Bonne Alternance). Ce n'est pas une offre : il n'y a pas de poste publié,
/// donc pas de description ni de scoring possible.
class NormalizedRecruiter {
  const NormalizedRecruiter({
    required this.sourceId,
    required this.name,
    this.siret = '',
    this.sector = '',
    this.website = '',
    this.location = '',
    this.applyUrl = '',
    this.phone = '',
    this.email = '',
  });

  final String sourceId;
  final String name;
  final String siret;
  final String sector;
  final String website;
  final String location;
  final String applyUrl;
  final String phone;
  final String email;
}

/// Équivalent du `s()` de `sources.mjs` : null devient chaîne vide, et on
/// élague. Aucune valeur de repli inventée.
String _s(Object? v) => v == null ? '' : v.toString().trim();

/// Premier non-vide, ou chaîne vide. Port des cascades `a || b || c`.
String _first(List<Object?> candidates) {
  for (final c in candidates) {
    final v = _s(c);
    if (v.isNotEmpty) return v;
  }
  return '';
}

Map<String, dynamic>? _map(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : null;

List<Map<String, dynamic>> _list(Object? v) => v is List
    ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
    : const [];

/// France Travail : `{ resultats: [...] }`, Offres d'emploi v2
/// `/offres/search`.
List<NormalizedOffer> normalizeFranceTravail(Map<String, dynamic>? payload) {
  return _list(payload?['resultats']).map((r) {
    return NormalizedOffer(
      source: 'france_travail',
      sourceId: _s(r['id']),
      title: _s(r['intitule']),
      company: _s(_map(r['entreprise'])?['nom']),
      location: _s(_map(r['lieuTravail'])?['libelle']),
      contractType: _first([r['typeContrat'], r['typeContratLibelle']]),
      salary: _s(_map(r['salaire'])?['libelle']),
      description: _s(r['description']),
      url: _s(_map(r['origineOffre'])?['urlOrigine']),
    );
  }).toList();
}

/// La Bonne Alternance, volet `jobs` (offres d'alternance publiées).
///
/// Forme vérifiée sur un vrai appel côté Docker (28/06/2026) et verrouillée par
/// des fixtures. Note reprise de `sources.mjs` : les offres partenaires (issues
/// de France Travail) ont `workplace.{brand,name,legal_name}` à null, donc
/// `company` ressort vide. C'est une dégradation propre, pas un bug.
List<NormalizedOffer> normalizeLaBonneAlternanceJobs(
    Map<String, dynamic>? payload) {
  return _list(payload?['jobs']).map((j) {
    final wp = _map(j['workplace']) ?? const {};
    final types = _map(j['contract'])?['type'];
    final contract = types is List
        ? types.map(_s).where((t) => t.isNotEmpty).join(', ')
        : _s(types);
    return NormalizedOffer(
      source: 'la_bonne_alternance',
      sourceId: _first([
        _map(j['identifier'])?['id'],
        _map(j['identifier'])?['partner_job_id'],
      ]),
      title: _s(_map(j['offer'])?['title']),
      company: _first([wp['brand'], wp['name'], wp['legal_name']]),
      location: _s(_map(wp['location'])?['address']),
      // Le repli « Alternance » n'invente rien : c'est la nature même de la
      // source, pas une déduction sur l'offre.
      contractType: contract.isNotEmpty ? contract : 'Alternance',
      description: _s(_map(j['offer'])?['description']),
      url: _s(_map(j['apply'])?['url']),
    );
  }).toList();
}

/// La Bonne Alternance, volet `recruiters` : des entreprises à fort potentiel
/// d'embauche, sans offre publiée, à contacter en candidature spontanée.
List<NormalizedRecruiter> normalizeLbaRecruiters(
    Map<String, dynamic>? payload) {
  return _list(payload?['recruiters']).map((r) {
    final wp = _map(r['workplace']) ?? const {};
    final apply = _map(r['apply']) ?? const {};
    return NormalizedRecruiter(
      sourceId: _first([_map(r['identifier'])?['id'], wp['siret']]),
      name: _first([wp['brand'], wp['name'], wp['legal_name']]),
      siret: _s(wp['siret']),
      sector: _first([
        _map(_map(wp['domain'])?['naf'])?['label'],
        _map(wp['naf'])?['label'],
      ]),
      website: _s(wp['website']),
      location: _s(_map(wp['location'])?['address']),
      applyUrl: _s(apply['url']),
      phone: _s(apply['phone']),
      email: _first([
        apply['email'],
        _map(r['contact'])?['email'],
        wp['email'],
      ]),
    );
  }).toList();
}
