import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gestione_domotica/models/configurazioni/connection_data.dart';
import 'package:http/http.dart' as http;

/// Errore di registrazione mostrabile all'utente (mai con dati sensibili)
class EnrollmentException implements Exception {
  EnrollmentException(this.message);

  final String message;

  @override
  String toString() => 'EnrollmentException: $message';
}

/// Client del contratto di enrollment v2.
///
/// La risposta contiene la password MQTT: usa solo HTTPS con verifica del
/// certificato e dell'hostname, senza redirect e senza fallback in chiaro.
/// Corpo della risposta e credenziali non vengono mai loggati.
class EnrollmentClient {
  EnrollmentClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const int apiVersion = 2;
  static const Duration timeout = Duration(seconds: 10);

  static Uri buildUri(String serverName, int httpsPort) {
    final String host = serverName.trim();
    if (host.isEmpty || host.contains(RegExp(r'[\s/:@?#]'))) {
      throw EnrollmentException('Nome server non valido');
    }
    if (httpsPort < 1 || httpsPort > 65535) {
      throw EnrollmentException('Porta HTTPS non valida');
    }
    return Uri(
        scheme: 'https',
        host: host,
        port: httpsPort,
        path: '/api/v2/enrollment');
  }

  Future<ConnectionData> enroll({
    required String serverName,
    required int httpsPort,
    required String pairingCode,
    required String deviceId,
    required String deviceName,
  }) async {
    final Uri uri = buildUri(serverName, httpsPort);
    if (pairingCode.trim().isEmpty) {
      throw EnrollmentException('Token di registrazione mancante');
    }
    final http.Request request = http.Request('POST', uri)
      ..followRedirects = false
      ..headers['content-type'] = 'application/json'
      ..headers['accept'] = 'application/json'
      ..body = json.encode({
        'pairingCode': pairingCode.trim(),
        'deviceId': deviceId,
        'deviceName': deviceName.trim(),
      });
    final http.Response response;
    try {
      final http.StreamedResponse streamed =
          await _client.send(request).timeout(timeout);
      response = await http.Response.fromStream(streamed).timeout(timeout);
    } on HandshakeException {
      throw EnrollmentException(
          'Certificato TLS del server non valido: registrazione annullata');
    } on TlsException {
      throw EnrollmentException(
          'Connessione TLS non riuscita: registrazione annullata');
    } on TimeoutException {
      throw EnrollmentException('Il server non risponde');
    } on SocketException {
      throw EnrollmentException('Server HTTPS non raggiungibile');
    } on http.ClientException {
      throw EnrollmentException('Server HTTPS non raggiungibile');
    }
    if (response.statusCode != 201) {
      throw EnrollmentException(
          'Registrazione rifiutata dal server (HTTP ${response.statusCode})');
    }
    return parseResponse(response.body);
  }

  /// Valida la risposta 201; qualsiasi versione o forma diversa e' un errore.
  static ConnectionData parseResponse(String body) {
    final EnrollmentException incompatible = EnrollmentException(
        'Risposta del server non compatibile (attesa apiVersion $apiVersion)');
    final dynamic decoded;
    try {
      decoded = json.decode(body);
    } on FormatException {
      throw incompatible;
    }
    if (decoded is! Map || decoded['apiVersion'] != apiVersion) {
      throw incompatible;
    }
    final dynamic connection = decoded['connection'];
    if (connection is! Map) {
      throw incompatible;
    }
    String? text(String key, {bool required = true}) {
      final dynamic value = connection[key];
      if (value is! String || (required && value.trim().isEmpty)) {
        throw incompatible;
      }
      return value;
    }

    final dynamic port = connection['mqttPort'];
    if (port is! int || port < 1 || port > 65535) {
      throw incompatible;
    }
    return ConnectionData(
      id: -1,
      connectionName: text('connectionName')!,
      localServerName: text('localServerName', required: false)!,
      remoteServerName: text('remoteServerName')!,
      remoteUser: text('mqttUsername')!,
      remotePassword: text('mqttPassword')!,
      remoteDomain: text('remoteDomain')!,
      localWiFiConnectionName:
          text('localWiFiConnectionName', required: false)!,
      intervalKeepAlive: 1,
      modeKeepAlive: 0,
      mqttPort: port,
    );
  }
}
