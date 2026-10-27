import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestione_domotica/models/configurazioni/connection_data.dart';
import 'package:gestione_domotica/repositories/enrollment_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _validBody() => {
      'apiVersion': 2,
      'connection': {
        'connectionName': 'Casa',
        'localServerName': 'domo.local',
        'remoteServerName': 'domo.tail1234.ts.net',
        'remoteDomain': 'Casa',
        'localWiFiConnectionName': 'wifi',
        'mqttPort': 1883,
        'mqttUsername': 'dev-1',
        'mqttPassword': 'secret-pw',
      },
    };

Future<ConnectionData> _enroll(http.Client client) => EnrollmentClient(
      client: client,
    ).enroll(
      serverName: 'domo.tail1234.ts.net',
      httpsPort: 8443,
      pairingCode: 'token',
      deviceId: 'abc123',
      deviceName: 'Phone',
    );

void main() {
  test('POST su HTTPS con il contratto v2 e parse della risposta', () async {
    late http.BaseRequest seen;
    String? body;
    final client = MockClient((request) async {
      seen = request;
      body = request.body;
      return http.Response(json.encode(_validBody()), 201);
    });
    final data = await _enroll(client);
    expect(seen.method, 'POST');
    expect(seen.url.toString(),
        'https://domo.tail1234.ts.net:8443/api/v2/enrollment');
    expect(seen.followRedirects, isFalse);
    expect(json.decode(body!), {
      'pairingCode': 'token',
      'deviceId': 'abc123',
      'deviceName': 'Phone',
    });
    expect(data.remoteUser, 'dev-1');
    expect(data.remotePassword, 'secret-pw');
    expect(data.mqttPort, 1883);
    expect(data.hasCredentials, isTrue);
  });

  test('toJson non contiene le credenziali', () {
    final data = EnrollmentClient.parseResponse(json.encode(_validBody()));
    final encoded = json.encode(data.toJson());
    expect(encoded.contains('secret-pw'), isFalse);
    expect(encoded.contains('dev-1'), isFalse);
    expect(data.toJson().containsKey('remotePassword'), isFalse);
  });

  test('stato diverso da 201 e errore esplicito', () async {
    final client = MockClient((_) async => http.Response('{}', 200));
    expect(_enroll(client), throwsA(isA<EnrollmentException>()));
  });

  test('versione o forma incompatibile e errore', () {
    final wrongVersion = _validBody()..['apiVersion'] = 3;
    final noConnection = {'apiVersion': 2};
    final badPort = _validBody();
    (badPort['connection'] as Map)['mqttPort'] = '1883';
    final noPassword = _validBody();
    (noPassword['connection'] as Map).remove('mqttPassword');
    for (final Object body in [
      wrongVersion,
      noConnection,
      badPort,
      noPassword
    ]) {
      expect(() => EnrollmentClient.parseResponse(json.encode(body)),
          throwsA(isA<EnrollmentException>()));
    }
    expect(() => EnrollmentClient.parseResponse('non json'),
        throwsA(isA<EnrollmentException>()));
  });

  test('host non validi o schema in chiaro sono rifiutati', () {
    for (final host in ['', 'http://x', 'a/b', 'a:80', 'a b']) {
      expect(() => EnrollmentClient.buildUri(host, 8443),
          throwsA(isA<EnrollmentException>()));
    }
    expect(() => EnrollmentClient.buildUri('host', 0),
        throwsA(isA<EnrollmentException>()));
    expect(EnrollmentClient.buildUri('host', 443).scheme, 'https');
  });

  test('errori di rete non fanno fallback e non espongono il corpo', () async {
    final client = MockClient((_) async => throw http.ClientException('x'));
    expect(
        _enroll(client),
        throwsA(isA<EnrollmentException>()
            .having((e) => e.message, 'message', isNot(contains('secret')))));
  });
}
