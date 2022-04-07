import 'package:flutter/material.dart';
import 'sensore_model.dart';

/// Classe che definisce il sensore di apertura porte e finestre
class SensoreInfisso extends SensoreModel {
  // costruttori
  SensoreInfisso({required int id, String? nome})
      :
        // super.id = id,
        //   nome = nome ?? "Sensore Infisso generico",
        super(
            id: id,
            nome: nome ?? "Sensore Infisso generico",
            icona: Icons.sensor_window_outlined);

  SensoreInfisso.fromJson(Map<String, dynamic> json)
      :
        //_id = json['id'],
        //  _nome = json['nome'],
        super.fromJson(json) {
    icona = Icons.sensor_window_outlined;
  }

  // variabili
  //int _id;
  //String _nome;
//  int valoreInt = 0;

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

  // @override
  // void cambiaStato(int valore) {}
  // uso la funzione padre per mandae il messaggio
}
