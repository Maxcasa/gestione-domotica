//import 'package:flutter/material.dart';

/// Classe che contiene lo schema del sistema

class Timer {
  // costruttori
  Timer();

  final List<int> _timer = [];
  bool isActivated = false;

  void setTimer(int inizio, int fine) {
    _timer.add(inizio);
    _timer.add(fine);
  }

  List<int> getTimer() {
    return _timer.sublist(0, 2);
  }

  // conversione Json
  Timer.fromJson(Map<String, dynamic> json)
      : isActivated = json['act'] ?? false {
    for (var i in json['time']) {
      _timer.add(i);
    }
  }

  Map<String, dynamic> toJson() {
    return {'act': isActivated, 'time': _timer};
  }
}
