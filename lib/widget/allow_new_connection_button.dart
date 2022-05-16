import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:gestione_domotica/models/configurazioni/remote_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';

/// Classe WIDGET che contiene la gestione per abilitare
/// il join di nuovi dispositivi al server
class AllowNewConnectionButton extends StatefulWidget {
  const AllowNewConnectionButton({Key? key}) : super(key: key);

  @override
  _AllowNewConnectionButtonState createState() =>
      _AllowNewConnectionButtonState();
}

class _AllowNewConnectionButtonState extends State<AllowNewConnectionButton> {
  RemoteConnection? remoteConnection;
  MQTTClientWrapper? mqttClientWrapper;

  int _secondiRimanenti = 60 * 5;
  bool statoAutorizza = false;
  late ElevatedButton _button;
  late Timer _timer;

  @override
  void initState() {
    remoteConnection = RemoteConnection();
    _button = ElevatedButton(
        onPressed: () {
          _setButton();
        },
        child: const Text('NON AUTORIZZA'));
    mqttClientWrapper = MQTTClientWrapper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _button,
      statoAutorizza
          ? Text('Tempo rimanente: ${_secondiRimanenti.toString()} s.')
          : const SizedBox.shrink(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setButton() {
    statoAutorizza != statoAutorizza;
    if (statoAutorizza) {
      // cosa fare per abilitare
      _button = ElevatedButton(
          onPressed: () {
            _setButton();
          },
          child: const Text('NON AUTORIZZA'));
      _timer = Timer.periodic(
          const Duration(seconds: 1),
          (Timer _timer) => setState(() {
                _secondiRimanenti--;
                if (_secondiRimanenti < 0) {
                  _setButton();
                }
              }));

      try {
        if (mqttClientWrapper!.connectionState ==
            MqttCurrentConnectionState.CONNECTED) {
          String messageData = '{"permit_connection": "true"}';
          mqttClientWrapper!.publishMessage(
              topicSurName: 'request/set', messageData: messageData);
        }
      } on Exception catch (e) {
        print('RemoteConnectionError :: $e');
      }
    } else {
      // cosa fare quando non abilito
      _button = ElevatedButton(
          onPressed: () {
            _setButton();
          },
          child: const Text('AUTORIZZA'));
      _secondiRimanenti = 60 * 5;
      _timer.cancel();
    }
  }
}
