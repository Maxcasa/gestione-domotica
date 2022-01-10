import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Classe che contiene la gestione del menu e del nome della pagina
class MainDrawerProvider extends ChangeNotifier {
  // costruttori
  MainDrawerProvider(String this.fileName) : super();

  // variabili
  final String fileName;
  String pageName = '';
  List<Map<String, dynamic>> drawerTree = [];
  List drawerJson = [];

  Future<void> getMenu() async {
    if (drawerJson.isEmpty) {
      String fileString = await rootBundle.loadString(fileName);
      drawerJson = json.decode(fileString);
      pageName = drawerJson[0]!['pageName'];
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
    notifyListeners();
  }
}
