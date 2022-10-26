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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:universal_html/html.dart';

// import 'package:logger/logger.dart';

/// Classe che contiene la gestione degli allarmi
// ignore: mixin_inherits_from_not_object
class StatoClima extends StatoModel {
  // costruttori
  StatoClima({required id, String? nome})
      : super(id: id, nome: nome ?? "Stato clima");

  // this.icona = icona ?? Icons.power_settings_new_outlined,
  //   this.valore = valore ?? 0,
  //   this.colore = colore ?? Colors.black;
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
  // int id;
  // String nome = "";
  // IconData icona = Icons.power_settings_new_outlined;
  // int valoreInt = 0;
  // Color colore = Colors.black;
  // bool abilitato = true;
  // TimerAttivazioni? timers;
  // void Function(int, AzioneStato, String)? azioneStatoCallBack;
  // SchemaRepository? schemaRepository;
  // MQTTClientWrapper? mqttClientWrapper;
  // Map<int, TimeRanges> timeRangesMap = {};
  // KeepAliveProvider? keepAliveProvider;

  //metodi
  @override
  set valore(Map<String, dynamic> valore) {
    super.valore = valore;
    valoreInt.forEach((key, value) {
      switch (value) {
        case 2:
          colore[key] = Colors.yellow;
          icona[key] = Icons.home_outlined;
          break;
        case 1:
          colore[key] = Colors.red;
          icona[key] = Icons.power_settings_new_outlined;
          break;
        case 0:
          colore[key] = Colors.black;
          icona[key] = Icons.power_settings_new_outlined;
          break;
      }
    });
    //}
    // if (jsonData.containsKey('timers')) {
    //   timers = TimerAttivazioni.fromJson(jsonData['timers']);
    //   print("Stato::GOT A NEW Timers $messageData");
    //   notifyListeners();
    // }
  }

  //int get valore => valoreInt;

  // funzione invocata dall'interfaccia quando si cambia il valore
  // @override
  // void cambiaStato(int valore, int pos) {
  //   //Se c'è un callback da chiamare lo chiamo
  //   List<int> locValore = valoreInt;
  //   if (valore > 0) {
  //     locValore[pos] += valore;
  //     locValore[pos] = locValore[pos] > 2 ? 0 : locValore[pos];
  //   }
  //   String messaggio = json.encode({'id': id, 'valore': locValore});
  //   if (azioneStatoCallBack != null) {
  //     azioneStatoCallBack!(id, AzioneStato.imposta, messaggio);
  //   }
  // }

  StatoClima.fromJson(Map<String, dynamic> json)
      :
        //_id = json['id'],
        //  _nome = json['nome'],
        super.fromJson(json);

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
