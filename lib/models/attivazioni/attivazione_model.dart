import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'dart:convert';

/// Classe che contiene la gestione delle attivazioni gestibili per un sensore
// ignore: mixin_inherits_from_not_object
class AttivazioneModel {
  // costruttori
  AttivazioneModel(
      {required this.id,
      this.nome = "Attivazione generica",
      this.icona = Icons.alarm_rounded,
      this.colore = Colors.black});

  // variabili
  int id;
  String nome = "";
  IconData icona;
  int valoreInt = 0;
  Color colore;
  bool abilitato = true;

  void Function(int, AzioneAttivazione, String)? azioneAttivazioneCallBack;
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

  void setAzioneAttivazioneListener(
      {Function(int, AzioneAttivazione, String)? callback}) {
    azioneAttivazioneCallBack = callback;
  }

  // funzione invocata dall'interfaccia quando si cambia il valore
  void cambiaStato(int valore) {
    //Se c'è un callback da chiamare lo chiamo
    String messaggio = json.encode({'id': id, 'stato': valore});
    if (azioneAttivazioneCallBack != null) {
      azioneAttivazioneCallBack!(id, AzioneAttivazione.imposta, messaggio);
    }
  }

  @override
  int get hashCode {
    int tmpHash = valore;
    // for (TimerAttivazione timer in timers) {
    //   tmpHash += (300 *
    //           (timers.length - timer.id!) *
    //           (timers.length - (timer.isActivated ? 2 : 1))) +
    //       timer.getSum();
    // }
    return tmpHash;
  }

  @override
  bool operator ==(Object other) =>
      other is AttivazioneModel &&
      other.runtimeType == runtimeType &&
      other.hashCode == hashCode;

  // conversione Json
  AttivazioneModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'] ?? 'Generico',
        valoreInt = json['valore'] ?? 0,
        icona = json['icona'] != null
            ? IconData(json['icona']['codePoint'],
                fontFamily: json['icona']['fontFamily'])
            : Icons.power_settings_new_outlined,
        colore = json['colore'] != null
            ? HexColor.fromHex(json['colore'])
            : Colors.black;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'nome': nome,
      'valore': valoreInt,
      'tipo': runtimeType.toString(),
      //'colore': colore,
      // 'size': size,
      'abilitato': abilitato,
      'hash': hashCode,
      'icona': {'codePoint': icona.codePoint, 'fontFamily': icona.fontFamily}
    };
    return result;
  }

  int toShortJson() {
    // Map<String, dynamic> result = {
    //   'valore': valoreInt
    //   // 'abilitato': abilitato,
    // };
    return valoreInt;
  }
}
