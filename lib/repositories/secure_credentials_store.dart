import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Credenziali MQTT di una connessione
class MqttCredentials {
  const MqttCredentials(this.username, this.password);

  final String username;
  final String password;
}

/// Accesso allo storage sicuro del sistema operativo (Keystore/Keychain)
/// per credenziali MQTT e identificativo stabile del dispositivo.
class SecureCredentialsStore {
  SecureCredentialsStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                  accessibility:
                      KeychainAccessibility.first_unlock_this_device),
            );

  final FlutterSecureStorage _storage;

  static const String _deviceIdKey = 'domo.deviceId';
  static const String _credentialsPrefix = 'domo.mqtt.';

  String _key(String domain) => '$_credentialsPrefix$domain';

  Future<MqttCredentials?> read(String domain) async {
    final String? raw = await _storage.read(key: _key(domain));
    if (raw == null) {
      return null;
    }
    try {
      final Map<String, dynamic> data = json.decode(raw);
      final String? user = data['u'];
      final String? password = data['p'];
      if (user != null && password != null) {
        return MqttCredentials(user, password);
      }
    } on FormatException {
      // dato corrotto: trattato come assente
    }
    return null;
  }

  Future<void> write(String domain, MqttCredentials credentials) {
    return _storage.write(
        key: _key(domain),
        value: json
            .encode({'u': credentials.username, 'p': credentials.password}));
  }

  static const String _legacyPurgedKey = 'domo.legacyPurged';

  Future<bool> isLegacyPurged() async =>
      await _storage.read(key: _legacyPurgedKey) == '1';

  Future<void> markLegacyPurged() =>
      _storage.write(key: _legacyPurgedKey, value: '1');

  Future<void> delete(String domain) => _storage.delete(key: _key(domain));

  /// Identificativo casuale generato una volta e conservato in locale.
  Future<String> deviceId() async {
    String? id = await _storage.read(key: _deviceIdKey);
    if (id == null || id.isEmpty) {
      final Random random = Random.secure();
      id = List.generate(
              16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
          .join();
      await _storage.write(key: _deviceIdKey, value: id);
    }
    return id;
  }
}
