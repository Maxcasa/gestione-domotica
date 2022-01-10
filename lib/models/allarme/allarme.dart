import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'dart:convert';

const String topicSurName = "a_out";

/// Classe che contiene la gestione degli allarmi
// ignore: mixin_inherits_from_not_object
class Allarme with ChangeNotifier {
  // costruttori
  Allarme({required this.id}) : super() {
    _setupMqtt();
    _getSchemaAllarme();
  }

  // variabili
  int id;
  String nome = "Allarme";
  IconData icona = Icons.power_settings_new_outlined;
  int valore = 0;
  Color colore = Colors.black;
  MQTTClientWrapper? mqttClientWrapper;

  //metodi
  Future<void> _getSchemaAllarme() async {
    List listAllarmi = (await SchemaRepository().schema)['sensori'];
    if (listAllarmi.isNotEmpty) {
      for (var element in listAllarmi) {
        nome = element['nome'];
        icona = element['icona'] != null
            ? IconData(element['icona']['codePoint'],
                fontFamily: element['icona']['fontFamily'])
            : Icons.power_settings_new_outlined;
        colore = element['colore'] != null
            ? HexColor.fromHex(element['colore'])
            : Colors.black;
      }
      notifyListeners();
    }
  }

  void _setupMqtt() {
    mqttClientWrapper = MQTTClientWrapper();
    if (mqttClientWrapper!.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      _subscribeTopic();
    }
    mqttClientWrapper!
        .addListener(_subscribeTopic, ['connectionState.connected']);
  }

  void _subscribeTopic() {
    mqttClientWrapper!.subscribeToTopic(
        topicSurName: topicSurName,
        onDataReceived: (messageData) => _onAllarmChanged(messageData));
    mqttClientWrapper!.publishMessage(
        topicSurName: topicSurName, messageData: "{\"status\": \"\"}");
  }

  _onAllarmChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('get')) {
      switch (jsonData['get']) {
        case "1":
          colore = Colors.red;
          valore = 1;
          notifyListeners();
          break;
        case "0":
          colore = Colors.black;
          valore = 0;
          notifyListeners();
          break;
      }
    }
  }

  void cambiaStatoAllarme() {
    String message = "{\"set\": \"" + (valore == 0 ? "1" : "0") + "\"}";
    mqttClientWrapper!
        .publishMessage(topicSurName: topicSurName, messageData: message);
  }
}
