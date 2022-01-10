import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileRepository {
  // costruttori
  LocalFileRepository(String this.storageName);

  //variabili
  final String storageName;

  Future<List<SensoreModel>?> getSensori() async {
    try {
      final contents;
      if (kIsWeb) {
        final html.Storage _localStorage = html.window.localStorage;
        contents = _localStorage[storageName];
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/$storageName.json');
        contents = await file.readAsString();
      }
      final List<SensoreModel> sensoriContents = [];
      jsonDecode(contents).forEach((element) {
        //sensoriContents.add(addSensoreFromJson(element));
      });
      return sensoriContents;
    } on Exception catch (e) {
      print("The exception thrown is $e");
      return null;
    }
  }

  Future<void> setSensori(List<SensoreModel> sensori) async {
    if (kIsWeb) {
      final html.Storage _localStorage = html.window.localStorage;
      _localStorage[storageName] = sensori.toString();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$storageName.json');
      await file.writeAsString(sensori.toString());
    }
  }
}
