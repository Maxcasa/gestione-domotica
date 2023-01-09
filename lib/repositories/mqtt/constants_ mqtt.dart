// final String defaultMarkerId = "1";

// final String serverUri = "test.mosquitto.org";
// final int port = 1883;

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }
