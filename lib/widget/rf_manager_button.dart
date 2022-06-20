import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:gestione_domotica/models/configurazioni/remote_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';

/// Classe WIDGET che contiene la gestione per abilitare
/// il join di nuovi dispositivi al server
class RfManagerButton extends StatefulWidget {
  const RfManagerButton({Key? key}) : super(key: key);

  @override
  _RfManagerButtonState createState() => _RfManagerButtonState();
}

class _RfManagerButtonState extends State<RfManagerButton> {
  RemoteConnection? remoteConnection;
  MQTTClientWrapper? mqttClientWrapper;

  int _secondiRimanenti = 60;
  bool statoAutorizza = true;
  late ElevatedButton _button;
  late Timer _timer;

  @override
  void initState() {
    remoteConnection = RemoteConnection();

    mqttClientWrapper = MQTTClientWrapper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return statoAutorizza
        ? ElevatedButton(
            onPressed: () {
              _setButton(0);
            },
            child: const Text('LEGGI RF'))
        : Row(children: [
            ElevatedButton(
                onPressed: () {
                  _setButton(1);
                },
                child: const Text('SALVA')),
            ElevatedButton(
                onPressed: () {
                  _setButton(2);
                },
                child: const Text('ANNULLA')),
          ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setButton(int value) {
    switch (value) {
      case 0:
        statoAutorizza = false;
        try {
          if (mqttClientWrapper!.connectionState ==
              MqttCurrentConnectionState.CONNECTED) {
            String messageData = '{"act_rf": "0"}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'request/set', messageData: messageData);
          }
        } on Exception catch (e) {
          print('RemoteConnectionError :: $e');
        }
        break;
      case 1:
        statoAutorizza = true;
        try {
          if (mqttClientWrapper!.connectionState ==
              MqttCurrentConnectionState.CONNECTED) {
            String messageData = '{"save_rf": "0"}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'request/set', messageData: messageData);
          }
        } on Exception catch (e) {
          print('RemoteConnectionError :: $e');
        }
        break;
      case 2:
        statoAutorizza = true;
        try {
          if (mqttClientWrapper!.connectionState ==
              MqttCurrentConnectionState.CONNECTED) {
            String messageData = '{"canc_rf": "0"}';
            mqttClientWrapper!.publishMessage(
                topicSurName: 'request/set', messageData: messageData);
          }
        } on Exception catch (e) {
          print('RemoteConnectionError :: $e');
        }
        break;
    }
    setState(() {});
  }
}
