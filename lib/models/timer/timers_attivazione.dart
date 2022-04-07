import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gestione_domotica/repositories/encrypt_data.dart';
import 'package:path_provider/path_provider.dart';

import './timer_attivazione.dart';

/// Classe che contiene lo schema del sistema

class TimerAttivazioni with ChangeNotifier {
  // costruttori
  // static final Timers _instance = Timers._internal();

  // factory Timers() {
  //   return _instance;
  // }

  // // costruttori
  // Timers._internal() : super() {
  //   loadTimers();
  // }

  List<TimerAttivazione> timers = [TimerAttivazione(), TimerAttivazione()];
  bool isActivated = false;

  // Future<Map<String, dynamic>> get timer async {
  //   return timersMap;
  // }

  @override
  int get hashCode {
    int tmpHash = 0;
    for (TimerAttivazione timer in timers) {
      tmpHash += (300 *
              (timers.length - timer.id!) *
              (timers.length - (timer.isActivated ? 2 : 1))) +
          timer.getSum();
    }
    return tmpHash;
  }

  @override
  bool operator ==(Object other) =>
      other is TimerAttivazioni &&
      other.runtimeType == runtimeType &&
      other.hashCode == hashCode;

  // conversione Json
  TimerAttivazioni.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false {
    timers = [];
    for (var i in json['timers']) {
      timers.add(TimerAttivazione.fromJson(i));
    }
  }

  void setTimer(int indexTimer, int inizio, int fine) {
    if (indexTimer >= 0 && indexTimer < timers.length) {
      timers[indexTimer].setTimer(inizio, fine);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'act': isActivated,
      'hash': hashCode,
      'timers':
          timers.map<Map<String, dynamic>>((timer) => timer.toJson()).toList(),
    };
  }

  // void saveTimers() async {
  //   if (!kIsWeb) {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final File file = File('${directory.path}/timers.json');
  //     String stringToWrite = encryptMyData(json.encode(toJson()));
  //     await file.writeAsString(stringToWrite);
  //   }
  // }

  // Future<void> loadTimers() async {
  //   if (!kIsWeb) {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final File file = File('${directory.path}/timers.json');
  //     if (await file.exists()) {
  //       String fileString = decryptMyData(await file.readAsString()) ?? '';
  //       Map<String, dynamic> jsonTimers = json.decode(fileString);
  //       isActivated = jsonTimers['act'] ?? false;
  //       timers = [];
  //       for (var i in jsonTimers['timer']) {
  //         timers.add(Timer.fromJson(i));
  //       }
  //     }
  //   }
  //   notifyListeners();
  // }
}
