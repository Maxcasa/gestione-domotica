import 'dart:async';
import 'dart:convert';

import 'package:gestione_domotica/models/configurazioni/remote_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class KeepAliveProvider extends PropertyChangeNotifier<String> {
  // classe che distibuisce i messaggi keep alive
  // costruttori
  static final KeepAliveProvider _instance = KeepAliveProvider._internal();

  factory KeepAliveProvider() {
    return _instance;
  }

  KeepAliveProvider._internal() {
    mqttClientWrapper = MQTTClientWrapper();
    if (mqttClientWrapper!.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      _mqttClientListener();
    }
    mqttClientWrapper!
        .addListener(_mqttClientListener, ['connectionState.connected']);
  }

  Map<String, List<dynamic>> mappaValori = {};
  MQTTClientWrapper? mqttClientWrapper;
  bool _isAlive = true;
  int settingKeepAlive = 1;
  Timer? timer;

  void _mqttClientListener() {
    if (mqttClientWrapper!.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper!.subscribeToTopic(
          topicSurName: 'request/get',
          onDataReceived: (messageData) => _keepAlive(messageData));
      if ((mqttClientWrapper!
                  .remoteConnection!.activeConnectionData?.modeKeepAlive ??
              0) >
          0) {
        setTimer();
      }
    } else {
      mqttClientWrapper!.unsubscribeToTopic(topicSurName: 'request/get');
      timer?.cancel();
    }
  }

  // void  _connected() {
  //   setState(() {
  //     _iconaConn = Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
  //   });
  // }

  void _keepAlive(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    // se risponde che OK è vivo altrimenti è morto e provo a riconnettere
    if (jsonData.containsKey('keepalive')) {
      _isAlive = true;
      if (jsonData['keepalive'] != 'OK') {
        impostaMappaValori('Timers', jsonData['keepalive']);
      }
      if ((mqttClientWrapper!
                  .remoteConnection!.activeConnectionData?.modeKeepAlive ??
              0) >
          0) {
        setTimer();
      }
    }
    if (jsonData.containsKey('TeH')) {
      impostaMappaValori('TeH', jsonData['TeH']);
    }
  }

  void impostaMappaValori(String key, List<dynamic> valori) {
    mappaValori[key] = valori;
    notifyListeners(key);
  }

  void setTimer() {
    timer?.cancel();
    timer = Timer.periodic(
        Duration(
            minutes: mqttClientWrapper!.remoteConnection!.activeConnectionData
                    ?.intervalKeepAlive ??
                1), (Timer t) {
      // se non è vivo disconnetto
      if (_isAlive) {
        _isAlive = false;
        mqttClientWrapper!.publishMessage(
            topicSurName: 'request/set', messageData: '{"keepalive": "OK"}');
      } else {
        mqttClientWrapper!.disconnect();
      }
    });
  }
}
