import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
import 'package:gestione_domotica/repositories/multi_message_provider.dart';

/// Classe WIDGET che contiene la gestione dell'icona della connessione
class ConnectionIcon extends StatefulWidget {
  //ConnectionIcon({Key? key}) : super(key: key);
  static const ConnectionIcon _instance = ConnectionIcon._internal();

  factory ConnectionIcon() {
    return _instance;
  }

  const ConnectionIcon._internal({Key? key}) : super(key: key);

  @override
  _ConnectionIconState createState() => _ConnectionIconState();
}

class _ConnectionIconState extends State<ConnectionIcon> {
  MQTTClientWrapper? mqttClientWrapper;
  Icon _iconaConn = Icon(Icons.wifi_rounded, color: Colors.black, size: 20);
  // Icon _iconaLoc = Icon(Icons.cloud_off_rounded, color: Colors.black, size: 20);
  Icon _iconaLoc = Icon(Icons.home_rounded, color: Colors.black, size: 20);
  Icon _iconaView = Icon(Icons.home_rounded, color: Colors.black, size: 20);
  bool _isAlive = true;
  Timer? timer;
  KeepAliveProvider? keepAliveProvider;

  @override
  void initState() {
    mqttClientWrapper = MQTTClientWrapper();
    _multiplex();
    mqttClientWrapper!.addListener(_multiplex);
    keepAliveProvider = KeepAliveProvider();

    // mqttClientWrapper!.addListener(_connected, ['connectionState.connected']);
    // mqttClientWrapper!.addListener(_connecting, ['connectionState.connecting']);
    // mqttClientWrapper!
    //     .addListener(_disconnected, ['connectionState.disconnected']);
    // mqttClientWrapper!
    //     .addListener(_disconnecting, ['connectionState._disconnecting']);
    // mqttClientWrapper!.addListener(_riconnect, ['connectionState.riconnect']);
    // mqttClientWrapper!
    //     .addListener(_riconnected, ['connectionState.riconnected']);
    // mqttClientWrapper!.addListener(_errore, ['connectionState.error']);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    mqttClientWrapper!.removeListener(_multiplex);
    mqttClientWrapper!.unsubscribeToTopic(topicSurName: 'request/get');
    // mqttClientWrapper!
    //     .removeListener(_connected, ['connectionState.connected']);
    // mqttClientWrapper!
    //     .removeListener(_connecting, ['connectionState.connecting']);
    // mqttClientWrapper!
    //     .removeListener(_disconnected, ['connectionState.disconnected']);
    // mqttClientWrapper!
    //     .removeListener(_disconnecting, ['connectionState._disconnecting']);
    // mqttClientWrapper!
    //     .removeListener(_riconnect, ['connectionState.riconnect']);
    // mqttClientWrapper!
    //     .removeListener(_riconnected, ['connectionState.riconnected']);
    // mqttClientWrapper!.removeListener(_errore, ['connectionState.error']);
    super.dispose();
  }

  void _multiplex() {
    timer?.cancel();
    setState(() {
      switch (mqttClientWrapper!.connectionState) {
        case MqttCurrentConnectionState.IDLE:
          _iconaConn =
              Icon(Icons.wifi_off_rounded, color: Colors.black, size: 20);
          if (mqttClientWrapper!.remote) {
            _iconaLoc =
                Icon(Icons.cloud_off_rounded, color: Colors.black, size: 20);
          } else {
            _iconaLoc = Icon(Icons.home_rounded, color: Colors.black, size: 20);
          }
          break;
        case MqttCurrentConnectionState.CONNECTING:
          _iconaConn = Icon(Icons.wifi_rounded, color: Colors.yellow, size: 20);
          if (mqttClientWrapper!.remote) {
            _iconaLoc =
                Icon(Icons.cloud_rounded, color: Colors.yellow, size: 20);
          } else {
            _iconaLoc =
                Icon(Icons.home_rounded, color: Colors.yellow, size: 20);
          }
          break;
        case MqttCurrentConnectionState.CONNECTED:
          _iconaConn = Icon(Icons.wifi_rounded, color: Colors.green, size: 20);
          if (mqttClientWrapper!.remote) {
            _iconaLoc =
                Icon(Icons.cloud_rounded, color: Colors.green, size: 20);
          } else {
            _iconaLoc = Icon(Icons.home_rounded, color: Colors.green, size: 20);
          }
          mqttClientWrapper!.subscribeToTopic(
              topicSurName: 'request/get',
              onDataReceived: (messageData) => _keepAlive(messageData));
          timer =
              Timer.periodic(Duration(minutes: 1), (Timer t) => _checkAlive());
          MultiMessageProvider multiMessageProvider = MultiMessageProvider();
          multiMessageProvider.addMessage(
              'request/set', "{\"status\": \"stati\"}", ['stati/get']);
          multiMessageProvider.addMessage(
              'request/set', "{\"status\": \"sensori\"}", ['sensori/get']);

          break;
        case MqttCurrentConnectionState.DISCONNECTED:
          _iconaConn =
              Icon(Icons.wifi_off_rounded, color: Colors.black, size: 20);
          if (mqttClientWrapper!.remote) {
            _iconaLoc =
                Icon(Icons.cloud_off_rounded, color: Colors.black, size: 20);
          } else {
            _iconaLoc = Icon(Icons.home_rounded, color: Colors.black, size: 20);
          }
          break;
        // case MqttCurrentConnectionState.TOGGLE_DISCONNECTED:
        //   _iconaConn =
        //       Icon(Icons.wifi_off_rounded, color: Colors.black, size: 20);
        //   if (mqttClientWrapper!.remote) {
        //     _iconaLoc =
        //         Icon(Icons.cloud_off_rounded, color: Colors.black, size: 20);
        //   } else {
        //     _iconaLoc = Icon(Icons.home_rounded, color: Colors.black, size: 20);
        //   }
        //   break;
        // case MqttCurrentConnectionState.RICONNECTING:
        //   _iconaConn = Icon(Icons.wifi_rounded, color: Colors.yellow, size: 20);
        //   if (mqttClientWrapper!.remote) {
        //     _iconaLoc =
        //         Icon(Icons.cloud_rounded, color: Colors.yellow, size: 20);
        //   } else {
        //     _iconaLoc =
        //         Icon(Icons.home_rounded, color: Colors.yellow, size: 20);
        //   }
        //   break;
        // case MqttCurrentConnectionState.RICONNECTED:
        //   _iconaConn = Icon(Icons.wifi_rounded, color: Colors.green, size: 20);
        //   if (mqttClientWrapper!.remote) {
        //     _iconaLoc =
        //         Icon(Icons.cloud_rounded, color: Colors.green, size: 20);
        //   } else {
        //     _iconaLoc = Icon(Icons.home_rounded, color: Colors.green, size: 20);
        //   }
        //   break;
        case MqttCurrentConnectionState.ERROR_WHEN_CONNECTING:
          _iconaConn = Icon(Icons.error_outline, color: Colors.red, size: 20);
          if (mqttClientWrapper!.remote) {
            _iconaLoc =
                Icon(Icons.cloud_off_rounded, color: Colors.red, size: 20);
          } else {
            _iconaLoc = Icon(Icons.home_rounded, color: Colors.red, size: 20);
          }
          break;
      }

      // _iconaView = mqttClientWrapper!.remote ? _icona
    });
  }

  _connected() {
    setState(() {
      _iconaConn = Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
    });
  }

  _connecting() {
    setState(() {
      _iconaConn = Icon(Icons.cloud_outlined, color: Colors.yellow, size: 20);
    });
  }

  _disconnected() {
    setState(() {
      _iconaConn = Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
    });
  }

  _disconnecting() {
    setState(() {
      _iconaConn =
          Icon(Icons.cloud_off_outlined, color: Colors.yellow, size: 20);
    });
  }

  _riconnect() {
    setState(() {
      _iconaConn = Icon(Icons.cloud_outlined, color: Colors.yellow, size: 20);
    });
  }

  _riconnected() {
    setState(() {
      _iconaConn = Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
    });
  }

  _errore() {
    setState(() {
      _iconaConn = Icon(Icons.error_outline, color: Colors.red, size: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
        icon: _iconaConn,
        onPressed: () {
          mqttClientWrapper!.toggleState();
        },
      ),
      IconButton(
        icon: _iconaLoc,
        onPressed: () {
          mqttClientWrapper!.toggleState();
        },
      ),
    ]);
  }

  void _keepAlive(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    // se risponde che OK è vivo altrimenti è morto e provo a riconnettere
    if (!(jsonData.containsKey('keepalive')) &&
        (jsonData['keepalive'] != 'OK')) {
      _isAlive = true;
    }
    if (jsonData.containsKey('TeH')) {
      keepAliveProvider!.impostaTeH(jsonData['TeH']);
    }
  }

  void _checkAlive() {
    // se non è vivo disconnetto
    if (!(_isAlive)) {
      mqttClientWrapper!.disconnect();
    } else {
      _isAlive = false;
      mqttClientWrapper!.publishMessage(
          topicSurName: 'request/set', messageData: '{"keepalive": "OK"}');
    }
  }

  // bool connectionState() {
  //   if (mqttClientWrapper == null ||
  //       mqttClientWrapper!.connectionState !=
  //           MqttCurrentConnectionState.CONNECTED) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }
}
