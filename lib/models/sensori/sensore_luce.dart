import 'dart:convert';

import 'package:flutter/material.dart';
import 'sensore_model.dart';
import 'package:gestione_domotica/models/hex_color.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreLuce extends SensoreModel {
  // costruttori
  SensoreLuce({required int id, String? nome})
      : _id = id,
        _nome = nome ?? "Sensore Luce generico",
        super(id: id, nome: nome, icona: Icons.lightbulb_rounded);

  SensoreLuce.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _nome = json['nome'],
        // _valore = json['valore'] ?? 0,
        // colore = json['colore'] != null
        //     ? HexColor.fromHex(json['colore'])
        //     : Colors.black,
        super.fromJson(json);

  // variabili
  int _id;
  String _nome;
  @override
  Color colore = Colors.black;
  int _valore = 0;

  @override
  set valore(int valore) {
    if (valore < 0) {
      _valore = (_valore + 1) % 2;
    } else {
      _valore = valore;
    }
    if (_valore > 0) {
      colore = Colors.yellow;
    } else {
      colore = Colors.black;
    }
  }

  @override
  String? cambiaStato(int valore) {
    return jsonEncode({'id': _id, 'set': -1});
  }
}
