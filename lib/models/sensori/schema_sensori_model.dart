//import 'dart:html';

//mport 'dart:convert';
//import 'package:project_calendar/models/data_layer.dart';
//import 'azione.dart';

import 'dart:convert';

import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/model_data.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
//import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:flutter/material.dart';

const String topicSurName = "sensori";
// const String localStorage = "sensori";

final factories = <String, Object Function(int id)>{
  'Sensore': (id) => SensoreModel(id: id),
  'SensoreLuce': (id) => SensoreLuce(id: id),
  'SensoreInfisso': (id) => SensoreInfisso(id: id),
  'SensoreTeH': (id) => SensoreTeH(id: id),
  'Sirena_1': (id) => SensoreSirena(id: id, numeroRele: 1),
  'Sirena_2': (id) => SensoreSirena(id: id, numeroRele: 2),
  'SensorePresenza': (id) => SensorePresenza(id: id)
};

/// Classe che gestisce l'insieme dei sensori
// ignore: mixin_inherits_from_not_object
class SchemaSensoriModel with ChangeNotifier {
  // costruttori
  static final SchemaSensoriModel _instance = SchemaSensoriModel._internal();

  factory SchemaSensoriModel() {
    return _instance;
  }

  // costruttori
  SchemaSensoriModel._internal({this.id = 0})
      : this.nome = topicSurName,
        super() {
    schemaRepository = SchemaRepository();
    schemaRepository!.addListener(_getDati);
    if (schemaRepository != null) {
      _getDati();
    }
    _setupMqtt();
    keepAliveProvider = KeepAliveProvider();
    keepAliveProvider?.addListener(setTeH, ['TeH']);
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
  List<SensoreModel> sensori = [];
  Image? sensoriBack;
  MQTTClientWrapper? mqttClientWrapper;
  SchemaRepository? schemaRepository;
  String _nome = '';
  List<Map<String, dynamic>> waitingSensoreStato = [];
  KeepAliveProvider? keepAliveProvider;

  // getter e setter
  SensoreModel? getSensore(id) {
    for (var i = 0; i < sensori.length; i++) {
      if (sensori[i].id == id) {
        return sensori[id];
      }
    }
    return null;
  }

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

  Future<void> _getDati() async {
    _getSchemaSensori();
    _getSensoriBack();
    notifyListeners();
  }

  Future<void> _getSchemaSensori() async {
    Map<String, dynamic> tmpSchema = await schemaRepository!.schema;
    sensori = [];
    if (tmpSchema.containsKey(topicSurName)) {
      List listSensori = tmpSchema[topicSurName];
      if (listSensori.isNotEmpty) {
        for (var element in listSensori) {
          String tipo = element['tipo'] ?? 'Sensore';
          int id = element['id'];
          if (factories.containsKey(tipo)) {
            if (tipo == 'Sensore') {
              sensori.add(SensoreModel.fromJson(element));
            } else if (tipo == 'SensoreLuce') {
              sensori.add(SensoreLuce.fromJson(element));
            } else if (tipo == 'SensoreInfisso') {
              sensori.add(SensoreInfisso.fromJson(element));
            } else if (tipo == 'SensoreTeH') {
              sensori.add(SensoreTeH.fromJson(element));
            } else if (tipo == 'Sirena' || tipo == 'Sirena_1') {
              sensori.add(SensoreSirena.fromJson(element, numeroRele: 1));
            } else if (tipo == 'Sirena_2') {
              sensori.add(SensoreSirena.fromJson(element, numeroRele: 2));
            } else if (tipo == 'SensorePresenza') {
              sensori.add(SensorePresenza.fromJson(element));
            }
            sensori.last.setAzioneSensoreListener(callback: azioneSensore);
          }
        }
        // mqttClientWrapper!.publishMessage(
        //     topicSurName: topicSurName, messageData: 'get/status');
      }
    }
    _consumeWaitingSensore();
  }

  //metodi
  Future<void> _getSensoriBack() async {
    sensoriBack = await schemaRepository!.sensoriBack;
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
        topicSurName: '${topicSurName}/get',
        onDataReceived: (messageData) => _onSensorChanged(messageData));
    mqttClientWrapper!.subscribeToTopic(
        topicSurName: 'request/get',
        onDataReceived: (messageData) => _attivaSensori(messageData));
  }

  void _consumeWaitingSensore() {
    for (var element in waitingSensoreStato) {
      _onSensorChanged(jsonEncode(element));
    }
  }

  _onSensorChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('stato')) {
      List<SensoreModel> localSensori = [];
      if (jsonData['id'] == "*") {
        localSensori.addAll(sensori);
      } else if (int.tryParse(jsonData['id']) != null) {
        // se passo un id intero
        if (getSensore(int.parse(jsonData['id'])) != null) {
          // se è l'id è quello di un sensore registrato
          localSensori.add(getSensore(int.parse(jsonData['id']))!);
        } else {
          // se l'id non è registrato metto il comando in attesa
          int findIndex = waitingSensoreStato
              .indexWhere((element) => element['id'] == jsonData['id']);
          if (findIndex >= 0) {
            waitingSensoreStato[findIndex]['stato'] = jsonData['stato'];
          } else {
            waitingSensoreStato.add(jsonData);
          }
        }
      }
      for (SensoreModel localSensore in localSensori) {
        localSensore.valore = int.parse(jsonData['stato']);
        if (localSensore is SensoreSirena && jsonData.containsKey('azion')) {
          localSensore.azionamenti = int.parse(jsonData['azion']);
        }
        int findIndex = waitingSensoreStato
            .indexWhere((element) => element['id'] == jsonData['id']);
        if (findIndex >= 0) {
          waitingSensoreStato.removeAt(findIndex);
        }
        notifyListeners();
      }
    }
    // if (jsonData.containsKey('set')) {
    //   getSensore(jsonData['id']).valore = jsonData['set'];
    //   notifyListeners();
    // }
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

  void azioneSensore(int id, AzioneSensore azione, String messageData) {
    mqttClientWrapper!.publishMessage(
        topicSurName: '${topicSurName}/set', messageData: messageData);
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

  void setTeH() {
    if (keepAliveProvider != null &&
        keepAliveProvider!.mappaValori.containsKey('TeH') &&
        keepAliveProvider!.mappaValori['TeH'] != null &&
        keepAliveProvider!.mappaValori['TeH']!.isNotEmpty) {
      for (Map<String, dynamic> sensoreDaAggiornare
          in keepAliveProvider!.mappaValori['TeH']!) {
        if (getSensore(int.parse(sensoreDaAggiornare['id'])) != null &&
            getSensore(int.parse(sensoreDaAggiornare['id']))!.tipo ==
                'SensoreTeH') {
          SensoreTeH sensore =
              getSensore(int.parse(sensoreDaAggiornare['id']))! as SensoreTeH;
          sensore.valoreList = sensoreDaAggiornare['valori'];
        }
      }
      notifyListeners();
    }
  }

  // operator ==(Plan other) {
  //   return false;
  // }

  void _attivaSensori(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    // se risponde che il join è permesso
    if (jsonData.containsKey('attiva')) {
      for (var element in sensori) {
        int valoreDaAttivare = int.parse(jsonData['attiva']);
        if (valoreDaAttivare > 0) {
          valoreDaAttivare = element.attiva | valoreDaAttivare;
        } else {
          valoreDaAttivare = element.attiva & ~(-valoreDaAttivare);
        }
        if (jsonData['tipo'] == 'SensoreInfisso' && element is SensoreInfisso) {
          element.attiva = valoreDaAttivare;
        } else if (jsonData['tipo'] == 'SensorePresenza' &&
            element is SensorePresenza) {
          element.attiva = valoreDaAttivare;
        }
      }
      notifyListeners();
    }
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
