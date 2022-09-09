import 'dart:io';

import 'package:mqtt_client/mqtt_server_client.dart';

class MqttDomoClient extends MqttServerClient {
  MqttDomoClient(
    String server,
    String clientIdentifier, {
    bool remote = false,
    int maxConnectionAttempts = 3,
  }) : super(remote ? '$server' : '$server', clientIdentifier,
            maxConnectionAttempts: maxConnectionAttempts);

  MqttDomoClient.withPort(
    String server,
    String clientIdentifier, {
    bool remote = false,
    int maxConnectionAttempts = 3,
  }) : super.withPort(remote ? '$server' : '$server', clientIdentifier,
            remote ? 8883 : 1883,
            maxConnectionAttempts: maxConnectionAttempts) {
    String serverLog = remote ? 'mqtts://$server' : 'mqtt://$server';
    print(
        'MQTTClientWrapper:SERVER:$serverLog:${remote ? 8883 : 1883} client connecting....');
  }

  // porta standard 8883

  set useWebSocket(webSocket) {
    super.useWebSocket = webSocket;
  }

  set badCertificateResult(bool bedCert) {
    super.onBadCertificate = (dynamic a) => bedCert;
  }

  set secure(secure) {
    super.secure = secure;
  }

  set securityContext(securityContext) {
    super.securityContext = securityContext;
  }

  set onBadCertificate(bool Function(X509Certificate certificate)? callBack) {
    super.onBadCertificate = callBack;
  }
}
