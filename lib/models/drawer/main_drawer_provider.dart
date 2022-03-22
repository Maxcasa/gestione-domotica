import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';

/// Classe che contiene la gestione del menu e del nome della pagina
class MainDrawerProvider extends ChangeNotifier {
  // costruttori
  MainDrawerProvider(String this.fileName) : super() {
    _loadfile();
    mqttClientWrapper = MQTTClientWrapper();
  }

  Future<void> _loadfile() async {
    String fileString = await rootBundle.loadString(fileName);
    drawerJson = json.decode(fileString);
    notifyListeners();
  }

  // variabili
  final String fileName;
  String pageName = '';
  // String fileString = '';
  List<Map<String, dynamic>> drawerTree = [];
  List drawerJson = [];
  MQTTClientWrapper? mqttClientWrapper;

  getMenu() {
    if (drawerJson.isEmpty) {
      // String fileString = await rootBundle.loadString(fileName);
      // drawerJson = json.decode(fileString);
      pageName = '';
    }
    drawerTree = [];
    for (var drawerItem in drawerJson) {
      if (drawerItem['pageName'] != pageName) {
        drawerTree.add({
          "num": drawerItem['num'],
          "pageName": drawerItem['pageName'],
          "drawerItem": drawerItem['drawerItem']
        });
      }
    }
    //notifyListeners();
  }

  bool connectionState() {
    if (mqttClientWrapper == null ||
        mqttClientWrapper!.connectionState !=
            MqttCurrentConnectionState.CONNECTED) {
      return false;
    } else {
      return true;
    }
  }
}
