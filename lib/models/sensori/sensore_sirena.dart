import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreSirena extends SensoreModel {
  // costruttori
  SensoreSirena({required int id, String? nome, int numeroRele = 1})
      : _id = id,
        _nome = nome ?? "Sensore Sirena generico",
        super(id: id, nome: nome, icona: Icons.notifications_on_rounded);

  SensoreSirena.fromJson(Map<String, dynamic> json, {int numeroRele = 1})
      : _id = json['id'],
        _nome = json['nome'],
        azionamenti = json['azion'] ?? 0,
        super.fromJson(json) {
    icona = Icons.notifications_on_rounded;
  }

  // variabili
  int _id;
  String _nome;
  int azionamenti = 0;
  // @override
  // Color colore = Colors.black;
  // @override
  // int valoreInt = 0;
  int numeroRele = 0;

  @override
  set valore(int valore) {
    valoreInt = valore;
    setColore();
  }

  @override
  get visualSize => size * (1 + (valore & 1));

  @override
  String get text => azionamenti.toString();

  void setColore() {
    if (valoreInt == 0) {
      colore = Colors.black;
    } else if (valoreInt == 1) {
      colore = Colors.red;
    } else if (valoreInt > 1) {
      colore = Colors.yellow;
    }
  }

  @override
  void cambiaStato(int valore) {
    // se valore
    int locValore = 0;
    if (valore > 0) {
      if ((valoreInt & 1) == 1) {
        locValore &= ~1;
      } else {
        locValore |= 1;
      }
    } else if (valore < 0 && numeroRele > 1) {
      if ((valoreInt & 2) == 1) {
        locValore &= ~2;
      } else {
        locValore |= 2;
      }
    }
    // this.valore = locValore;
    //Se c'è un callbck da chiamare lo chiamo
    super.cambiaStato(locValore);
    // String messaggio = json.encode({'id': id, 'stato': _valore});
    // if (azioneSensoreCallBack != null) {
    //   azioneSensoreCallBack!(id, AzioneSensore.imposta, messaggio);
    // }
  }
}
