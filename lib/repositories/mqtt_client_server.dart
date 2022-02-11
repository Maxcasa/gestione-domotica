import 'package:mqtt_client/mqtt_server_client.dart';

class MqttDomoClient extends MqttServerClient {
  MqttDomoClient(
    String server,
    String clientIdentifier, {
    bool remote = false,
    int maxConnectionAttempts = 3,
  }) : super(remote ? 'mqtts://$server' : 'mqtt://$server', clientIdentifier,
            maxConnectionAttempts: maxConnectionAttempts);

  MqttDomoClient.withPort(
    String server,
    String clientIdentifier, {
    bool remote = false,
    int maxConnectionAttempts = 3,
  }) : super.withPort(remote ? 'mqtts://$server' : 'mqtt://$server',
            clientIdentifier, remote ? 8883 : 1883,
            maxConnectionAttempts: maxConnectionAttempts);
}
