import 'package:flutter/foundation.dart';
import 'package:gestione_domotica/models/remote_conf/remote_connection.dart';
//import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:math';
import './mqtt_client_web.dart'
    if (dart.library.io) './mqtt_client_server.dart';

//import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:flutter/material.dart';
//import 'package:gestione_domotica/models/model_data.dart';
//import 'repository.dart';

// final String serverUri = "test.mosquitto.org";
//const String serverUri = "192.168.1.3";

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  RICONNECTING,
  RICONNECTED,
  DISCONNECTED,
  TOGGLE_DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }

/// Classe Singleton per la gestione della comunicazione MQTT
class MQTTClientWrapper extends PropertyChangeNotifier<String> {
// class MQTTClientWrapper with ChangeNotifier {
  // costruttori
  static final MQTTClientWrapper _instance = MQTTClientWrapper._internal();

  factory MQTTClientWrapper() {
    return _instance;
  }

  MQTTClientWrapper._internal() {
    remoteConnection = RemoteConnection();
    remoteConnection!.addListener(serverChange);
    remoteConnection!.getConnectionInfo();
    print('Istanzio l\'MQTT Client');
  }

  // variabili
  MqttDomoClient? client;
  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;
  Map<String, List<Function(String)>> onDataReceivedArray = {};
  Map<String, List<Function(String, bool)>> onSubscriptionArray = {};
  List<String> subscribedTopicList = [];
  List<String> subscribedSubTopicList = [];

  RemoteConnection? remoteConnection;
  bool reconnect = false;
  bool _errorDetect = true;
  bool remote = false;
  // bool _statusRequest = false;

  String? remoteServer;
  String mqttUser = "";
  String mqttPW = "";
  // const int port = 1883;
  static const String topicBase = "Domotic";

  Future<void> connectMqttClient() async {
    print('MQTTClientWrapper::ConnectionState $connectionState');
    if (!(connectionStateCheck()) &&
        !(errorDetectedOrForced()) &&
        connectionState != MqttCurrentConnectionState.TOGGLE_DISCONNECTED &&
        remoteConnection != null &&
        !(remoteConnection!.connectionDataNull) &&
        remoteConnection!.connectionPresent) {
      // Posso collegarmi devo decidere se local o remote
      connectionState = MqttCurrentConnectionState.CONNECTING;
      if (await remoteConnection!.checkLocal()) {
        remoteServer = remoteConnection!.localServerName;
        mqttUser = 'mqtt_user';
        mqttPW = 'mqtt_user';
        remote = false;
      } else if (remoteConnection!.remoteUser != null) {
        remoteServer = remoteConnection!.remoteServerName;
        mqttUser = remoteConnection!.remoteUser!;
        remote = true;
      } else {
        _remoteNull();
        notifyListeners('connectionState.disconnected');
      }
      if (remoteServer != null) {
        _setupMqttClient();
        await _connectClient();
        _listenClient();
      }
      // serverUri = 'ws://$remoteServer';

      // } else {
      //   connectionState = MqttCurrentConnectionState.IDLE;
      // }
    } else {
      _remoteNull();
    }
  }

  void _remoteNull() {
    remoteServer = null;
    connectionState = MqttCurrentConnectionState.IDLE;
    remote = false;
    reconnect = false;
  }

  void _setupMqttClient() {
    // client = MqttServerClient.withPort(serverUri, '#', port);
    Random random = Random();
    String cliendId = 'mqtt_domo' + random.nextInt(1000000).toString();
    client = MqttDomoClient.withPort(remoteServer!, cliendId, remote: remote);
    if (kIsWeb) {
      client!.websocketProtocols = ['mqtt'];
    } else if (remote) {
      print('MQTTClientWrapper::Secure activated');
      client!.secure = true;
    }
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
    client!.onDisconnected = _onDisconnected;
    client!.onAutoReconnect = _onAutoReconnect;
    client!.onAutoReconnected = _onAutoReconnected;
    client!.onConnected = _onConnected;
    client!.onSubscribed = _onSubscribed;
    client!.onUnsubscribed = _onUnsubscribed;
  }

  Future<void> _connectClient() async {
    try {
      notifyListeners('connectionState.connecting');
      await client!.connect(mqttUser, mqttPW);
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      notifyListeners('connectionState.error');
      // client!.disconnect();
    }

    // if (client!.connectionStatus!.state == MqttConnectionState.connected) {
    //   connectionState = MqttCurrentConnectionState.CONNECTED;
    //   notifyListeners('connectionState.error');
    //   print('MQTTClientWrapper::$serverUri client connected');
    // } else {
    //   print(
    //       'MQTTClientWrapper::ERROR $serverUri client connection failed - disconnecting, status is ${client!.connectionStatus}');
    //   connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
    //   notifyListeners('currentConnectionState');
    //   client!.disconnect();
    // }
  }

  void _listenClient() {
    try {
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final topic = c[0].topic;
        final String message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print(
            "MQTTClientWrapper::GOT A NEW MESSAGE $message from topic $topic");
        if (onDataReceivedArray.containsKey(topic)) {
          for (var element in onDataReceivedArray[topic]!) {
            element(message);
          }
        }
      });
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      notifyListeners('connectionState.error');
      client!.disconnect();
    }
  }

  // metodo per la sottoscizione ad un topic
  // topicSurName: postfisso del topic (es. sensori)
  // onDataReceived: metodo che viene invocato quando viene ricevuto un messaggio
  void subscribeToTopic(
      {required String topicSurName,
      required Function(String) onDataReceived}) {
    String totalTopic =
        "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    print('MQTTClientWrapper::Subscribing to the ' + totalTopic + ' topic');
    if (!subscribedTopicList.contains(totalTopic)) {
      client!.subscribe(totalTopic, MqttQos.exactlyOnce);
    }
    if (onDataReceivedArray.containsKey(totalTopic)) {
      onDataReceivedArray[totalTopic]!.add(onDataReceived);
    } else {
      onDataReceivedArray[totalTopic] = [onDataReceived];
    }
  }

  void subscriptionCallback(
      {String topicSurName = '#all',
      required Function(String, bool) onSubscription}) {
    // String totalTopic =
    //     "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    if (onDataReceivedArray.containsKey(topicSurName)) {
      onSubscriptionArray[topicSurName]!.add(onSubscription);
    } else {
      onSubscriptionArray[topicSurName] = [onSubscription];
    }
  }

  // metodo per la rimozione della sottoscizione ad un topic
  // topicSurName: postfisso del topic (es. sensori)
  void unsubscribeToTopic({required String topicSurName}) {
    String totalTopic =
        "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    if (onDataReceivedArray.containsKey(totalTopic)) {
      print('MQTTClientWrapper::UnSubscribing to the ' +
          '$topicBase/${remoteConnection!.remoteDomain}/' +
          '$topicSurName/' +
          ' topic');
      client!.unsubscribe(
          "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName");
      onDataReceivedArray.remove(topicSurName);
    }
  }

  // void status() {
  //   if (connectionState == MqttCurrentConnectionState.CONNECTED) {
  //     _getstatus();
  //   } else {
  //     _statusRequest = true;
  //   }
  // }

  // void _getstatus() {
  //   _statusRequest = false;
  //   publishMessage(
  //       topicSurName: 'request/set', messageData: "{\"status\": \"OK\"}");
  // }

  // metodo per la pubblicazione di un messaggio
  // topicSurName: postfisso del topic (es. sensori)
  // messageData: ModelData da inviare
  void publishMessage(
      {required String topicSurName, required String messageData}) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    String totalTopic =
        "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    builder.addString(messageData);

    print(
        'MQTTClientWrapper::Publishing message ${messageData} to topic ${totalTopic}');
    client!.publishMessage(totalTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    String subTopic =
        topic.substring(topic.indexOf('/', topic.indexOf('/') + 1) + 1);
    subscribedTopicList.add(topic);
    subscribedSubTopicList.add(subTopic);
    if (onSubscriptionArray.containsKey(subTopic)) {
      for (var element in onSubscriptionArray[subTopic]!) {
        element(subTopic, true);
      }
    }
    if (onSubscriptionArray.containsKey('#all')) {
      for (var element in onSubscriptionArray['#all']!) {
        element(subTopic, true);
      }
    }
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onUnsubscribed(String? topic) {
    if (topic != null) {
      String subTopic =
          topic.substring(topic.indexOf('/', topic.indexOf('/') + 1) + 1);
      subscribedTopicList.remove(topic);
      subscribedSubTopicList.remove(subTopic);
      if (onSubscriptionArray.containsKey(topic)) {
        for (var element in onSubscriptionArray[topic]!) {
          element(subTopic, false);
        }
      }
      if (onSubscriptionArray.containsKey('#all')) {
        for (var element in onSubscriptionArray['#all']!) {
          element(subTopic, false);
        }
      }
    }
    print('MQTTClientWrapper::UnSubscription confirmed for topic $topic');
    //subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    // if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
    //   print('MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    // }
    if (connectionState != MqttCurrentConnectionState.TOGGLE_DISCONNECTED) {
      connectionState = MqttCurrentConnectionState.DISCONNECTED;
    }
    subscribedTopicList = [];
    subscribedSubTopicList = [];
    if (reconnect && remoteConnection!.connectionPresent) {
      connectMqttClient();
    } else {
      notifyListeners('connectionState.disconnected');
    }

    // if (reconnect) {
    //   _connectClient();
    // }
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    reconnect = false;
    // if (_statusRequest) {
    //   _getstatus();
    // }
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    notifyListeners('connectionState.connected');
  }

  void _onAutoReconnect() async {
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remote == (await remoteConnection!.checkLocal()) &&
        !reconnect) {
      print(
          'MQTTClientWrapper::OnRiconnect ${remoteConnection!.connectionPresent}');
      reconnect = true;
      client!.autoReconnect = false;
      client!.disconnect();
      //  connect('mqtt_user', 'mqtt_user');
    }
    connectionState = MqttCurrentConnectionState.RICONNECTING;
    print(
        'MQTTClientWrapper::OnRiconnect client callback - Client riconnection was in progress');
    notifyListeners('connectionState.riconnect');
  }

  void _onAutoReconnected() {
    connectionState = MqttCurrentConnectionState.RICONNECTED;
    print(
        'MQTTClientWrapper::OnRiconnected client callback - Client riconnection was sucessful');
    notifyListeners('connectionState.riconnected');
  }

  void toggleState() {
    if (connectionStateCheck()) {
      connectionState = MqttCurrentConnectionState.TOGGLE_DISCONNECTED;
      reconnect = false;
      client!.autoReconnect = false;
      client!.disconnect();
      //  connect('mqtt_user', 'mqtt_user');
    } else if (connectionState == MqttCurrentConnectionState.DISCONNECTED ||
        connectionState == MqttCurrentConnectionState.IDLE ||
        connectionState == MqttCurrentConnectionState.ERROR_WHEN_CONNECTING ||
        connectionState == MqttCurrentConnectionState.TOGGLE_DISCONNECTED) {
      connectionState = MqttCurrentConnectionState.IDLE;
      connectMqttClient();
    }
  }

  void disconnect() {
    if (connectionStateCheck()) {
      client!.disconnect();
    }
  }

  void serverChange() async {
    if (connectionStateCheck() &&
        remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remote == (await remoteConnection!.checkLocal()) &&
        !reconnect) {
      reconnect = true;
      client!.autoReconnect = false;
      client!.disconnect();
      //  connect('mqtt_user', 'mqtt_user');
    } else if (!connectionStateCheck() && remoteConnection!.connectionPresent) {
      connectMqttClient();
    }
  }

  bool connectionStateCheck() {
    if (connectionState == MqttCurrentConnectionState.CONNECTING ||
        connectionState == MqttCurrentConnectionState.CONNECTED ||
        connectionState == MqttCurrentConnectionState.RICONNECTING ||
        connectionState == MqttCurrentConnectionState.RICONNECTED) {
      return true;
    }
    return false;
  }

  bool errorDetectedOrForced() {
    if (connectionState == MqttCurrentConnectionState.ERROR_WHEN_CONNECTING &&
        _errorDetect) {
      return true;
    }
    _errorDetect = true;
    return false;
  }

  // bool connectivityCheck() {
  //   if (remoteConnection!.connectivity != 0) {
  //     return true;
  //   }
  //   return false;
  // }
}

// Future<MqttServerClient> connect() async {
//   MqttServerClient client =
//       MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
//   client.logging(on: true);
//   client.onConnected = onConnected;
//   client.onDisconnected = onDisconnected;
//   client.onUnsubscribed = onUnsubscribed;
//   client.onSubscribed = onSubscribed;
//   client.onSubscribeFail = onSubscribeFail;
//   client.pongCallback = pong;

//   final connMessage = MqttConnectMessage()
//       .authenticateAs('username', 'password')
//       .keepAliveFor(60)
//       .withWillTopic('willtopic')
//       .withWillMessage('Will message')
//       .startClean()
//       .withWillQos(MqttQos.atLeastOnce);
//   client.connectionMessage = connMessage;
//   try {
//     await client.connect();
//   } catch (e) {
//     print('Exception: $e');
//     client.disconnect();
//   }

//   /// The client has a change notifier object(see the Observable class) which we then listen to to get
//   /// notifications of published updates to each subscribed topic.
//   client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//     final recMess = c![0].payload as MqttPublishMessage;
//     final pt =
//         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

//     /// The above may seem a little convoluted for users only interested in the
//     /// payload, some users however may be interested in the received publish message,
//     /// lets not constrain ourselves yet until the package has been in the wild
//     /// for a while.
//     /// The payload is a byte buffer, this will be specific to the topic
//     print(
//         'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
//     print('');
//   });

//   return client;
// }

// // connection succeeded
// void onConnected() {
//   print('Connected');
// }

// // unconnected
// void onDisconnected() {
//   print('Disconnected');
// }

// // subscribe to topic succeeded
// void onSubscribed(String topic) {
//   print('Subscribed topic: $topic');
// }

// // subscribe to topic failed
// void onSubscribeFail(String topic) {
//   print('Failed to subscribe $topic');
// }

// // unsubscribe succeeded
// void onUnsubscribed(String topic) {
//   print('Unsubscribed topic: $topic');
// }

// // PING response received
// void pong() {
//   print('Ping response client callback invoked');
// }
