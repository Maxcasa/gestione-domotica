import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';

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
  Icon _icona = Icon(Icons.cloud_off_rounded, color: Colors.black, size: 20);
  bool _isAlive = true;
  Timer? timer;

  @override
  void initState() {
    mqttClientWrapper = MQTTClientWrapper();
    _multiplex();
    mqttClientWrapper!.addListener(_multiplex);

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
    mqttClientWrapper!.unsubscribeToTopic(topicSurName: 'keepalive/get');
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
    switch (mqttClientWrapper!.connectionState) {
      case MqttCurrentConnectionState.IDLE:
        _icona = Icon(Icons.cloud_off_rounded, color: Colors.black, size: 20);
        break;
      case MqttCurrentConnectionState.CONNECTING:
        _icona = Icon(Icons.cloud_rounded, color: Colors.yellow, size: 20);
        break;
      case MqttCurrentConnectionState.CONNECTED:
        _icona = Icon(Icons.cloud_rounded, color: Colors.green, size: 20);
        mqttClientWrapper!.subscribeToTopic(
            topicSurName: 'keepalive/get',
            onDataReceived: (messageData) => _keepAlive(messageData));
        timer =
            Timer.periodic(Duration(minutes: 1), (Timer t) => _checkAlive());
        break;
      case MqttCurrentConnectionState.DISCONNECTED:
        _icona = Icon(Icons.cloud_rounded, color: Colors.red, size: 20);
        break;
      case MqttCurrentConnectionState.RICONNECTING:
        _icona = Icon(Icons.cloud_rounded, color: Colors.yellow, size: 20);
        break;
      case MqttCurrentConnectionState.RICONNECTED:
        _icona = Icon(Icons.cloud_rounded, color: Colors.green, size: 20);
        break;
      case MqttCurrentConnectionState.ERROR_WHEN_CONNECTING:
        _icona = Icon(Icons.error_outline, color: Colors.red, size: 20);
        break;
    }
    setState(() {});
  }

  _connected() {
    setState(() {
      _icona = Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
    });
  }

  _connecting() {
    setState(() {
      _icona = Icon(Icons.cloud_outlined, color: Colors.yellow, size: 20);
    });
  }

  _disconnected() {
    setState(() {
      _icona = Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
    });
  }

  _disconnecting() {
    setState(() {
      _icona = Icon(Icons.cloud_off_outlined, color: Colors.yellow, size: 20);
    });
  }

  _riconnect() {
    setState(() {
      _icona = Icon(Icons.cloud_outlined, color: Colors.yellow, size: 20);
    });
  }

  _riconnected() {
    setState(() {
      _icona = Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
    });
  }

  _errore() {
    setState(() {
      _icona = Icon(Icons.error_outline, color: Colors.red, size: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _icona,
      onPressed: () {
        mqttClientWrapper!.toggleState();
      },
    );
  }

  void _keepAlive(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    // se risponde che OK è vivo altrimenti è morto e provo a riconnettere
    if (!(jsonData.containsKey('state')) && (jsonData['state'] != 'OK')) {
      _isAlive = true;
    }
  }

  void _checkAlive() {
    // se non è vivo disconnetto
    if (!(_isAlive)) {
      mqttClientWrapper!.disconnect();
    } else {
      _isAlive = false;
      mqttClientWrapper!.publishMessage(
          topicSurName: 'keepalive/set', messageData: '{"stato": "OK"}');
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
