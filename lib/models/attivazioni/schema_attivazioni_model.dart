//import 'dart:html';

//mport 'dart:convert';
//import 'package:project_calendar/models/data_layer.dart';
//import 'azione.dart';

import 'dart:convert';

import 'package:gestione_domotica/models/attivazioni/attivazioni_layer.dart';
import 'package:gestione_domotica/models/model_data.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/schema_repository.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
//import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:flutter/material.dart';

const String topicSurName = "attivazioni";
// const String localStorage = "sensori";

final factories = <String, Object Function(int id)>{
  'Attivazione': (id) => AttivazioneModel(id: id),
  'Allarme': (id) => AttivazioneAllarme(id: id),
  'Notifica': (id) => AttivazioneNotifica(id: id),
};

/// Classe che gestisce l'insieme dei sensori
// ignore: mixin_inherits_from_not_object
class SchemaAttivazioniModel with ChangeNotifier {
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
    _setupMqtt();
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
  List<AttivazioneModel> attivazioni = [];
  Image? sensoriBack;
  MQTTClientWrapper? mqttClientWrapper;
  SchemaRepository? schemaRepository;
  String _nome = '';
  List<Map<String, dynamic>> waitingAttivazioneStato = [];
  KeepAliveProvider? keepAliveProvider;

  // getter e setter
  AttivazioneModel? getAttivazione(id) {
    for (var i = 0; i < attivazioni.length; i++) {
      if (attivazioni[i].id == id) {
        return attivazioni[id];
      }
    }
    return null;
  }

  Future<List<AttivazioneModel>> getAttivazioni() async {
    if (attivazioni.isEmpty) {
      await _getSchemaAttivazioni();
    }
    return attivazioni;
  }

  //metodi

  Future<void> _getDati() async {
    _getSchemaAttivazioni();
    notifyListeners();
  }

  Future<void> _getSchemaAttivazioni() async {
    Map<String, dynamic> tmpSchema = await schemaRepository!.schema;
    attivazioni = [];
    if (tmpSchema.containsKey(topicSurName)) {
      List listAttivazioni = tmpSchema[topicSurName];
      if (listAttivazioni.isNotEmpty) {
        for (var element in listAttivazioni) {
          String tipo = element['nome'] ?? 'Attivazione';
          int id = element['id'];
          if (factories.containsKey(tipo)) {
            if (tipo == 'Attivazione') {
              attivazioni.add(AttivazioneModel.fromJson(element));
            } else if (tipo == 'Allarme') {
              attivazioni.add(AttivazioneAllarme.fromJson(element));
            } else if (tipo == 'Notifica') {
              attivazioni.add(AttivazioneModel.fromJson(element));
            }
            attivazioni.last
                .setAzioneAttivazioneListener(callback: azioneAttivazione);
          }
        }
        // mqttClientWrapper!.publishMessage(
        //     topicSurName: topicSurName, messageData: 'get/status');
      }
    }
    _consumeWaitingSensore();
  }

  //metodi
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
        topicSurName: '$topicSurName/get',
        onDataReceived: (messageData) => _onAttivazioneChanged(messageData));
  }

  void azioneAttivazione(int id, AzioneAttivazione azione, String messageData) {
    mqttClientWrapper!.publishMessage(
        topicSurName: '$topicSurName/set', messageData: messageData);
  }

  void _consumeWaitingSensore() {
    for (var element in waitingAttivazioneStato) {
      _onAttivazioneChanged(jsonEncode(element));
    }
  }

  _onAttivazioneChanged(String messageData) {
    Map<String, dynamic> jsonData = jsonDecode(messageData);
    if (jsonData.containsKey('stato')) {
      List<AttivazioneModel> localAttivazioni = [];
      if (jsonData['id'] == "*") {
        localAttivazioni.addAll(attivazioni);
      } else if (int.tryParse(jsonData['id']) != null) {
        // se passo un id intero
        if (getAttivazione(int.parse(jsonData['id'])) != null) {
          // se è l'id è quello di un sensore registrato
          localAttivazioni.add(getAttivazione(int.parse(jsonData['id']))!);
        } else {
          // se l'id non è registrato metto il comando in attesa
          int findIndex = waitingAttivazioneStato
              .indexWhere((element) => element['id'] == jsonData['id']);
          if (findIndex >= 0) {
            waitingAttivazioneStato[findIndex]['stato'] = jsonData['stato'];
          } else {
            waitingAttivazioneStato.add(jsonData);
          }
        }
      }
      for (AttivazioneModel localAttivazione in localAttivazioni) {
        localAttivazione.valore = int.parse(jsonData['stato']);
        int findIndex = waitingAttivazioneStato
            .indexWhere((element) => element['id'] == jsonData['id']);
        if (findIndex >= 0) {
          waitingAttivazioneStato.removeAt(findIndex);
        }
        notifyListeners();
      }
    }
  }

  // conversione Json
  SchemaAttivazioniModel.fromJson(Map<String, dynamic> json)
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
      'attivazioni': attivazioni
          .map<Map<String, dynamic>>((sensore) => sensore.toJson())
          .toList(),
    };
  }
}
