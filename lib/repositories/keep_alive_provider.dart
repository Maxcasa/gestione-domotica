import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensore_model.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class KeepAliveProvider extends ChangeNotifier {
  // classe che distibuisce i messaggi keep alive
  // costruttori
  static final KeepAliveProvider _instance = KeepAliveProvider._internal();

  factory KeepAliveProvider() {
    return _instance;
  }

  KeepAliveProvider._internal();

  List<Map<String, dynamic>> valori = [];

  void impostaTeH(List<Map<String, dynamic>> valori) {
    this.valori = valori;
    notifyListeners();
  }
}
