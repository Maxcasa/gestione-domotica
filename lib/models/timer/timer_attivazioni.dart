import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import './timer_attivazione.dart';

/// Classe che contiene lo schema del sistema

class TimerAttivazioni with ChangeNotifier {
  // costruttori
  TimerAttivazioni();
  // static final Timers _instance = Timers._internal();

  // factory Timers() {
  //   return _instance;
  // }

  // // costruttori
  // Timers._internal() : super() {
  //   loadTimers();
  // }

  List<TimerAttivazione> timers = [];
  bool isActivated = false;

  // Future<Map<String, dynamic>> get timer async {
  //   return timersMap;
  // }

  List<dynamic> get timersArray {
    return timers.map((timer) => timer.timerInit).toList();
  }

  List<bool> get activationArray {
    return timers.map((timers) => timers.isActivated).toList();
  }

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

  void setTimer(List<int> indexTimer, List<int> multiInit) {
    if (indexTimer[0] >= 0 && indexTimer[0] < timers.length) {
      timers[indexTimer[0]].setTimer(multiInit, indexTimer[1]);
    }
  }

  void attivaTimer(int indexTimer, bool attiva) {
    if (indexTimer < 0) {
      isActivated = attiva;
    } else if (indexTimer < timers.length) {
      timers[indexTimer].isActivated = attiva;
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

  List<dynamic> toShortJson() {
    List<dynamic> shortJson = [isActivated];
    shortJson.addAll(timers.map((timer) => timer.toShortJson()).toList());
    return shortJson;
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
