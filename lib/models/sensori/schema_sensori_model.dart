//import 'dart:html';

//mport 'dart:convert';
//import 'package:project_calendar/models/data_layer.dart';
//import 'azione.dart';

import 'dart:convert';

import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/model_data.dart';
import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
//import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:flutter/material.dart';

const String topicSurName = "sensori";
// const String localStorage = "sensori";

final factories = <String, Object Function(int id)>{
  'Atti': (id) => SensoreModel(id: id),
  'SensoreLuce': (id) => SensoreLuce(id: id),
  'SensoreInfisso': (id) => SensoreInfisso(id: id),
  'SensoreTeH': (id) => SensoreTeH(id: id),
  'Sirena_1': (id) => SensoreSirena(id: id, numeroRele: 1),
  'Sirena_2': (id) => SensoreSirena(id: id, numeroRele: 2),
  'SensorePresenza': (id) => SensorePresenza(id: id),
  'SensoreCamera': (id) => SensoreCamera(id: id)
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
    //multiMessageProvider = MultiMessageProvider();
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
  List<SensoreModel>? sensori;
  Image? sensoriBack;
  MQTTClientWrapper? mqttClientWrapper;
  SchemaRepository? schemaRepository;
  String _nome = '';
  List<Map<String, dynamic>> waitingSensoreStato = [];
  KeepAliveProvider? keepAliveProvider;
  MultiMessageProvider multiMessageProvider = MultiMessageProvider();
  bool statusRequested = false;

  // getter e setter
  SensoreModel? getSensore(id) {
    if (sensori != null) {
      for (var i = 0; i < sensori!.length; i++) {
        if (sensori![i].id == id) {
          return sensori![i];
        }
      }
    }
    return null;
  }

  Future<List<SensoreModel>?> getSensori() async {
    if (sensori == null) {
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

  List<SensoreModel> getModel(String tipoSensore) {
    List<SensoreModel> tmpSensoriList = [];
    if (sensori != null) {
      for (dynamic sensore in sensori!) {
        if (sensore.tipo == tipoSensore) {
          tmpSensoriList.add(sensore);
        }
      }
    }
    return tmpSensoriList;
  }

  //metodi

  Future<void> _getDati() async {
    _getSchemaSensori();
    _getSensoriBack();
    notifyListeners();
  }

  Future<void> _getSchemaSensori() async {
    Map<String, dynamic>? tmpSchema = await schemaRepository!.schema;
    if (tmpSchema != null && tmpSchema.containsKey(topicSurName)) {
      sensori = [];
      List listSensori = tmpSchema[topicSurName];
      if (listSensori.isNotEmpty) {
        for (var element in listSensori) {
          String tipo = element['tipo'] ?? 'Sensore';
          //int id = element['id'];
          if (factories.containsKey(tipo)) {
            if (tipo == 'Sensore') {
              sensori!.add(SensoreModel.fromJson(element));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'SensoreLuce') {
              sensori!.add(SensoreLuce.fromJson(element));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'SensoreInfisso') {
              sensori!.add(SensoreInfisso.fromJson(element));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'SensoreTeH') {
              sensori!.add(SensoreTeH.fromJson(element));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'Sirena' || tipo == 'Sirena_1') {
              sensori!.add(SensoreSirena.fromJson(element, numeroRele: 1));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'Sirena_2') {
              sensori!.add(SensoreSirena.fromJson(element, numeroRele: 2));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'SensorePresenza') {
              sensori!.add(SensorePresenza.fromJson(element));
              sensori!.last.setAzioneSensoreListener(callback: azioneSensore);
            } else if (tipo == 'SensoreCamera') {
              sensori!.add(SensoreCamera.fromJson(element));
              sensori!.last.setAzioneSensoreListener(callback: azioneCamera);
            }
          }
        }
        // mqttClientWrapper!.publishMessage(
        //     topicSurName: topicSurName, messageData: 'get/status');
        print('SchemaSensoriModel:: sensori caricati');
        // Se è il caso richiedo lo stato
        if (statusRequested) {
          requestStatus();
        }
      }
    }
    _consumeWaitingSensore();
  }

  @override
  int get hashCode {
    int tmpHash = 0;
    if (sensori != null) {
      for (int i = 0; i < sensori!.length; i++) {
        tmpHash += 64 * i * sensori![i].hashCode;
      }
    }
    return tmpHash;
  }

  @override
  bool operator ==(Object other) =>
      other is SchemaSensoriModel &&
      other.runtimeType == runtimeType &&
      other.hashCode == hashCode;

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
    if (sensori != null) {
      Map<String, dynamic> jsonData = jsonDecode(messageData);
      List<SensoreModel>? localSensori = [];
      if (jsonData.containsKey('id')) {
        if (jsonData['id'] == "*") {
          localSensori.addAll(sensori!);
        } else {
          if (jsonData['id'] is String) {
            jsonData['id'] = int.parse(jsonData['id']);
          }
          // se passo un id intero
          if (getSensore(jsonData['id']) != null) {
            // se è l'id è quello di un sensore registrato
            localSensori.add(getSensore(jsonData['id'])!);
          } else {
            // se l'id non è registrato metto il comando in attesa
            int findIndex = waitingSensoreStato
                .indexWhere((element) => element['id'] == jsonData['id']);
            if (findIndex >= 0) {
              if (jsonData.containsKey('valore')) {
                waitingSensoreStato[findIndex]['valore'] = jsonData['valore'];
              }
              if (jsonData.containsKey('attiva')) {
                waitingSensoreStato[findIndex]['attiva'] = jsonData['attiva'];
              }
              if (jsonData.containsKey('com')) {
                waitingSensoreStato[findIndex]['com'] = jsonData['com'];
              }
            } else {
              waitingSensoreStato.add(jsonData);
            }
          }
        }
        if (localSensori.isNotEmpty) {
          for (SensoreModel localSensore in localSensori) {
            if (jsonData.containsKey('valore')) {
              try {
                localSensore.valore = jsonData['valore'];
              } catch (e) {
                localSensore.valore = int.parse(jsonData['valore']);
              }
            }
            if (jsonData.containsKey('attiva')) {
              _onAttivazioneChange(localSensore, jsonData['attiva']);
            }
            if (jsonData.containsKey('com')) {
              // Map<String, dynamic> messageJson = {};
              // if (jsonData['com'] == 'shotrJ') {
              //     messageJson['status'] = 'sensori';
              //     List listSensorHash = [];
              //     for (SensoreModel localSensore in localSensori) {
              //       Map<String, dynamic> sensorHash = {
              //         'id': localSensore.id,
              //         'hash': localSensore.hashCode
              //       };
              //       listSensorHash.add(sensorHash);
              //     }
              //     if (listSensorHash.isNotEmpty) {
              //       messageJson['hash'] = listSensorHash;
              //       multiMessageProvider.addMessage(
              //           'request/set', json.encode(messageJson), ['sensori/get']);
              //     }
              //   }
            }

            // if (localSensore is SensoreSirena && jsonData.containsKey('azion')) {
            //   localSensore.azionamenti = int.parse(jsonData['azion']);
            // }
            int findIndex = waitingSensoreStato
                .indexWhere((element) => element['id'] == jsonData['id']);
            if (findIndex >= 0) {
              waitingSensoreStato.removeAt(findIndex);
            }
          }
          saveSchema();
          notifyListeners();
        }
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

  void _onAttivazioneChange(SensoreModel sensore, dynamic jsonData,
      {int index = 0}) {
    if (jsonData is List) {
      for (int i = 0; i < jsonData.length; i++) {
        _onAttivazioneChange(sensore, jsonData[i], index: i);
      }
    } else if (jsonData is Map) {
      sensore.attivazioni = {...sensore.attivazioni, ...jsonData};
      // int findIndex = sensore.attivazioni
      //     .indexWhere((element) => element.id == jsonData['id']);
      // if (findIndex >= 0) {
      //   sensore.attivazioni = [findIndex].setFromJson(jsonData as Map<String, dynamic>);
      // }
    } else if (jsonData is int) {
      sensore.attivazioni[index].valoreInt = jsonData;
    }
  }

  void azioneSensore(int id, AzioneSensore azione, String messageData) {
    mqttClientWrapper!.publishMessage(
        topicSurName: '${topicSurName}/set', messageData: messageData);
  }

  void azioneCamera(int id, AzioneSensore azione, String messageData) {
    mqttClientWrapper!.publishMessage(
        topicSurName: '${topicSurName}/set', messageData: messageData);
  }

  void attivaSensori(String tipoSensore, int attivazione, bool stato) {
    String messageData =
        '{"id": "$tipoSensore", "attiva": ["$attivazione", $stato]}';
    mqttClientWrapper!.publishMessage(
        topicSurName: '${topicSurName}/set', messageData: messageData);
    // mqttClientWrapper!
    //     .publishMessage(topicSurName: 'request/set', messageData: messageData);
  }

  int getMaxIdSensore() {
    // final ids = _storage.keys.toList()..sort();
    // final id = (ids.length == 0) ? 1 : ids.last + 1;
    int maxIdAzione = 0;
    if (sensori != null) {
      for (var element in sensori!) {
        if (element.id > maxIdAzione) {
          maxIdAzione = element.id;
        }
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
    // Map<String, dynamic> jsonData = jsonDecode(messageData);
    // // se risponde che il join è permesso
    // if (jsonData.containsKey('attiva')) {
    //   for (var element in sensori) {
    //     int valoreDaAttivare = int.parse(jsonData['attiva']);
    //     if (valoreDaAttivare > 0) {
    //       valoreDaAttivare = element.attiva | valoreDaAttivare;
    //     } else {
    //       valoreDaAttivare = element.attiva & ~(-valoreDaAttivare);
    //     }
    //     if (jsonData['tipo'] == 'SensoreInfisso' && element is SensoreInfisso) {
    //       element.attivazioni = valoreDaAttivare;
    //     } else if (jsonData['tipo'] == 'SensorePresenza' &&
    //         element is SensorePresenza) {
    //       element.attivazioni = valoreDaAttivare;
    //     }
    //   }
    //   notifyListeners();
    // }
  }

  void requestStatus() {
    if (sensori != null && sensori!.isNotEmpty) {
      multiMessageProvider.addMessage('sensori/set',
          '{"hj": ${json.encode(toShortJson())}}', ['sensori/get']);
      statusRequested = false;
    } else {
      statusRequested = true;
    }
  }

  //funzione per salvare lo schema
  void saveSchema() {
    if (sensori != null) {
      schemaRepository?.saveSchema({
        topicSurName: sensori!
            .map<Map<String, dynamic>>((sensore) => sensore.toJson())
            .toList()
      });
    }
    //schemaRepository?.saveBackImage();
  }

  // conversione Json
  SchemaSensoriModel.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.nome = json['name'] ?? '' {
    // json['sensori']?.forEach((sensore) {
    //   _localFileRepository.addSensoreFromJson(sensore);
    // });
  }

  Map<String, dynamic>? toJson() {
    if (sensori != null) {
      return {
        'id': id,
        'name': nome,
        'hash': hashCode,
        'sensori': sensori!
            .map<Map<String, dynamic>>((sensore) => sensore.toJson())
            .toList(),
      };
    } else {
      return null;
    }
  }

  Map<String, dynamic>? toShortJson() {
    if (sensori != null) {
      return {
        'i': id,
        's': sensori!
            .map<Map<String, dynamic>>((sensore) => sensore.toShortJson())
            .toList(),
      };
    } else {
      return null;
    }
  }
}
