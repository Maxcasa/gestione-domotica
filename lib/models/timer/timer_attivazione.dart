//import 'package:flutter/material.dart';

/// Classe che contiene lo schema del sistema

class TimerAttivazione {
  // costruttori
  TimerAttivazione();

  List<int> _timerInizio = [0];
  List<int> _timerFine = [10];
  int? id;
  int valore = 0;
  int maxTimers = 1;
  bool isActivated = false;

  void setTimer(List<int> inizio, List<int> fine) {
    _timerInizio = inizio;
    _timerFine = fine;
  }

  List<int> getTimer({int indexTimer = 0}) {
    indexTimer = indexTimer <= maxTimers ? indexTimer : maxTimers;
    return [_timerInizio[indexTimer], _timerFine[indexTimer]];
  }

  int getSum() => (_timerInizio.reduce((a, b) => a + b) +
      _timerFine.reduce((a, b) => a + b));

  // conversione Json
  TimerAttivazione.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false,
        id = json['id'],
        valore = json['valore'] ?? 0 {
    if (json.containsKey('start')) {
      _timerInizio = json['start'];
    } else {
      _timerInizio = [0];
    }
    if (json.containsKey('end')) {
      _timerFine = json['end'];
    } else {
      _timerFine = [60 * 24 ~/ 5];
    }
    if (json.containsKey('max')) {
      maxTimers = json['max'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'act': isActivated,
      'valore': valore,
      'max': maxTimers,
      'start': _timerInizio,
      'end': _timerFine
    };
  }
}
