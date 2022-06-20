import 'dart:core';

import 'package:gestione_domotica/models/hw/hw_layer.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:flutter/material.dart';
//import 'package:gestione_domotica/repositories/multi_message_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/models/hex_color.dart';
//import 'package:time_range_picker/time_range_picker.dart';
import 'dart:convert';

import 'package:universal_html/html.dart';

// import 'package:logger/logger.dart';

const String topicSurName = "hw_conf";

final factories = <String, Object Function(int id)>{
  'Hw': (id) => HwModel(id: id),
  'Semaforo': (id) => HwModel(id: id),
  'ReceiverHF': (id) => HwModel(id: id)
};

/// Classe che contiene la gestione degli allarmi
// ignore: mixin_inherits_from_not_object
class SchemaHwModel with ChangeNotifier {
  // costruttori
  SchemaHwModel({this.id = 0})
      : this.nome = topicSurName,
        super() {
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
  // int id;
  // String nome = "Allarme";
  // IconData icona = Icons.power_settings_new_outlined;
  // int valore = 0;
  // Color colore = Colors.black;
  // SchemaRepository? schemaRepository;
  // MQTTClientWrapper? mqttClientWrapper;
  // Map<int, TimeRanges> timeRangesMap = {};
  // KeepAliveProvider? keepAliveProvider;
  // TimerAttivazioni? timers;

  // variabili
  int id;
  String nome;
  List<HwModel> stati = [];
  MQTTClientWrapper? mqttClientWrapper;
  SchemaRepository? schemaRepository;
  // String _nome = '';
  List<Map<String, dynamic>> waitingStatoStato = [];

  // final log = logger(SchemaStatiModel);

  //metodi
  Future<void> _getDati() async {
    _getSchemaHw();
    notifyListeners();
  }

  HwModel? getStato(id) {
    // for (var i = 0; i < stati.length; i++) {
    //   if (stati[i].id == id) {
    //     return stati[id];
    //   }
    // }
    try {
      return stati.firstWhere((stato) => stato.id == id);
    } on Exception catch (e) {
      return null;
    }
  }

  List<HwModel> getModel(String tipoStato) {
    List<HwModel> tmpStatiList = [];
    for (dynamic stato in stati) {
      if ((stato).toString() == "Instance of '$tipoStato'") {
        tmpStatiList.add(stato);
      }
    }
    return tmpStatiList;
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

  Future<void> _getSchemaHw() async {
    Map<String, dynamic> tmpSchema = await schemaRepository!.schema;
    stati = [];
    if (tmpSchema.containsKey(topicSurName)) {
      List listStati = tmpSchema[topicSurName];
      if (listStati.isNotEmpty) {
        for (var element in listStati) {
          String tipo = element['tipo'] ?? 'Hw';
          if (factories.containsKey(tipo)) {
            if (tipo == 'Hw') {
              stati.add(HwModel.fromJson(element));
            } else if (tipo == 'Semaforo') {
              stati.add(HwModel.fromJson(element));
            } else if (tipo == 'ReceiverHF') {
              stati.add(HwModel.fromJson(element));
            }
            stati.last.setAzioneHwListener(callback: azioneHw);
          }
        }
        // mqttClientWrapper!.publishMessage(
        //     topicSurName: topicSurName, messageData: 'get/status');
      }
    }
    _consumeWaitingStato();
  }

  void azioneHw(int id, AzioneHw azione, String messageData) {
    mqttClientWrapper!.publishMessage(
        topicSurName: '$topicSurName/set', messageData: messageData);
  }

  void _consumeWaitingStato() {
    for (var element in waitingStatoStato) {
      _onStatoChanged(jsonEncode(element));
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
        topicSurName: '$topicSurName/get',
        onDataReceived: (messageData) => _onStatoChanged(messageData));
    // mqttClientWrapper!.publishMessage(
    //     topicSurName: '${topicSurName}/get', messageData: "{\"status\": \"\"}");
  }

  _onStatoChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('stato')) {
      List<HwModel> localStati = [];
      if (jsonData['id'] == "*") {
        localStati.addAll(stati);
      } else if (int.tryParse(jsonData['id']) != null) {
        // se passo un id intero
        if (getStato(int.parse(jsonData['id'])) != null) {
          // se è l'id è quello di un sensore registrato
          localStati.add(getStato(int.parse(jsonData['id']))!);
        } else {
          // se l'id non è registrato metto il comando in attesa
          int findIndex = waitingStatoStato
              .indexWhere((element) => element['id'] == jsonData['id']);
          if (findIndex >= 0) {
            waitingStatoStato[findIndex]['stato'] = jsonData['stato'];
          } else {
            waitingStatoStato.add(jsonData);
          }
        }
      }
      for (HwModel localSensore in localStati) {
        localSensore.valore = int.parse(jsonData['stato']);
        int findIndex = waitingStatoStato
            .indexWhere((element) => element['id'] == jsonData['id']);
        if (findIndex >= 0) {
          waitingStatoStato.removeAt(findIndex);
        }
        notifyListeners();
      }
    }
  }
}
