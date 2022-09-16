import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';

/// Classe che contiene la gestione delle attivazioni allarmi
// ignore: mixin_inherits_from_not_object
class AttivazioneNotifica extends AttivazioneModel {
  // costruttori
  AttivazioneNotifica({required id, String? nome})
      : super(
            id: id,
            nome: nome ?? "Attivazione allarme",
            icona: Icons.alarm_rounded);

  //metodi
  set valore(int valore) {
    valoreInt = valore;
    switch (valoreInt) {
      // case 2:
      //   colore = Colors.yellow;
      //   icona = Icons.home_outlined;
      //   break;
      case 1:
        colore = Colors.red;
        icona = Icons.power_settings_new_outlined;
        break;
      case 0:
        colore = Colors.black;
        icona = Icons.power_settings_new_outlined;
        break;
    }
  }

  int get valore => valoreInt;

  AttivazioneNotifica.fromJson(Map<String, dynamic> json)
      :
        //_id = json['id'],
        //  _nome = json['nome'],
        super.fromJson(json);
}
