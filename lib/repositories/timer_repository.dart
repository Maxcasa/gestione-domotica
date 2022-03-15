import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/timer.dart';

/// Classe che contiene lo schema del sistema

class TimerRepository extends ChangeNotifier {
  // costruttori
  static final TimerRepository _instance = TimerRepository._internal();

  factory TimerRepository() {
    return _instance;
  }

  TimerRepository._internal();

  Map<String, Timer> timersMap = {};

  Future<Map<String, dynamic>> get timers async {
    return timersMap;
  }

  Timer? getTimer(String timer) {
    if (timersMap.containsKey(timer)) {
      return timersMap[timer];
    } else {
      return Timer(timer: {'activated': false});
    }
  }

  bool isActivated(String timer) {
    if (timersMap.containsKey(timer) && timersMap[timer]!.isActivated) {
      return true;
    } else {
      return false;
    }
  }
}
