// import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
// import 'package:universal_html/html.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/hex_color.dart';

final factories = <String, Object Function(int id)>{
  '-1': (id) => AttivazioneModel(id: id),
  '0': (id) => AttivazioneAllarme(id: id),
  '1': (id) => AttivazioneNotifica(id: id),
};

/// Classe che definisce il generico sensore
class SensoreModel {
  // costruttori
  SensoreModel(
      {required this.id,
      String? nome,
      this.icona = Icons.crop_square_outlined,
      this.colore = Colors.black,
      this.size = 30,
      this.posLeft = 0,
      this.posTop = 0})
      : this.nome = nome ?? "Sensore generico";

  // variabili
  int id;
  String inUrl = '';
  String outUrl = '';
  String nome;
  IconData icona;
  Color colore;
  int valoreInt = 0;
  String? token;
  int size = 30;
  double posLeft = 0;
  double posTop = 0;
  bool abilitato = true;
  Map<String, dynamic> attivazioni = {};
  void Function(int, AzioneSensore, String)? azioneSensoreCallBack;

  int zIndex = 0;

  // getter & setter
  String get tipo => runtimeType.toString();

  set valore(int valore) {
    valoreInt = valore;
  }

  int get valore => valoreInt;

  int get visualSize => size * (1 + valore);

  String get text => '';

  bool get sensoreVisibile {
    if (valoreInt != 0) {
      return true;
    }
    return false;
  }

  // conversione Json
  SensoreModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        inUrl = json['in'] ?? '',
        outUrl = json['out'] ?? '',
        nome = json['nome'],
        colore = json['colore'] != null
            ? HexColor.fromHex(json['colore'])
            : Colors.black,
        size = json['size'] ?? 30,
        icona = json['icona'] != null
            ? IconData(json['icona']['codePoint'],
                fontFamily: json['icona']['fontFamily'])
            : Icons.crop_square_outlined,
        posLeft = double.parse(json['posLeft'] ?? '0'),
        posTop = double.parse(json['posTop'] ?? '0'),
        abilitato = json['abilitato'] ?? true {
    valore = json['valore'] ?? 0;
    if (json.containsKey('attiva') && json['attiva'] is Map) {
      attivazioni = json['attiva'] ?? [];
      //_getAttivazione(json['attiva']);
    } else if (json.containsKey('attivazione') && json['attivazione'] is Map) {
      attivazioni = json['attivazione'] ?? [];
      //_getAttivazione(json['attivazione']);
    }
  }

  // void _getAttivazione(List arrayAttivazioni) {
  //   attivazioni = [];
  //   for (var element in arrayAttivazioni) {
  //     int id = element['id'] ?? 0;
  //     //int id = element['id'];
  //     if (factories.containsKey(id.toString())) {
  //       if (id == -1) {
  //         attivazioni.add(AttivazioneModel.fromJson(element));
  //       } else if (id == 0) {
  //         attivazioni.add(AttivazioneAllarme.fromJson(element));
  //       } else if (id == 1) {
  //         attivazioni.add(AttivazioneNotifica.fromJson(element));
  //       }
  //       // attivazioni.last
  //       //     .setAzioneAttivazioneListener(callback: azioneAttivazione);
  //     }
  //   }
  //   //_consumeWaitingSensore();
  // }

  void setAzioneSensoreListener(
      {Function(int, AzioneSensore, String)? callback}) {
    azioneSensoreCallBack = callback;
  }

  // funzione invocata dall'interfaccia quando si cambia il valore
  void cambiaValore(int valore) {
    //Se c'è un callback da chiamare lo chiamo
    String messaggio = json.encode({'id': id, 'valore': valore});
    if (azioneSensoreCallBack != null) {
      azioneSensoreCallBack!(id, AzioneSensore.imposta, messaggio);
    }
  }

  @override
  int get hashCode {
    int tmpHash = valoreInt;
    for (int i = 0; i < attivazioni.length; i++) {
      tmpHash += 8 * i * attivazioni[i].hashCode;
    }
    return tmpHash;
  }

  @override
  bool operator ==(Object other) =>
      other is SensoreModel &&
      other.runtimeType == runtimeType &&
      other.hashCode == hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'in': inUrl,
      'out': outUrl,
      'nome': nome,
      'valore': valoreInt,
      'tipo': runtimeType.toString(),
      'posLeft': posLeft.toString(),
      'posTop': posTop.toString(),
      //'colore': colore,
      'size': size,
      'abilitato': abilitato,
      'attiva': attivazioni,
      // .map<Map<String, dynamic>>((attivazione) => attivazione.toJson())
      // .toList(),
      'icona': {'codePoint': icona.codePoint, 'fontFamily': icona.fontFamily}
    };
    return result;
  }

  Map<String, dynamic> toShortJson() {
    Map<String, dynamic> result = {
      'v': valoreInt,
      // 'abilitato': abilitato,
      'a': attivazioni
      // .map<int>((attivazione) => attivazione.toShortJson())
      // .toList()
    };
    return result;
  }

  void rimuovi() {
    if (azioneSensoreCallBack != null) {
      String messaggio = json.encode({'id': id, 'com': 'rimuovi'});
      azioneSensoreCallBack!(id, AzioneSensore.rimuovi, messaggio);
    }
  }

  void disabilita() {
    abilitato = false;
    if (azioneSensoreCallBack != null) {
      String messaggio = json.encode({'id': id, 'com': 'disabilita'});
      azioneSensoreCallBack!(id, AzioneSensore.disabilita, messaggio);
    }
  }

  void abilita() {
    abilitato = true;
    if (azioneSensoreCallBack != null) {
      String messaggio = json.encode({'id': id, 'com': 'abilita'});
      azioneSensoreCallBack!(id, AzioneSensore.abilita, messaggio);
    }
  }

  // @override
  // String jsonEncode() {
  //   return jsonEncode(toString());
  // }

}
