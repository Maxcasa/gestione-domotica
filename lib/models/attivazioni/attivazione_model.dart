import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'dart:convert';

/// Classe che contiene la gestione delle attivazioni gestibili per un sensore
// ignore: mixin_inherits_from_not_object
class AttivazioneModel {
  // costruttori
  AttivazioneModel(
      {required this.id, this.nome = "Attivazione generica", this.max = 0});

  // variabili
  int id;
  String nome = "";
  // IconData icona;
  // int valoreInt = 0;
  int max = 0;
  // Color colore;
  bool abilitato = true;

  void Function(int, AzioneAttivazione, String)? azioneAttivazioneCallBack;
  // SchemaRepository? schemaRepository;
  // MQTTClientWrapper? mqttClientWrapper;
  // Map<int, TimeRanges> timeRangesMap = {};
  // KeepAliveProvider? keepAliveProvider;

  //metodi
  // getter & setter
  String get tipo => runtimeType.toString();

  IconData getIcona({int valore = 0}) {
    return Icons.power_settings_new_outlined;
  }

  Color getColore({int valore = 0}) {
    return Colors.black;
  }

  // funzione invocata dall'interfaccia quando si cambia il valore
  // void cambiaStato(int valore) {
  //   //Se c'è un callback da chiamare lo chiamo
  //   String messaggio = json.encode({'id': id, 'stato': valore});
  //   if (azioneAttivazioneCallBack != null) {
  //     azioneAttivazioneCallBack!(id, AzioneAttivazione.imposta, messaggio);
  //   }
  // }

  // @override
  // int get hashCode {
  //   int tmpHash = valore;
  //   // for (TimerAttivazione timer in timers) {
  //   //   tmpHash += (300 *
  //   //           (timers.length - timer.id!) *
  //   //           (timers.length - (timer.isActivated ? 2 : 1))) +
  //   //       timer.getSum();
  //   // }
  //   return tmpHash;
  // }

  @override
  bool operator ==(Object other) =>
      other is AttivazioneModel &&
      other.runtimeType == runtimeType &&
      other.hashCode == hashCode;

  // conversione Json
  AttivazioneModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'] ?? 'Generico',
        max = json['max'] ?? 0;

  setFromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    nome = json['nome'] ?? nome;
    max = json['max'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {'id': id, 'nome': nome, 'max': max};
    return result;
  }
}
