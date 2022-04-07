// import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:universal_html/html.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/hex_color.dart';

/// Classe che definisce il generico sensore
class SensoreModel {
  // costruttori
  SensoreModel(
      {required this.id,
      String? nome,
      this.icona = Icons.crop_square_outlined,
      this.colore = Colors.black,
      this.size = 30,
      this.posLeft = 0,
      this.posTop = 0})
      : this.nome = nome ?? "Sensore generico";

  // variabili
  int id;
  String nome;
  IconData icona;
  Color colore;
  int valoreInt = 0;
  int size = 30;
  double posLeft = 0;
  double posTop = 0;
  bool abilitato = true;
  void Function(int, AzioneSensore, String)? azioneSensoreCallBack;

  int zIndex = 0;

  // getter & setter
  String get tipo => runtimeType.toString();

  set valore(int valore) {
    valoreInt = valore;
  }

  int get valore => valoreInt;

  int get visualSize => size * (1 + valore);

  String get text => '';

  // conversione Json
  SensoreModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'],
        valoreInt = json['valore'] ?? 0,
        colore = json['colore'] != null
            ? HexColor.fromHex(json['colore'])
            : Colors.black,
        size = json['size'] ?? 30,
        icona = json['icona'] != null
            ? IconData(json['icona']['codePoint'],
                fontFamily: json['icona']['fontFamily'])
            : Icons.crop_square_outlined,
        posLeft = double.parse(json['posLeft'] ?? '0'),
        posTop = double.parse(json['posTop'] ?? '0'),
        abilitato = json['abilitato'] ?? true;

  void setAzioneSensoreListener(
      {Function(int, AzioneSensore, String)? callback}) {
    azioneSensoreCallBack = callback;
  }

  // funzione invocata dall'interfaccia quando si cambia il valore
  void cambiaStato(int valore) {
    //Se c'è un callback da chiamare lo chiamo
    String messaggio = json.encode({'id': id, 'stato': valore});
    if (azioneSensoreCallBack != null) {
      azioneSensoreCallBack!(id, AzioneSensore.imposta, messaggio);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'nome': nome,
      'valore': valoreInt,
      'tipo': runtimeType.toString(),
      //'colore': colore,
      'size': size,
      'abilitato': abilitato,
      'icona': {'codePoint': icona.codePoint, 'fontFamily': icona.fontFamily}
    };
    return result;
  }

  void rimuovi() {
    if (azioneSensoreCallBack != null) {
      String messaggio = json.encode({'id': id, 'stato': 'rimuovi'});
      azioneSensoreCallBack!(id, AzioneSensore.rimuovi, messaggio);
    }
  }

  void disabilita() {
    abilitato = false;
    if (azioneSensoreCallBack != null) {
      String messaggio = json.encode({'id': id, 'stato': 'disabilita'});
      azioneSensoreCallBack!(id, AzioneSensore.disabilita, messaggio);
    }
  }

  void abilita() {
    abilitato = true;
    if (azioneSensoreCallBack != null) {
      String messaggio = json.encode({'id': id, 'stato': 'abilita'});
      azioneSensoreCallBack!(id, AzioneSensore.abilita, messaggio);
    }
  }

  // @override
  // String jsonEncode() {
  //   return jsonEncode(toString());
  // }

}
