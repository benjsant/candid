/// Résolution de commune : aide à la saisie, jamais bloquante.
library;

import 'package:candid/sources/geo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fake extends Interceptor {
  _Fake(this.status, this.body);
  final int status;
  final Object? body;

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) => h.resolve(
        Response<dynamic>(requestOptions: o, statusCode: status, data: body),
      );
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

  test('une commune sans code est ignorée', () async {
    final communes = await searchCommunes('Xy', dio: _dio(200, [
      {'nom': 'Sans code'},
      {'nom': 'Bonne', 'code': '12345'},
    ]));
    expect(communes.single.name, 'Bonne');
  });
}
