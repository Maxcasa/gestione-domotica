import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';

/// Classe che contiene la gestione delle attivazioni allarmi
// ignore: mixin_inherits_from_not_object
class AttivazioneNotifica extends AttivazioneModel {
  // costruttori
  AttivazioneNotifica({required id, String? nome})
      : super(id: id, nome: nome ?? "Attivazione notifica", max: 1);

  //metodi

  IconData getIcona({int valore = 0}) {
    return Icons.notifications_on_rounded;
  }

  Color getColore({int valore = 0}) {
    switch (valore) {
      case 1:
        return Colors.red;
      case 0:
        return Colors.black;
    }
    return Colors.black;
  }

  AttivazioneNotifica.fromJson(Map<String, dynamic> json)
      :
        //_id = json['id'],
        //  _nome = json['nome'],
        super.fromJson(json);
}
