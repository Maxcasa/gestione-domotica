//import 'dart:html';

//mport 'dart:convert';
//import 'package:project_calendar/models/data_layer.dart';
//import 'azione.dart';

import 'dart:convert';

import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:gestione_domotica/models/model_data.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
//import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:flutter/material.dart';

const String topicSurName = "attivazioni";
// const String localStorage = "sensori";

final factories = <String, Object Function(int id)>{
  'Attivazione': (id) => AttivazioneModel(id: id),
  'Allarme': (id) => AttivazioneAllarme(id: id),
  'Notifica': (id) => AttivazioneNotifica(id: id),
};

/// Classe che gestisce l'insieme delle attivazioni di sensori e stati
// ignore: mixin_inherits_from_not_object
class SchemaAttivazioniModel {
  // costruttori
  static final SchemaAttivazioniModel _instance =
      SchemaAttivazioniModel._internal();

  factory SchemaAttivazioniModel() {
    return _instance;
  }

  // costruttori
  SchemaAttivazioniModel._internal({this.id = 0})
      : this.nome = topicSurName,
        super() {
    schemaRepository = SchemaRepository();
    schemaRepository!.addListener(_getDati);
    if (schemaRepository != null) {
      _getDati();
    }
  }

  // SchemaSensoriModel.fromListSensori(
  //     {required this.id, String? nome, required List<SensoreModel> sensori})
  //     : this.nome = nome ?? '',
  //       super() {
  //   this.sensori.addAll(sensori);
  //   _setupMqtt();
  //   //saveSchemaSensori();
  // }

  // variabili
  int id;
  String nome;
  List<AttivazioneModel>? attivazioni;
  SchemaRepository? schemaRepository;
  String _nome = '';
  List<Map<String, dynamic>> waitingAttivazioneStato = [];
  KeepAliveProvider? keepAliveProvider;

  // getter e setter
  AttivazioneModel? getAttivazione(id) {
    if (attivazioni != null) {
      for (var i = 0; i < attivazioni!.length; i++) {
        if (attivazioni![i].id == id) {
          return attivazioni![id];
        }
      }
    }
    return null;
  }

  Future<List<AttivazioneModel>?> getAttivazioni() async {
    if (attivazioni == null) {
      await _getSchemaAttivazioni();
    }
    return attivazioni;
  }

  //metodi

  Future<void> _getDati() async {
    _getSchemaAttivazioni();
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

  Future<void> _getSchemaAttivazioni() async {
    Map<String, dynamic>? tmpSchema = await schemaRepository!.schema;
    if (tmpSchema != null && tmpSchema.containsKey(topicSurName)) {
      attivazioni = [];
      List listAttivazioni = tmpSchema[topicSurName];
      if (listAttivazioni.isNotEmpty) {
        for (var element in listAttivazioni) {
          String tipo = element['nome'] ?? 'Attivazione';
          int id = element['id'];
          if (factories.containsKey(tipo)) {
            if (tipo == 'Attivazione') {
              attivazioni!.add(AttivazioneModel.fromJson(element));
            } else if (tipo == 'Allarme') {
              attivazioni!.add(AttivazioneAllarme.fromJson(element));
            } else if (tipo == 'Notifica') {
              attivazioni!.add(AttivazioneNotifica.fromJson(element));
            }
          }
        }
        // mqttClientWrapper!.publishMessage(
        //     topicSurName: topicSurName, messageData: 'get/status');
      }
    }
  }

  //metodi

  // conversione Json
  SchemaAttivazioniModel.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.nome = json['name'] ?? '' {
    // json['sensori']?.forEach((sensore) {
    //   _localFileRepository.addSensoreFromJson(sensore);
    // });
  }

  Map<String, dynamic>? toJson() {
    if (attivazioni != null) {
      return {
        'id': id,
        'name': nome,
        'attivazioni': attivazioni!
            .map<Map<String, dynamic>>((sensore) => sensore.toJson())
            .toList(),
      };
    } else {
      return null;
    }
  }
}
