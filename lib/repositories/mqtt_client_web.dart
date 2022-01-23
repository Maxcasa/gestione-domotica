import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttDomoClient extends MqttBrowserClient {
  MqttDomoClient(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) : super('ws://$server', clientIdentifier,
            maxConnectionAttempts: maxConnectionAttempts);

  MqttDomoClient.withPort(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) : super.withPort('ws://$server', clientIdentifier, 8080,
            maxConnectionAttempts: maxConnectionAttempts);
}
