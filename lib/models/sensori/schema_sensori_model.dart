//import 'dart:html';

//mport 'dart:convert';
//import 'package:project_calendar/models/data_layer.dart';
//import 'azione.dart';

import 'dart:convert';

import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/model_data.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
//import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:flutter/material.dart';

const String topicSurName = "sensori/";
const String localStorage = "sensori";

final factories = <String, Object Function(int id)>{
  'Sensore': (id) => SensoreModel(id: id),
  'SensoreLuce': (id) => SensoreLuce(id: id),
  'SensoreInfisso': (id) => SensoreInfisso(id: id),
  'SensoreSirena': (id) => SensoreSirena(id: id),
};

/// Classe che gestisce l'insieme dei sensori
// ignore: mixin_inherits_from_not_object
class SchemaSensoriModel with ChangeNotifier {
  // costruttori
  SchemaSensoriModel({this.id = 0})
      : this.nome = localStorage,
        super() {
    _setupMqtt();
    _getSchemaSensori();
    _getSensoriBack();
  }

  SchemaSensoriModel.fromListSensori(
      {required this.id, String? nome, required List<SensoreModel> sensori})
      : this.nome = nome ?? '',
        super() {
    this.sensori.addAll(sensori);
    _setupMqtt();
    //saveSchemaSensori();
  }

  // variabili
  int id;
  String nome;
  List<SensoreModel> sensori = [];
  Image? sensoriBack;
  MQTTClientWrapper? mqttClientWrapper;
  String _nome = '';

  // getter e setter
  SensoreModel getSensore(id) =>
      sensori.singleWhere((sensore) => sensore.id == id);

  Future<List<SensoreModel>> getSensori() async {
    if (sensori.isEmpty) {
      await _getSchemaSensori();
    }
    return sensori;
  }

  Future<Image?> getSensoriBack() async {
    if (sensoriBack == null) {
      await _getSensoriBack();
    }
    return sensoriBack;
  }

  //metodi
  Future<void> _getSchemaSensori() async {
    List listSensori = (await SchemaRepository().schema)['sensori'];
    if (listSensori.isNotEmpty) {
      for (var element in listSensori) {
        String tipo = element['tipo'] ?? 'Semnsore';
        int id = element['id'];
        if (factories.containsKey(tipo)) {
          if (tipo == 'Sensore') {
            sensori.add(SensoreModel.fromJson(element));
          } else if (tipo == 'SensoreLuce') {
            sensori.add(SensoreLuce.fromJson(element));
          } else if (tipo == 'SensoreInfisso') {
            sensori.add(SensoreInfisso.fromJson(element));
          }
        }
      }
      // mqttClientWrapper!.publishMessage(
      //     topicSurName: topicSurName, messageData: 'get/status');
    }
    notifyListeners();
  }

  //metodi
  Future<void> _getSensoriBack() async {
    sensoriBack = await SchemaRepository().sensoriBack;
  }

  void _setupMqtt() {
    mqttClientWrapper = MQTTClientWrapper();
    if (mqttClientWrapper!.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      _subscribeTopic();
    }
    mqttClientWrapper!
        .addListener(_subscribeTopic, ['connectionState.connected']);
  }

  void _subscribeTopic() {
    mqttClientWrapper!.subscribeToTopic(
        topicSurName: topicSurName,
        onDataReceived: (messageData) => _onSensorChanged(messageData));
  }

  _onSensorChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('get')) {
      getSensore(jsonData['id']).valore = jsonData['get'];
      notifyListeners();
    }
    if (jsonData.containsKey('set')) {
      getSensore(jsonData['id']).valore = jsonData['set'];
      notifyListeners();
    }
    // if (jsonData.containsKey('set_status')) {
    //   getSensore(jsonData['id']).valore = jsonData['set'];
    //   sensori = [];
    //   jsonData['set_status']?.forEach((sensore) {
    //     _localFileRepository.addSensoreFromJson(sensore);
    //   });
    //   saveSchemaSensori();
    //   notifyListeners();
    // }
  }

  void cambiaStatoSensore(int id) {
    String? messageData = getSensore(id).cambiaStato(1);
    if (messageData != null) {
      mqttClientWrapper!
          .publishMessage(topicSurName: topicSurName, messageData: messageData);
    }
  }

  int getMaxIdSensore() {
    // final ids = _storage.keys.toList()..sort();
    // final id = (ids.length == 0) ? 1 : ids.last + 1;
    int maxIdAzione = 0;
    for (var element in sensori) {
      if (element.id > maxIdAzione) {
        maxIdAzione = element.id;
      }
    }

    return maxIdAzione;
  }

  // operator ==(Plan other) {
  //   return false;
  // }

  void saveSchemaSensori() {
    SchemaRepository().saveSchema();
  }

  // conversione Json
  SchemaSensoriModel.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.nome = json['name'] ?? '' {
    // json['sensori']?.forEach((sensore) {
    //   _localFileRepository.addSensoreFromJson(sensore);
    // });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'sensori': sensori
          .map<Map<String, dynamic>>((sensore) => sensore.toJson())
          .toList(),
    };
  }
}
