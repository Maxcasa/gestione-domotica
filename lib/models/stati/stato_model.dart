//import 'package:gestione_domotica/models/logging.dart';
import 'package:gestione_domotica/models/stati/stati_layer.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';
//import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
//import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:flutter/material.dart';
//import 'package:gestione_domotica/repositories/multi_message_provider.dart';
//import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';
//import 'package:time_range_picker/time_range_picker.dart';
import 'dart:convert';

import 'package:universal_html/html.dart';

// import 'package:logger/logger.dart';

/// Classe che contiene la gestione degli allarmi
// ignore: mixin_inherits_from_not_object
class StatoModel {
  // costruttori
  StatoModel(
      {required this.id,
      this.nome = "Stato generico",
      this.icona = Icons.power_settings_new_outlined,
      this.colore = Colors.black});
  // : super() {
  //   _setupMqtt();
  //   schemaRepository = SchemaRepository();
  //   schemaRepository!.addListener(_getDati);
  //   keepAliveProvider = KeepAliveProvider();
  //   if (schemaRepository != null) {
  //     _getDati();
  //   }
  //   getStatus();
  //   // timerRepository = TimersRepository();
  //   // timerRepository!.addListener(_getTimer);
  //   // if (timerRepository != null) {
  //   //   _getTimer();
  //   // }
  // }

  // variabili
  int id;
  String nome = "";
  IconData icona;
  int valoreInt = 0;
  Color colore;
  bool abilitato = true;
  List<int> operatori = [0, 0];
  TimerAttivazioni? timers;
  void Function(int, AzioneStato, String)? azioneStatoCallBack;
  // SchemaRepository? schemaRepository;
  // MQTTClientWrapper? mqttClientWrapper;
  // Map<int, TimeRanges> timeRangesMap = {};
  // KeepAliveProvider? keepAliveProvider;

  //metodi
  // getter & setter
  String get tipo => runtimeType.toString();

  set valore(int valore) {
    valoreInt = valore;
  }

  int get valore => valoreInt;

  void setAzioneStatoListener({Function(int, AzioneStato, String)? callback}) {
    azioneStatoCallBack = callback;
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

  // funzione invocata dall'interfaccia quando si cambia il valore
  void cambiaStato(int valore) {
    //Se c'è un callback da chiamare lo chiamo
    String messaggio = json.encode({'id': id, 'valore': valore});
    if (azioneStatoCallBack != null) {
      azioneStatoCallBack!(id, AzioneStato.imposta, messaggio);
    }
  }

  // conversione Json
  StatoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'],
        icona = json['icona'] != null
            ? IconData(json['icona']['codePoint'],
                fontFamily: json['icona']['fontFamily'])
            : Icons.power_settings_new_outlined,
        colore = json['colore'] != null
            ? HexColor.fromHex(json['colore'])
            : Colors.black,
        operatori = json['oper'] ?? [0, 0],
        abilitato = json['abilitato'] ?? 0,
        timers = json.containsKey('timers')
            ? TimerAttivazioni.fromJson(json)
            : TimerAttivazioni();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'nome': nome,
      'valore': valoreInt,
      'tipo': runtimeType.toString(),
      //'colore': colore,
      // 'size': size,
      'abilitato': abilitato,
      'oper': operatori,
      'icona': {'codePoint': icona.codePoint, 'fontFamily': icona.fontFamily}
    };
    return result;
  }

  // void getTimerFromRemote() {
  //   if (keepAliveProvider!.mappaValori.containsKey('Timers') &&
  //       keepAliveProvider?.mappaValori['Timers']![0]['id']! == id &&
  //       timers?.timers != null) {
  //     if (timers.hashCode !=
  //         keepAliveProvider?.mappaValori['Timers']![0]['hash']) {
  //       // richiedi il set del timer
  //       String message = "{\"id\": 0, \"timers\": \"get\"}";
  //       mqttClientWrapper!.publishMessage(
  //           topicSurName: '${topicSurName}/set', messageData: message);
  //     }
  //   }
  // }

  void setTimer(List<int> multiInit, List<int> indexTimer) {
    if (timers != null &&
        indexTimer[0] >= 0 &&
        indexTimer[0] < timers!.timers.length) {
      timers!.setTimer(indexTimer, multiInit);
      // invio il set del timer
      String messaggio =
          "{\"id\": 0, \"timers\": ${json.encode(timers!.toJson())}}";
      if (azioneStatoCallBack != null) {
        azioneStatoCallBack!(id, AzioneStato.imposta, messaggio);
      }
      // mqttClientWrapper!.publishMessage(
      //     topicSurName: '${topicSurName}/set', messageData: message);
    }
  }

  void attivaTimer(int indexTimer, bool attiva) {
    timers!.attivaTimer(indexTimer, attiva);
    // invio il set del timer
    String messaggio =
        "{\"id\": 0, \"timers\": ${json.encode(timers!.toJson())}}";
    if (azioneStatoCallBack != null) {
      azioneStatoCallBack!(id, AzioneStato.imposta, messaggio);
    }
  }

  // cambiaStato(String messageData) {
  //   Map<String, dynamic> jsonData = jsonDecode(messageData);
  //   if (jsonData.containsKey('valore')) {
  //     switch (jsonData['valore']) {
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
