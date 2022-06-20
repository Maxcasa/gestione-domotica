import 'package:gestione_domotica/models/hw/hw_layer.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'dart:convert';

import 'package:universal_html/html.dart';

/// Classe che contiene la gestione dell'HW
// ignore: mixin_inherits_from_not_object
class HwModel {
  // costruttori
  HwModel(
      {required this.id,
      this.nome = "HW generico",
      this.icona = Icons.power_settings_new_outlined,
      this.colore = Colors.black});

  // variabili
  int id;
  String nome = "";
  IconData icona;
  int valoreInt = 0;
  Color colore;
  bool abilitato = true;
  void Function(int, AzioneHw, String)? azioneStatoCallBack;
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

  void setAzioneHwListener({Function(int, AzioneHw, String)? callback}) {
    azioneStatoCallBack = callback;
  }

  // funzione invocata dall'interfaccia quando si cambia il valore
  void cambiaStato(int valore) {
    //Se c'è un callback da chiamare lo chiamo
    String messaggio = json.encode({'id': id, 'stato': valore});
    if (azioneStatoCallBack != null) {
      azioneStatoCallBack!(id, AzioneHw.imposta, messaggio);
    }
  }

  // conversione Json
  HwModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'],
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
      'icona': {'codePoint': icona.codePoint, 'fontFamily': icona.fontFamily}
    };
    return result;
  }
}
