//import 'package:flutter/material.dart';

/// Classe che contiene lo schema del sistema

class TimerAttivazione {
  // costruttori
  TimerAttivazione();

  List<dynamic> _timerInit = [
    [0, 10]
  ];
  int? id;
  int valore = 0;
  int maxTimers = 1;
  bool isActivated = false;

  set timer(List<dynamic> init) {
    _timerInit = init;
  }

  void setTimer(List<int> init, int index) {
    if (index < _timerInit.length) {
      _timerInit[index] = init;
    } else {
      throw Exception('Index must be inside timers');
    }
  }

  List<int> getTimer({int index = 0}) {
    if (index < _timerInit.length) {
      //indexTimer = indexTimer <= maxTimers ? indexTimer : maxTimers;
      return _timerInit[index];
      //_timerInit[index] = init;
    } else {
      throw Exception('Index must be inside timers');
    }
  }

  int getSum() => (_timerInit.reduce((a, b) => a + b));

  // conversione Json
  TimerAttivazione.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false,
        id = json['id'],
        valore = json['valore'] ?? 0 {
    if (json.containsKey('time')) {
      _timerInit = json['time'];
    } else {
      _timerInit = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'act': isActivated,
      'valore': valore,
      'max': maxTimers,
      'time': _timerInit
    };
  }
}
