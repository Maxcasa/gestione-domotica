import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttDomoClient extends MqttBrowserClient {
  MqttDomoClient(
    String server,
    String clientIdentifier, {
    bool remote = false,
    int maxConnectionAttempts = 3,
  }) : super(remote ? 'wss://$server' : 'ws://$server', clientIdentifier,
            maxConnectionAttempts: maxConnectionAttempts);

  MqttDomoClient.withPort(
    String server,
    String clientIdentifier, {
    bool remote = false,
    int maxConnectionAttempts = 3,
  }) : super.withPort(remote ? 'wss://$server' : 'ws://$server',
            clientIdentifier, remote ? 443 : 8080,
            maxConnectionAttempts: maxConnectionAttempts) {
    String serverLog = remote ? 'wss://$server' : 'ws://$server';
    print(
        'MQTTClientWrapper:WEB:$serverLog:${remote ? 443 : 8080} client connecting....');
  }

  set useWebSocket(webSocket) {}

  set secure(secure) {}

  set badCertificateResult(bool bedCert) {}

  set securityContext(securityContext) {
    //super.securityContext = securityContext;
  }

  set onBadCertificate(dynamic callBack) {
    // super.onBadCertificate = callBack;
  }
}
