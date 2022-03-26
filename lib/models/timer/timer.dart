//import 'package:flutter/material.dart';

/// Classe che contiene lo schema del sistema

class Timer {
  // costruttori
  Timer();

  List<int> _timer = [0, 10];
  bool isActivated = false;

  void setTimer(int inizio, int fine) {
    _timer = [inizio, fine];
  }

  List<int> getTimer() {
    return _timer.sublist(0, 2);
  }

  // conversione Json
  Timer.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false {
    _timer = [];
    for (var i in json['time']) {
      _timer.add(i);
    }
  }

  Map<String, dynamic> toJson() {
    return {'act': isActivated, 'time': _timer};
  }
}
