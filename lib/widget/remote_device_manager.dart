import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';

/// Classe WIDGET che contiene la gestione dell'icona della connessione
class RemoteDeviceManage extends StatefulWidget {
  RemoteDeviceManage({Key? key}) : super(key: key);

  @override
  _RemoteDeviceManageState createState() => _RemoteDeviceManageState();
}

class _RemoteDeviceManageState extends State<RemoteDeviceManage> {
  MQTTClientWrapper? mqttClientWrapper;
  ElevatedButton _button =
      const ElevatedButton(onPressed: null, child: Text('Non collegato'));

  @override
  void initState() {
    mqttClientWrapper = MQTTClientWrapper();
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
    if (mqttClientWrapper!.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      _subscribeTopic();
    }
    mqttClientWrapper!
        .addListener(_subscribeTopic, ['connectionState.connected']);
    super.initState();
  }

  void _subscribeTopic() {
    mqttClientWrapper!.subscribeToTopic(
        topicSurName: 'bridge/request/permit_join',
        onDataReceived: (messageData) => _permitedJoin(messageData));
    bottonePermetti();
  }

  @override
  Widget build(BuildContext context) {
    return _button;
  }

  @override
  void dispose() {
    mqttClientWrapper!
        .removeListener(_subscribeTopic, ['connectionState.connected']);
    super.dispose();
  }

  void _permitedJoin(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    // se risponde che il join è permesso
    if (jsonData.containsKey('value')) {
      if (jsonData['value']) {
        bottoneBlocca();
      } else {
        bottonePermetti();
      }
    }
  }

  void bottonePermetti() {
    setState(() {
      _button = ElevatedButton(
          onPressed: () {
            String messageData = '{"value": true, "time": 600}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'bridge/request/permit_join',
                messageData: messageData);
          },
          child: const Text('Permetti join'));
    });
  }

  void bottoneBlocca() {
    setState(() {
      _button = ElevatedButton(
          onPressed: () {
            String messageData = '{"value": false}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'bridge/request/permit_join',
                messageData: messageData);
          },
          child: const Text('Blocca join'));
    });
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
