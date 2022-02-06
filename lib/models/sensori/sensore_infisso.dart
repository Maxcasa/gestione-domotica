import 'package:flutter/material.dart';
import 'sensore_model.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreInfisso extends SensoreModel {
  // costruttori
  SensoreInfisso({required int id, String? nome})
      : _id = id,
        _nome = nome ?? "Sensore Infisso generico",
        super(id: id, nome: nome, icona: Icons.sensor_window_outlined);

  SensoreInfisso.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _nome = json['nome'],
        super.fromJson(json) {
    icona = Icons.sensor_window_outlined;
  }

  // variabili
  int _id;
  String _nome;
  int _valore = 0;

  @override
  set valore(int valore) {
    _valore = valore;
    if (_valore > 0) {
      colore = Colors.red;
    } else {
      colore = Colors.black;
    }
  }

  @override
  void cambiaStato(int valore) {}
}
