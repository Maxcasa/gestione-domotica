//import 'package:flutter/material.dart';

/// Classe che contiene lo schema del sistema

class Timer {
  // costruttori
  Timer({required Map<String, dynamic> this.timer});

  Map<String, dynamic> timer;

  // Future<Map<String, dynamic>> get timer async {
  //   return timersMap;
  // }

  bool get isActivated {
    if (timer.containsKey('activated') && timer['activated']) {
      return true;
    } else {
      return false;
    }
  }
}
