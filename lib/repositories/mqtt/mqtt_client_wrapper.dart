import 'dart:async';
import 'dart:math';

import 'package:gestione_domotica/models/configurazioni/connection_data.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

//import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:flutter/material.dart';
//import 'package:gestione_domotica/models/model_data.dart';
//import 'repository.dart';

// final String serverUri = "test.mosquitto.org";
//const String serverUri = "192.168.1.3";
// RICONNECTING,
// RICONNECTED,
//  TOGGLE_DISCONNECTED,

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttWrapperState { ACTIVE, INACTIVE, ERROR }

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
    remoteConnection!.addListener(() {
      removeToken = true;
    }, ['activeIndex']);
    remoteConnection!.addListener(serverChange,
        ['activeIndex', 'connectivity', 'connectionInfo', 'connectionConf']);
    remoteConnection!.addListener(sendToken, ['token']);
    remoteConnection!.getConnectionInfo();
    print('Istanzio l\'MQTT Client');
  }

  // variabili
  MqttServerClient? client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>?
      _updatesSubscription;
  // topic gia' richiesti al broker sul client corrente
  final Set<String> _requestedTopics = {};
  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;
  MqttWrapperState wrapperState = MqttWrapperState.INACTIVE;
  Map<String, List<Function(String)>> onDataReceivedArray = {};
  Map<String, List<Function(String, bool)>> onSubscriptionArray = {};
  List<String> subscribedTopicList = [];
  List<String> subscribedSubTopicList = [];

  //controllo se devo mandare il token
  bool isTokenToSend = false;
  bool removeToken = false;

  RemoteConnection? remoteConnection;
  // bool reconnect = false;
  // bool _errorDetect = true;
  bool remote = false;
  // bool _statusRequest = false;

  bool active = false;

  String? remoteServer;
  String mqttUser = "";
  String mqttPW = "";
  int mqttPort = defaultMqttPort;
  static const String topicBase = "Domotic";

  Future<void> connectMqttClient() async {
    print('MQTTClientWrapper::ConnectionState $connectionState');
    if (!connectionAllowed) {
      _remoteNull();
      return;
    }
    // LAN preferita se l'health check risponde, altrimenti tailnet; in
    // entrambi i casi stesso account MQTT, porta 1883 e nessun TLS.
    connectionState = MqttCurrentConnectionState.CONNECTING;
    final bool local = await remoteConnection!.checkLocal();
    final String? host = local
        ? remoteConnection!.localServerName
        : remoteConnection!.remoteServerName;
    final String? user = remoteConnection!.remoteUser;
    final String? password = remoteConnection!.remotePassword;
    if (host == null || host.isEmpty || user == null || password == null) {
      _remoteNull();
      notifyListeners('connectionState.disconnected');
      return;
    }
    remoteServer = host;
    mqttUser = user;
    mqttPW = password;
    mqttPort = remoteConnection!.mqttPort;
    remote = !local;
    _disposeClient();
    _setupMqttClient();
    await _connectClient();
  }

  bool get connectionAllowed {
    if (!connectionStateCheck() &&
        wrapperState == MqttWrapperState.ACTIVE &&
        remoteConnection != null &&
        !(remoteConnection!.connectionDataNull) &&
        remoteConnection!.connectionPresent) {
      return true;
    } else {
      return false;
    }
  }

  void _remoteNull() {
    remoteServer = null;
    connectionState = MqttCurrentConnectionState.IDLE;
    remote = false;
  }

  void _disposeClient() {
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _requestedTopics.clear();
    final MqttServerClient? old = client;
    if (old != null) {
      old.autoReconnect = false;
      old.onDisconnected = null;
      old.onAutoReconnect = null;
      old.onAutoReconnected = null;
      old.onConnected = null;
      old.onSubscribed = null;
      old.onUnsubscribed = null;
      old.disconnect();
    }
    client = null;
  }

  void _setupMqttClient() {
    String clientId = 'mqtt_domo${Random.secure().nextInt(1000000)}';
    print('MQTTClientWrapper::client connecting to port $mqttPort');
    client = MqttServerClient.withPort(remoteServer!, clientId, mqttPort);
    client!.logging(on: false);
    client!.useWebSocket = false;
    client!.secure = false;
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
      print('MQTTClientWrapper::client exception - ${e.runtimeType}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      notifyListeners('connectionState.error');
    }
  }

  void _listenClient() {
    // una sola sottoscrizione allo stream per client, anche dopo riconnessioni
    if (_updatesSubscription != null ||
        client == null ||
        client!.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    _updatesSubscription = client!.updates!
        .listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      for (final MqttReceivedMessage<MqttMessage?> received in messages) {
        final MqttMessage? payload = received.payload;
        if (payload is! MqttPublishMessage) {
          continue;
        }
        final String topic = received.topic;
        final String message =
            MqttPublishPayload.bytesToStringAsString(payload.payload.message);
        final List<Function(String)>? callbacks = onDataReceivedArray[topic];
        if (callbacks != null) {
          for (var element in List.of(callbacks)) {
            element(message);
          }
        }
      }
    });
  }

  // sottoscrizione idempotente: un solo subscribe per topic e callback unica
  void _subscribe(String totalTopic, Function(String) onDataReceived) {
    print('MQTTClientWrapper::Subscribing to the $totalTopic topic');
    if (client != null &&
        !subscribedTopicList.contains(totalTopic) &&
        _requestedTopics.add(totalTopic)) {
      client!.subscribe(totalTopic, MqttQos.exactlyOnce);
    }
    final List<Function(String)> callbacks =
        onDataReceivedArray.putIfAbsent(totalTopic, () => []);
    if (!callbacks.contains(onDataReceived)) {
      callbacks.add(onDataReceived);
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
    _subscribe(totalTopic, onDataReceived);
  }

  // metodo per la sottoscizione ad un topic
  // senza topicSurName
  // onDataReceived: metodo che viene invocato quando viene ricevuto un messaggio
  void subscribeToGenericTopic(
      {required String totalTopic, required Function(String) onDataReceived}) {
    // String totalTopic =
    //     "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    _subscribe(totalTopic, onDataReceived);
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
      _requestedTopics.remove(totalTopic);
      client?.unsubscribe(totalTopic);
      onDataReceivedArray.remove(totalTopic);
    }
  }

  // metodo per la rimozione della sottoscizione ad un topic
  // senza topicSurName
  void unsubscribeToGenericTopic({required String totalTopic}) {
    // String totalTopic =
    //     "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    if (onDataReceivedArray.containsKey(totalTopic)) {
      print('MQTTClientWrapper::UnSubscribing to the $totalTopic topic');
      _requestedTopics.remove(totalTopic);
      client?.unsubscribe(totalTopic);
      onDataReceivedArray.remove(totalTopic);
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

    print('MQTTClientWrapper::Publishing message to topic $totalTopic');
    client!.publishMessage(totalTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  // metodo per la pubblicazione di un messaggio
  // senza topicSurName
  // messageData: ModelData da inviare
  void publishGenericMessage(
      {required String totalTopic, required String messageData}) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    // String totalTopic =
    //     "$topicBase/${remoteConnection!.remoteDomain}/$topicSurName";
    builder.addString(messageData);

    print('MQTTClientWrapper::Publishing message to topic $totalTopic');
    client!.publishMessage(totalTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    String subTopic =
        topic.substring(topic.indexOf('/', topic.indexOf('/') + 1) + 1);
    if (!subscribedTopicList.contains(topic)) {
      subscribedTopicList.add(topic);
      subscribedSubTopicList.add(subTopic);
    }
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
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    // if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
    //   print('MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    // }
    subscribedTopicList = [];
    subscribedSubTopicList = [];
    _requestedTopics.clear();
    if (connectionAllowed) {
      connectMqttClient();
    } else {
      notifyListeners('connectionState.disconnected');
      remoteConnection!.connectionState(false);
    }

    // if (reconnect) {
    //   _connectClient();
    // }
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    _listenClient();
    // if (_statusRequest) {
    //   _getstatus();
    // }
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    // se devo mando il token
    if (isTokenToSend) {
      String messageData = '{"token": "${remoteConnection!.token}"}';
      publishMessage(topicSurName: 'request/set', messageData: messageData);
      isTokenToSend = false;
    }
    notifyListeners('connectionState.connected');
    remoteConnection!.connectionState(true);
  }

  void _onAutoReconnect() async {
    if (!connectionAllowed) {
      print(
          'MQTTClientWrapper::OnRiconnect ${remoteConnection!.connectionPresent}');
      client!.autoReconnect = false;
      client!.disconnect();
      //  connect('mqtt_user', 'mqtt_user');
    } else {
      connectionState = MqttCurrentConnectionState.CONNECTING;
      print(
          'MQTTClientWrapper::OnRiconnect client callback - Client riconnection was in progress');
      notifyListeners('connectionState.reconnecting');
    }
  }

  void _onAutoReconnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnRiconnected client callback - Client riconnection was sucessful');
    notifyListeners('connectionState.reconnected');
  }

  void toggleState() {
    if (connectionStateCheck()) {
      // connectionState = MqttCurrentConnectionState.TOGGLE_DISCONNECTED;
      // reconnect = false;
      client!.autoReconnect = false;
      wrapperState = MqttWrapperState.INACTIVE;
      client!.disconnect();
      //  connect('mqtt_user', 'mqtt_user');
    } else {
      wrapperState = MqttWrapperState.ACTIVE;
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
        remote == (await remoteConnection!.checkLocal())) {
      if (removeToken) {
        String messageData = '{"token": "remove"}';
        publishMessage(topicSurName: 'request/set', messageData: messageData);
        removeToken = false;
      }
      client!.autoReconnect = false;
      client!.disconnect();
      //  connect('mqtt_user', 'mqtt_user');
    } else if (!connectionStateCheck() && remoteConnection!.connectionPresent) {
      connectMqttClient();
    }
  }

  void sendToken() {
    isTokenToSend = true;
  }

  bool connectionStateCheck() {
    if (connectionState == MqttCurrentConnectionState.CONNECTING ||
        connectionState == MqttCurrentConnectionState.CONNECTED) {
      return true;
    }
    return false;
  }

  bool errorDetectedOrForced() {
    if (connectionState == MqttCurrentConnectionState.ERROR_WHEN_CONNECTING) {
      return true;
    }
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
