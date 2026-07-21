/// Recherche de commune française via l'API Découpage administratif
/// (`geo.api.gouv.fr`), **sans clé**, comme le grounding INSEE de l'agent.
///
/// Pourquoi c'est nécessaire : France Travail filtre par **code INSEE**, pas par
/// nom de ville. Demander « 59606 » à l'utilisateur serait absurde ; on lui
/// laisse taper « Valenciennes » et on résout.
///
/// Règle habituelle : si l'API ne répond pas, la saisie n'est pas bloquée. Le
/// profil reste enregistrable sans commune, la collecte sera juste plus large.
library;

import 'package:dio/dio.dart';

/// Une commune résolue : ce que l'API a réellement renvoyé, rien de deviné.
class Commune {
  const Commune({
    required this.name,
    required this.inseeCode,
    this.departement = '',
    this.postalCode = '',
  });

  final String name;

  /// Le code INSEE, celui qu'attend le paramètre `commune` de France Travail.
  final String inseeCode;
  final String departement;
  final String postalCode;

  /// Libellé affichable : « Valenciennes (59) ».
  String get label =>
      departement.isEmpty ? name : '$name ($departement)';
}

const _url = 'https://geo.api.gouv.fr/communes';

/// Coordonnées d'une commune. La Bonne Alternance cherche par latitude et
/// longitude, là où France Travail cherche par code INSEE : on résout donc le
/// code au moment de la collecte plutôt que de stocker deux formats.
class LatLng {
  const LatLng(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// Résout des codes INSEE en coordonnées. Les codes absents ou refusés sont
/// simplement omis du résultat : une commune non résolue ne bloque pas les
/// autres.
Future<Map<String, LatLng>> communeCoordinates(
  List<String> inseeCodes, {
  Dio? dio,
}) async {
  final codes = inseeCodes.where((c) => c.trim().isNotEmpty).toList();
  if (codes.isEmpty) return const {};

  // Un code par requête. `code=59606,59350` répond « 200 [] » : l'API n'accepte
  // PAS de liste sur ce paramètre, et le dit en rendant zéro résultat plutôt
  // qu'une erreur (constat du 21/07/2026, après avoir supposé le contraire).
  // Les communes d'un profil se comptent sur les doigts d'une main.
  final client = dio ?? Dio();
  final out = <String, LatLng>{};

  for (final code in codes) {
    try {
      final response = await client.get<dynamic>(
        _url,
        queryParameters: {'code': code, 'fields': 'code,centre'},
        options: Options(validateStatus: (_) => true),
      );
      if (response.statusCode != 200) continue;
      final body = response.data;
      if (body is! List) continue;

      for (final raw in body.whereType<Map>()) {
        final m = raw.cast<String, dynamic>();
        final found = (m['code'] ?? '').toString();
        final centre = m['centre'];
        final coords = centre is Map ? centre['coordinates'] : null;
        // GeoJSON : [longitude, latitude], dans cet ordre. L'inverser enverrait
        // la recherche à l'autre bout du monde sans lever d'erreur.
        if (found.isNotEmpty && coords is List && coords.length >= 2) {
          out[found] = LatLng(
            (coords[1] as num).toDouble(),
            (coords[0] as num).toDouble(),
          );
        }
      }
    } on DioException {
      // Une commune injoignable n'empêche pas les autres.
      continue;
    }
  }
  return out;
}

/// Cherche des communes par nom. Rend une liste vide en cas d'échec : c'est une
/// aide à la saisie, pas une étape bloquante.
Future<List<Commune>> searchCommunes(String query, {Dio? dio}) async {
  final q = query.trim();
  if (q.length < 2) return const [];

  try {
    final response = await (dio ?? Dio()).get<dynamic>(
      _url,
      queryParameters: {
        'nom': q,
        'fields': 'nom,code,codesPostaux,departement',
        // Trier par population met la ville cherchée avant ses homonymes et
        // avant les communes voisines au nom composé.
        'boost': 'population',
        'limit': 8,
      },
      options: Options(validateStatus: (_) => true),
    );

    if (response.statusCode != 200) return const [];
    final body = response.data;
    if (body is! List) return const [];

    return body.whereType<Map>().map((raw) {
      final m = raw.cast<String, dynamic>();
      final dep = m['departement'];
      final postal = m['codesPostaux'];
      return Commune(
        name: (m['nom'] ?? '').toString(),
        inseeCode: (m['code'] ?? '').toString(),
        departement:
            dep is Map ? (dep['code'] ?? '').toString() : '',
        postalCode: postal is List && postal.isNotEmpty
            ? postal.first.toString()
            : '',
      );
    }).where((c) => c.inseeCode.isNotEmpty).toList();
  } on DioException {
    return const [];
  }
}
