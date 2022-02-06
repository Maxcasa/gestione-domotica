import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreSirena extends SensoreModel {
  // costruttori
  SensoreSirena({required int id, String? nome})
      : _id = id,
        _nome = nome ?? "Sensore Sirena generico",
        super(id: id, nome: nome, icona: Icons.notifications_on_rounded);

  SensoreSirena.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _nome = json['nome'],
        super.fromJson(json) {
    icona = Icons.notifications_on_rounded;
  }

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
  void cambiaStato(int valore) {
    _valore += valore;
    _valore %= 2;
    //Se c'è un callbck da chiamare lo chiamo
    super.cambiaStato(_valore);
    // String messaggio = json.encode({'id': id, 'stato': _valore});
    // if (azioneSensoreCallBack != null) {
    //   azioneSensoreCallBack!(id, AzioneSensore.imposta, messaggio);
    // }
  }
}
