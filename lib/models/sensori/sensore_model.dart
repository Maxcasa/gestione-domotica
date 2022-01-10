// import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:gestione_domotica/models/hex_color.dart';

/// Classe che definisce il generico sensore
class SensoreModel {
  // costruttori
  SensoreModel(
      {required this.id,
      String? nome,
      this.icona = Icons.add_alert_outlined,
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
  int valore = 0;
  int size = 30;
  double posLeft = 0;
  double posTop = 0;

  // getter & setter
  String get tipo => runtimeType.toString();

  // conversione Json
  SensoreModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'],
        valore = json['valore'] ?? 0,
        colore = json['colore'] != null
            ? HexColor.fromHex(json['colore'])
            : Colors.black,
        size = json['size'],
        icona = json['icona'] != null
            ? IconData(json['icona']['codePoint'],
                fontFamily: json['icona']['fontFamily'])
            : Icons.add_alert_outlined,
        posLeft = double.parse(json['posLeft'] ?? '0'),
        posTop = double.parse(json['posTop'] ?? '0');

  String? cambiaStato(int valore) {
    return json.encode({'id': id, 'set': valore});
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'nome': nome,
      'valore': valore,
      'tipo': runtimeType.toString(),
      //'colore': colore,
      'size': size,
      'icona': {'codePoint': icona.codePoint, 'fontFamily': icona.fontFamily}
    };
    return result;
  }

  // @override
  // String jsonEncode() {
  //   return jsonEncode(toString());
  // }

}
