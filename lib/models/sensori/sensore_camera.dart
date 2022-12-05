import 'dart:convert';

import 'package:flutter/material.dart';
import 'sensore_model.dart';
import 'package:gestione_domotica/models/hex_color.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreCamera extends SensoreModel {
  // costruttori
  SensoreCamera({required int id, String? nome})
      : _id = id,
        _nome = nome ?? "Sensore Camera generico",
        super(id: id, nome: nome, icona: Icons.directions_walk_rounded);

  SensoreCamera.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _nome = json['nome'],
        // _valore = json['valore'] ?? 0,
        // colore = json['colore'] != null
        //     ? HexColor.fromHex(json['colore'])
        //     : Colors.black,
        super.fromJson(json) {
    icona = Icons.directions_walk_rounded;
  }

  // variabili
  int _id;
  String _nome;

  // @override
  // Color colore = Colors.black;
  // @override
  // int valoreInt = 0;

  // funzione chiamata quando arriva un valore da remoto
  @override
  set valore(int valore) {
    valoreInt = valore;
    if (valoreInt > 0) {
      zIndex = 1;
    } else {
      zIndex = 0;
    }
    if ((valoreInt & 1) == 1) {
      colore = Colors.red;
    } else {
      colore = Colors.black;
    }
    if (valoreInt < -10 && valoreInt > -20) {
      icona = Icons.battery_alert_outlined;
      if (colore == Colors.black) {
        colore = Colors.yellow;
      }
    }
  }

  @override
  bool get sensoreVisibile => true;
}
