import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensore_model.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class KeepAliveProvider extends PropertyChangeNotifier<String> {
  // classe che distibuisce i messaggi keep alive
  // costruttori
  static final KeepAliveProvider _instance = KeepAliveProvider._internal();

  factory KeepAliveProvider() {
    return _instance;
  }

  KeepAliveProvider._internal();

  Map<String, List<Map<String, dynamic>>> mappaValori = {};

  void impostaTeH(List<Map<String, dynamic>> valori) {
    mappaValori['TeH'] = valori;
    notifyListeners('TeH');
  }
}
