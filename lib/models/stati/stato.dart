import 'package:gestione_domotica/models/logging.dart';
import 'package:gestione_domotica/models/timer/timers.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:flutter/material.dart';
//import 'package:gestione_domotica/repositories/multi_message_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/timer/timers.dart';
//import 'package:time_range_picker/time_range_picker.dart';
import 'dart:convert';

import 'package:universal_html/html.dart';

// import 'package:logger/logger.dart';

const String topicSurName = "stati";

/// Classe che contiene la gestione degli allarmi
// ignore: mixin_inherits_from_not_object
class Stato with ChangeNotifier {
  // costruttori
  Stato({required this.id}) : super() {
    _setupMqtt();
    schemaRepository = SchemaRepository();
    schemaRepository!.addListener(_getDati);
    if (schemaRepository != null) {
      _getDati();
    }
    getStatus();
    // timerRepository = TimersRepository();
    // timerRepository!.addListener(_getTimer);
    // if (timerRepository != null) {
    //   _getTimer();
    // }
  }

  // variabili
  int id;
  String nome = "Allarme";
  IconData icona = Icons.power_settings_new_outlined;
  int valore = 0;
  Color colore = Colors.black;
  SchemaRepository? schemaRepository;
  MQTTClientWrapper? mqttClientWrapper;
  Map<int, TimeRanges> timeRangesMap = {};
  //Timers? timers;

  final log = logger(Stato);

  //metodi
  Future<void> _getDati() async {
    _getSchemaAllarme();
  }

  // void _getTimer() {
  //   timer = timerRepository!.getTimers('stati');
  // }

  void getStatus() {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // log.v("Creo lo Stato");
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  Future<void> _getSchemaAllarme() async {
    Map<String, dynamic> tmpSchema = await schemaRepository!.schema;
    if (tmpSchema.containsKey(topicSurName)) {
      List listStati = tmpSchema[topicSurName];
      if (listStati.isNotEmpty) {
        for (var element in listStati) {
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
        topicSurName: '${topicSurName}/get',
        onDataReceived: (messageData) => _onAllarmChanged(messageData));
    // mqttClientWrapper!.publishMessage(
    //     topicSurName: '${topicSurName}/get', messageData: "{\"status\": \"\"}");
  }

  _onAllarmChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('stato')) {
      switch (jsonData['stato']) {
        case "2":
          colore = Colors.yellow;
          icona = Icons.home_outlined;
          valore = 2;
          notifyListeners();
          break;
        case "1":
          colore = Colors.red;
          icona = Icons.power_settings_new_outlined;
          valore = 1;
          notifyListeners();
          break;
        case "0":
          colore = Colors.black;
          icona = Icons.power_settings_new_outlined;
          valore = 0;
          notifyListeners();
          break;
      }
    }
  }

  void cambiaStatoAllarme() {
    int tmpValore = valore + 1;
    tmpValore = tmpValore <= 2 ? tmpValore : 0;
    String message = "{\"id\": 0, \"stato\": \"" + tmpValore.toString() + "\"}";
    mqttClientWrapper!.publishMessage(
        topicSurName: '${topicSurName}/set', messageData: message);
  }

  // void addTimeRange(TimeRange timeRange) {
  //   timeRangesMap[valore] = timeRange as TimeRanges;
  // }
}
