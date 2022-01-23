import 'package:mqtt_client/mqtt_server_client.dart';

class MqttDomoClient extends MqttServerClient {
  MqttDomoClient(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) : super(server, clientIdentifier,
            maxConnectionAttempts: maxConnectionAttempts);

  MqttDomoClient.withPort(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) : super.withPort(server, clientIdentifier, 1883,
            maxConnectionAttempts: maxConnectionAttempts);
}
