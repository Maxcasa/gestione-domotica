import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/hex_color.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';

/// Classe che contiene la gestione delle attivazioni allarmi
// ignore: mixin_inherits_from_not_object
class AttivazioneAllarme extends AttivazioneModel {
  // costruttori
  AttivazioneAllarme({required id, String? nome})
      : super(id: id, nome: nome ?? "Attivazione allarme", max: 2);

  //metodi

  IconData getIcona({int valore = 0}) {
    switch (valore) {
      case 2:
        return Icons.home_outlined;
      case 1:
        return Icons.power_settings_new_outlined;
      case 0:
        return Icons.power_settings_new_outlined;
    }
    return Icons.power_settings_new_outlined;
  }

  Color getColore({int valore = 0}) {
    switch (valore) {
      case 2:
        return Colors.yellow;
      case 1:
        return Colors.red;
      case 0:
        return Colors.black;
    }
    return Colors.black;
  }

  // // funzione invocata dall'interfaccia quando si cambia il valore
  // @override
  // void cambiaStato(int valore) {
  //   //Se c'è un callback da chiamare lo chiamo
  //   int locValore = valoreInt;
  //   if (valore > 0) {
  //     locValore += valore;
  //     locValore = locValore > 2 ? 0 : locValore;
  //   }
  //   String messaggio = json.encode({'id': id, 'stato': locValore});
  //   if (azioneStatoCallBack != null) {
  //     azioneStatoCallBack!(id, AzioneAttivazione.imposta, messaggio);
  //   }
  // }

  AttivazioneAllarme.fromJson(Map<String, dynamic> json)
      :
        //_id = json['id'],
        //  _nome = json['nome'],
        super.fromJson(json);
}
