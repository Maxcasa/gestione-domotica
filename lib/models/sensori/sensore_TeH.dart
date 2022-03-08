import 'dart:convert';

import 'package:flutter/material.dart';
import 'sensore_model.dart';
import 'package:gestione_domotica/models/hex_color.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreTeH extends SensoreModel {
  // costruttori
  SensoreTeH({required int id, String? nome})
      : _id = id,
        _nome = nome ?? "Sensore Luce generico",
        super(id: id, nome: nome, icona: Icons.thermostat_rounded);

  SensoreTeH.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _nome = json['nome'],
        // _valore = json['valore'] ?? 0,
        // colore = json['colore'] != null
        //     ? HexColor.fromHex(json['colore'])
        //     : Colors.black,
        super.fromJson(json) {
    icona = Icons.thermostat_rounded;
  }

  // variabili
  int _id;
  String _nome;
  // @override
  // Color colore = Colors.black;
  // @override
  List<double> valoreList = [];

  // funzione chiamata quando arriva un valore da remoto
  @override
  set valore(int valore) {
    valoreInt = valore;
    if (valoreInt > 0) {
      zIndex = 1;
    } else {
      zIndex = 0;
    }
    setColore();
  }

  void setColore() {
    if (valoreInt > 0) {
      colore = Colors.yellow;
    } else {
      colore = Colors.black;
    }
  }
}
