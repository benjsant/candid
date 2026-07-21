/// Client de l'API France Travail « Offres d'emploi v2 ».
///
/// Port du nœud « Token France Travail » et du nœud « FT - search » du workflow
/// `01-recherche-offres.json` du projet Docker. Les valeurs sensibles à
/// l'exactitude (URL du realm, scopes, noms des paramètres) en sont reprises
/// telles quelles : elles ont été vérifiées en production, on ne les redevine
/// pas.
///
/// Deux garde-fous repris de l'original :
///  - le **jeton est mis en cache** jusqu'à son expiration (moins une marge).
///    Il vit environ 25 minutes ; le redemander à chaque recherche serait un
///    appel gratuit en plus à chaque fois ;
///  - une panne de l'API **ne fait pas planter la collecte** : elle remonte une
///    exception typée que l'appelant affiche proprement, exactement comme
///    l'absence de clé désactive l'agent sans casser l'application.
library;

import 'package:dio/dio.dart';

import '../core/secrets.dart';
import 'normalize.dart';

/// L'API France Travail est indisponible ou mal configurée. Message destiné à
/// être montré tel quel à l'utilisateur.
class FranceTravailUnavailable implements Exception {
  const FranceTravailUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

const _tokenUrl =
    'https://entreprise.francetravail.fr/connexion/oauth2/access_token?realm=/partenaire';
const _searchUrl =
    'https://api.francetravail.io/partenaire/offresdemploi/v2/offres/search';

/// Scopes exigés par l'API Offres d'emploi v2 (repris du workflow Docker).
const _scope = 'api_offresdemploiv2 o2dsoffre';

/// Marge de sécurité sur l'expiration du jeton : on le renouvelle une minute
/// avant l'échéance plutôt que de risquer un 401 en plein milieu d'une collecte.
const _expiryMarginSeconds = 60;

/// Durée de repli si l'API n'annonce pas d'`expires_in` (valeur du workflow).
const _fallbackExpiresIn = 1499;

class FranceTravailClient {
  FranceTravailClient({required Secrets secrets, Dio? dio})
      // ignore: prefer_initializing_formals (champ privé, paramètre nommé)
      : _secrets = secrets,
        _dio = dio ?? Dio();

  final Secrets _secrets;
  final Dio _dio;

  String? _token;
  DateTime? _tokenExpiry;

  /// Vrai si les identifiants sont saisis. Sans eux, la collecte se désactive
  /// proprement : elle ne plante pas.
  Future<bool> get isConfigured => _secrets.canCollectFranceTravail;

  /// Jeton valide, depuis le cache si possible.
  Future<String> _accessToken() async {
    final cached = _token;
    final expiry = _tokenExpiry;
    if (cached != null && expiry != null && DateTime.now().isBefore(expiry)) {
      return cached;
    }

    final id = await _secrets.read(SecretKey.franceTravailClientId);
    final secret = await _secrets.read(SecretKey.franceTravailClientSecret);
    if (id == null || id.isEmpty || secret == null || secret.isEmpty) {
      throw const FranceTravailUnavailable(
        'Identifiants France Travail absents. Renseignez-les dans les réglages.',
      );
    }

    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        _tokenUrl,
        data: {
          'grant_type': 'client_credentials',
          'client_id': id,
          'client_secret': secret,
          'scope': _scope,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          // On lit le corps des erreurs plutôt que de laisser Dio jeter : le
          // message de l'API est plus utile que « 400 Bad Request ».
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw FranceTravailUnavailable(
        'France Travail injoignable (${e.type.name}). Vérifiez votre connexion.',
      );
    }

    if (response.statusCode != 200) {
      throw FranceTravailUnavailable(
        response.statusCode == 400 || response.statusCode == 401
            ? 'Identifiants France Travail refusés. Vérifiez-les dans les réglages.'
            : 'France Travail a répondu ${response.statusCode}.',
      );
    }

    final body = response.data;
    final map = body is Map ? body.cast<String, dynamic>() : null;
    final token = map?['access_token'];
    if (token is! String || token.isEmpty) {
      throw const FranceTravailUnavailable(
        'Réponse inattendue de France Travail : pas de jeton.',
      );
    }

    final expiresIn = map?['expires_in'];
    final seconds = (expiresIn is num ? expiresIn.toInt() : _fallbackExpiresIn) -
        _expiryMarginSeconds;
    _token = token;
    _tokenExpiry = DateTime.now().add(Duration(seconds: seconds.clamp(0, 86400)));
    return token;
  }

  /// Recherche des offres. Les paramètres reprennent ceux du workflow Docker :
  /// mots-clés, commune (code INSEE), distance en km.
  ///
  /// [range] borne la page ; l'API en accepte 150 au maximum par appel.
  Future<List<NormalizedOffer>> search({
    required String keywords,
    String? communeInsee,
    int? radiusKm,
    String range = '0-149',
  }) async {
    final token = await _accessToken();

    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        _searchUrl,
        queryParameters: {
          'motsCles': keywords,
          if (communeInsee != null && communeInsee.isNotEmpty)
            'commune': communeInsee,
          'distance': ?radiusKm,
          'range': range,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw FranceTravailUnavailable(
        'France Travail injoignable (${e.type.name}). Vérifiez votre connexion.',
      );
    }

    // 204 : l'API répond « aucun résultat » sans corps. Ce n'est pas une erreur.
    if (response.statusCode == 204) return const [];

    // 206 : réponse partielle (pagination). Le corps est exploitable tel quel.
    if (response.statusCode != 200 && response.statusCode != 206) {
      throw FranceTravailUnavailable(
        'France Travail a répondu ${response.statusCode}.',
      );
    }

    final body = response.data;
    return normalizeFranceTravail(
      body is Map ? body.cast<String, dynamic>() : null,
    );
  }
}
