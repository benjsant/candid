/// Client de La Bonne Alternance (service public apprentissage / beta.gouv),
/// API emploi unifiée v1 : `/api/job/v1/search`.
///
/// Elle cherche par **latitude/longitude + rayon + codes ROME**, là où France
/// Travail cherche par code INSEE. Les coordonnées sont donc résolues à la
/// collecte depuis les codes du profil (voir `geo.dart`), plutôt que stockées
/// en double dans la base.
///
/// La réponse contient deux listes de nature différente, et il ne faut pas les
/// confondre :
///  - `jobs` : de vraies offres d'alternance publiées ;
///  - `recruiters` : des entreprises à fort potentiel d'embauche, **sans offre
///    publiée**, à démarcher en candidature spontanée. Ce ne sont pas des
///    offres : elles n'ont ni intitulé de poste ni description, et les
///    enregistrer comme telles reviendrait à inventer une annonce qui n'existe
///    pas. Elles sont comptées et signalées, pas transformées en offres.
library;

import 'package:dio/dio.dart';

import '../core/secrets.dart';
import 'normalize.dart';

/// L'API est indisponible ou mal configurée. Message montrable tel quel.
class LbaUnavailable implements Exception {
  const LbaUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

const _searchUrl = 'https://api.apprentissage.beta.gouv.fr/api/job/v1/search';

/// Code ROME par défaut : « études et développement informatique », qui couvre
/// tout le développement. Repris du profil du projet Docker. Le profil peut le
/// remplacer.
const kDefaultRomeCodes = 'M1805';

/// Ce que rend une recherche : les offres, et le nombre d'entreprises à
/// démarcher (qu'on ne transforme pas en offres).
class LbaResult {
  const LbaResult({this.jobs = const [], this.recruiters = const []});

  final List<NormalizedOffer> jobs;

  /// Entreprises à démarcher. Volontairement séparées des offres : elles n'ont
  /// pas de poste publié, et en fabriquer un serait inventer.
  final List<NormalizedRecruiter> recruiters;

  int get recruiterCount => recruiters.length;
}

class LbaClient {
  LbaClient({required Secrets secrets, Dio? dio})
      // ignore: prefer_initializing_formals (champ privé, paramètre nommé)
      : _secrets = secrets,
        _dio = dio ?? Dio();

  final Secrets _secrets;
  final Dio _dio;

  /// Vrai si la clé est saisie. Sans elle, la source se désactive proprement.
  Future<bool> get isConfigured => _secrets.has(SecretKey.lbaApiKey);

  Future<LbaResult> search({
    required double latitude,
    required double longitude,
    int radiusKm = 30,
    String romeCodes = kDefaultRomeCodes,
  }) async {
    final key = await _secrets.read(SecretKey.lbaApiKey);
    if (key == null || key.isEmpty) {
      throw const LbaUnavailable(
        'Clé La Bonne Alternance absente. Renseignez-la dans les réglages.',
      );
    }

    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        _searchUrl,
        queryParameters: {
          'romes': romeCodes,
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusKm,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $key'},
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw LbaUnavailable(
        'La Bonne Alternance injoignable (${e.type.name}).',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const LbaUnavailable(
        'Clé La Bonne Alternance refusée. Vérifiez-la dans les réglages.',
      );
    }
    if (response.statusCode != 200) {
      throw LbaUnavailable(
        'La Bonne Alternance a répondu ${response.statusCode}.',
      );
    }

    final body = response.data;
    final map = body is Map ? body.cast<String, dynamic>() : null;
    return LbaResult(
      jobs: normalizeLaBonneAlternanceJobs(map),
      recruiters: normalizeLbaRecruiters(map),
    );
  }
}
