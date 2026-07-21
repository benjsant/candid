/// Résolution de commune : aide à la saisie, jamais bloquante.
library;

import 'package:candid/sources/geo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fake extends Interceptor {
  _Fake(this.status, this.body);
  final int status;
  final Object? body;
  final List<RequestOptions> calls = [];

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    calls.add(o);
    h.resolve(
      Response<dynamic>(requestOptions: o, statusCode: status, data: body),
    );
  }
}

Dio _dio(int status, Object? body) => Dio()..interceptors.add(_Fake(status, body));

void main() {
  test('mappe la réponse de geo.api.gouv.fr', () async {
    final communes = await searchCommunes('Valenciennes', dio: _dio(200, [
      {
        'nom': 'Valenciennes',
        'code': '59606',
        'codesPostaux': ['59300'],
        'departement': {'code': '59', 'nom': 'Nord'},
      },
    ]));

    expect(communes.single.name, 'Valenciennes');
    expect(communes.single.inseeCode, '59606');
    expect(communes.single.label, 'Valenciennes (59)');
  });

  test('une requête trop courte n\'appelle pas l\'API', () async {
    expect(await searchCommunes('V'), isEmpty);
    expect(await searchCommunes(' '), isEmpty);
  });

  test('API en panne : liste vide, la saisie reste possible', () async {
    expect(await searchCommunes('Lille', dio: _dio(500, null)), isEmpty);
    expect(await searchCommunes('Lille', dio: _dio(200, null)), isEmpty);
  });

  group('communeCoordinates', () {
    test('lit le centre GeoJSON dans le bon ordre', () async {
      // GeoJSON range [longitude, latitude]. Inverser enverrait la recherche
      // LBA à l'autre bout du monde sans lever la moindre erreur.
      final coords = await communeCoordinates(['59606'], dio: _dio(200, [
        {
          'code': '59606',
          'centre': {
            'type': 'Point',
            'coordinates': [3.5142, 50.362],
          },
        },
      ]));

      expect(coords['59606']!.latitude, 50.362);
      expect(coords['59606']!.longitude, 3.5142);
    });

    test('liste vide : aucun appel', () async {
      expect(await communeCoordinates([]), isEmpty);
      expect(await communeCoordinates(['', '  ']), isEmpty);
    });

    test('une requête par code : l\'API refuse les listes', () async {
      // `code=59606,59350` répond « 200 [] », sans erreur. Supposer le contraire
      // faisait échouer silencieusement toute la source LBA (21/07/2026).
      final f = _Fake(200, [
        {
          'code': '59606',
          'centre': {
            'coordinates': [3.5, 50.3],
          },
        },
      ]);
      await communeCoordinates(['59606', '59350', '59178'],
          dio: Dio()..interceptors.add(f));

      expect(f.calls, hasLength(3), reason: 'un appel par commune');
      expect(f.calls.map((c) => c.queryParameters['code']),
          ['59606', '59350', '59178']);
    });

    test('commune sans centre : omise, les autres passent', () async {
      final coords = await communeCoordinates(['1', '2'], dio: _dio(200, [
        {'code': '1'},
        {
          'code': '2',
          'centre': {
            'coordinates': [3.0, 50.0],
          },
        },
      ]));
      expect(coords.keys, ['2']);
    });

    test('API en panne : vide, la collecte continue', () async {
      expect(await communeCoordinates(['59606'], dio: _dio(500, null)), isEmpty);
    });
  });

  test('une commune sans code est ignorée', () async {
    final communes = await searchCommunes('Xy', dio: _dio(200, [
      {'nom': 'Sans code'},
      {'nom': 'Bonne', 'code': '12345'},
    ]));
    expect(communes.single.name, 'Bonne');
  });
}
