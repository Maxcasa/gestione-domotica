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
        super(
            id: json['id'],
            nome: json['nome'],
            icona: Icons.window_rounded,
            posLeft: double.parse(json['posLeft'] ?? '0'),
            posTop: double.parse(json['posTop'] ?? '0'));

  // variabili
  int _id;
  String _nome;

  @override
  String? cambiaStato(int valore) {
    return null;
  }
}
