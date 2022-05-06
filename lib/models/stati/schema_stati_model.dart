// import 'package:gestione_domotica/models/logging.dart';
import 'dart:core';

import 'package:gestione_domotica/models/stati/stati_layer.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:flutter/material.dart';
//import 'package:gestione_domotica/repositories/multi_message_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';
//import 'package:time_range_picker/time_range_picker.dart';
import 'dart:convert';

import 'package:universal_html/html.dart';

// import 'package:logger/logger.dart';

const String topicSurName = "stati";

final factories = <String, Object Function(int id)>{
  'Stato': (id) => StatoModel(id: id),
  'StatoAllarme': (id) => StatoAllarme(id: id),
  'StatoClima': (id) => StatoClima(id: id)
};

/// Classe che contiene la gestione degli allarmi
// ignore: mixin_inherits_from_not_object
class SchemaStatiModel with ChangeNotifier {
  // costruttori
  SchemaStatiModel({required this.id})
      : this.nome = topicSurName,
        super() {
    _setupMqtt();
    schemaRepository = SchemaRepository();
    schemaRepository!.addListener(_getDati);
    keepAliveProvider = KeepAliveProvider();
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
  List<StatoModel> stati = [];
  Image? statiBack;
  MQTTClientWrapper? mqttClientWrapper;
  SchemaRepository? schemaRepository;
  String _nome = '';
  List<Map<String, dynamic>> waitingStatoStato = [];
  KeepAliveProvider? keepAliveProvider;

  // final log = logger(SchemaStatiModel);

  //metodi
  Future<void> _getDati() async {
    _getSchemaStato();
    notifyListeners();
  }

  StatoModel? getStato(id) {
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

  List<StatoModel> getModel(String tipoStato) {
    List<StatoModel> tmpStatiList = [];
    for (dynamic stato in stati) {
      if ((stato).toString() == "Instance of '${tipoStato}'") {
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

  // Future<void> _getSchemaAllarme() async {
  //   Map<String, dynamic> tmpSchema = await schemaRepository!.schema;
  //   if (tmpSchema.containsKey(topicSurName)) {
  //     List listStati = tmpSchema[topicSurName];
  //     if (listStati.isNotEmpty) {
  //       for (var element in listStati) {
  //         id = element['id'];
  //         nome = element['nome'];
  //         icona = element['icona'] != null
  //             ? IconData(element['icona']['codePoint'],
  //                 fontFamily: element['icona']['fontFamily'])
  //             : Icons.power_settings_new_outlined;
  //         colore = element['colore'] != null
  //             ? HexColor.fromHex(element['colore'])
  //             : Colors.black;
  //         if (element.containsKey('timers')) {
  //           timers = TimerAttivazioni.fromJson(element);
  //           keepAliveProvider = KeepAliveProvider();
  //           getTimerFromRemote();
  //           keepAliveProvider?.addListener(getTimerFromRemote, ['Timers']);
  //         }
  //       }
  //       notifyListeners();
  //     }
  //   }
  // }

  Future<void> _getSchemaStato() async {
    Map<String, dynamic> tmpSchema = await schemaRepository!.schema;
    stati = [];
    if (tmpSchema.containsKey(topicSurName)) {
      List listStati = tmpSchema[topicSurName];
      if (listStati.isNotEmpty) {
        for (var element in listStati) {
          String tipo = element['tipo'] ?? 'StatoAllarme';
          int id = element['id'];
          if (factories.containsKey(tipo)) {
            if (tipo == 'Stato') {
              stati.add(StatoModel.fromJson(element));
            } else if (tipo == 'StatoAllarme') {
              stati.add(StatoAllarme.fromJson(element));
            } else if (tipo == 'StatoClima') {
              stati.add(StatoClima.fromJson(element));
            }
            stati.last.setAzioneStatoListener(callback: azioneStato);
          }
        }
        // mqttClientWrapper!.publishMessage(
        //     topicSurName: topicSurName, messageData: 'get/status');
      }
    }
    _consumeWaitingStato();
  }

  void azioneStato(int id, AzioneStato azione, String messageData) {
    mqttClientWrapper!.publishMessage(
        topicSurName: '${topicSurName}/set', messageData: messageData);
  }

  void _consumeWaitingStato() {
    for (var element in waitingStatoStato) {
      _onStatoChanged(jsonEncode(element));
    }
  }

  void getTimerFromRemote() {
    if (keepAliveProvider!.mappaValori.containsKey('Timers')) {
      keepAliveProvider?.mappaValori['Timers']!.forEach((mappaValore) {
        StatoModel stato =
            stati.firstWhere((stato) => mappaValore['id'] == stato.id);
        if (stato.timers?.timers != null &&
            stato.timers.hashCode != mappaValore['hash']) {
          // richiedi il set del timer
          String message = "{\"id\": ${stato.id}, \"timers\": \"get\"}";
          mqttClientWrapper!.publishMessage(
              topicSurName: '$topicSurName/set', messageData: message);
        }
      });
    }
  }

  // void setTimer(int indexTimer, int inizio, int fine) {
  //   if (timers != null &&
  //       indexTimer >= 0 &&
  //       indexTimer < timers!.timers.length) {
  //     timers!.setTimer(indexTimer, inizio, fine);
  //     // invio il set del timer
  //     String message =
  //         "{\"id\": 0, \"timers\": ${json.encode(timers!.toJson())}}";
  //     mqttClientWrapper!.publishMessage(
  //         topicSurName: '${topicSurName}/set', messageData: message);
  //   }
  // }

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
        onDataReceived: (messageData) => _onStatoChanged(messageData));
    // mqttClientWrapper!.publishMessage(
    //     topicSurName: '${topicSurName}/get', messageData: "{\"status\": \"\"}");
  }

  _onStatoChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('stato')) {
      List<StatoModel> localStati = [];
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
      for (StatoModel localSensore in localStati) {
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

  // _onStatoChanged(String messageData) {
  //   Map<String, dynamic> jsonData = jsonDecode(messageData);
  //   if (jsonData.containsKey('stato')) {
  //     switch (jsonData['stato']) {
  //       case "2":
  //         colore = Colors.yellow;
  //         icona = Icons.home_outlined;
  //         valore = 2;
  //         notifyListeners();
  //         break;
  //       case "1":
  //         colore = Colors.red;
  //         icona = Icons.power_settings_new_outlined;
  //         valore = 1;
  //         notifyListeners();
  //         break;
  //       case "0":
  //         colore = Colors.black;
  //         icona = Icons.power_settings_new_outlined;
  //         valore = 0;
  //         notifyListeners();
  //         break;
  //     }
  //   }
  //   if (jsonData.containsKey('timers')) {
  //     timers = TimerAttivazioni.fromJson(jsonData['timers']);
  //     print("Stato::GOT A NEW Timers $messageData");
  //     notifyListeners();
  //   }
  // }

  // void cambiaStatoAllarme() {
  //   int tmpValore = valore + 1;
  //   tmpValore = tmpValore <= 2 ? tmpValore : 0;
  //   String message = "{\"id\": 0, \"stato\": \"" + tmpValore.toString() + "\"}";
  //   mqttClientWrapper!.publishMessage(
  //       topicSurName: '${topicSurName}/set', messageData: message);
  // }

  // void addTimeRange(TimeRange timeRange) {
  //   timeRangesMap[valore] = timeRange as TimeRanges;
  // }
}
