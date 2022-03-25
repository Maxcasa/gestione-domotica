import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gestione_domotica/repositories/encrypt_data.dart';
import 'package:path_provider/path_provider.dart';

import './timer.dart';

/// Classe che contiene lo schema del sistema

class Timers with ChangeNotifier {
  // costruttori
  static final Timers _instance = Timers._internal();

  factory Timers() {
    return _instance;
  }

  // costruttori
  Timers._internal() : super() {
    loadTimers();
  }

  List<Timer> timers = [Timer(), Timer()];
  bool isActivated = false;

  // Future<Map<String, dynamic>> get timer async {
  //   return timersMap;
  // }

  // conversione Json
  Timers.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false {
    for (var i in json['timer']) {
      timers.add(Timer.fromJson(i));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'act': isActivated,
      'timer':
          timers.map<Map<String, dynamic>>((timer) => timer.toJson()).toList()
    };
  }

  void saveTimers() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/timers.json');
      String stringToWrite = encryptMyData(json.encode(toJson()));
      await file.writeAsString(stringToWrite);
    }
  }

  Future<void> loadTimers() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/timers.json');
      if (await file.exists()) {
        String fileString = decryptMyData(await file.readAsString()) ?? '';
        Map<String, dynamic> jsonTimers = json.decode(fileString);
        isActivated = jsonTimers['act'] ?? false;
        timers = [];
        for (var i in jsonTimers['timer']) {
          timers.add(Timer.fromJson(i));
        }
      }
    }
    notifyListeners();
  }
}
