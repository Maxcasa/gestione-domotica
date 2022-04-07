//import 'package:flutter/material.dart';

/// Classe che contiene lo schema del sistema

class TimerAttivazione {
  // costruttori
  TimerAttivazione();

  List<int> _timer = [0, 10];
  int? id;
  int valore = 0;
  bool isActivated = false;

  void setTimer(int inizio, int fine) {
    _timer = [inizio, fine];
  }

  List<int> getTimer() {
    return _timer.sublist(0, 2);
  }

  int getSum() => (_timer[0] + _timer[1]);

  // conversione Json
  TimerAttivazione.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false,
        id = json['id'],
        valore = json['valore'] ?? 0 {
    _timer = [];

    if (json.containsKey('start')) {
      _timer.add(json['start']);
    } else {
      _timer.add(0);
    }
    if (json.containsKey('end')) {
      _timer.add(json['end']);
    } else {
      _timer.add(60 * 24 ~/ 5);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'act': isActivated,
      'valore': valore,
      'start': _timer[0],
      'end': _timer[1]
    };
  }
}
