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
        topicSurName: 'bridge/request/get',
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
    mqttClientWrapper!.unsubscribeToTopic(topicSurName: 'bridge/request/get');
    super.dispose();
  }

  void _permitedJoin(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    // se risponde che il join è permesso
    if (jsonData.containsKey('permit_join')) {
      if (jsonData['permit_join']) {
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
            String messageData = '{"permit_join": true, "time": 600}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'bridge/request/set', messageData: messageData);
            bottoneBlocca();
          },
          child: const Text('Permetti join'));
    });
  }

  void bottoneBlocca() {
    // rimetto il bottone Permetti join dopo 10 minuti
    Future.delayed(const Duration(minutes: 10), () {
      bottonePermetti();
    });
    setState(() {
      _button = ElevatedButton(
          onPressed: () {
            String messageData = '{"permit_join": false}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'bridge/request/set', messageData: messageData);
            bottonePermetti();
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
