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
            maxConnectionAttempts: maxConnectionAttempts);

  set secure(secure) {
    super.secure = secure;
  }
}
