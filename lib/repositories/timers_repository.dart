// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:gestione_domotica/models/timer/timers.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:gestione_domotica/repositories/encrypt_data.dart';
// import 'dart:io';

// /// Classe che contiene lo schema dei Timer
// class TimersRepository {
//   // costruttori
//   static final TimersRepository _instance = TimersRepository._internal();

//   factory TimersRepository() {
//     return _instance;
//   }

//   TimersRepository._internal();

//   Map<String, Timers> timersMap = {};

//   Future<Map<String, dynamic>> get timers async {
//     return timersMap;
//   }

//   Timers? getTimers(String timer) {
//     if (timersMap.containsKey(timer)) {
//       return timersMap[timer];
//     } else {
//       return Timers(timers: {'activated': false});
//     }
//   }

//   void saveTimers(String schemaData) async {
//     if (!kIsWeb) {
//       final directory = await getApplicationDocumentsDirectory();
//       final File file = File('${directory.path}/timers.json');
//       String stringToWrite = encryptMyData(schemaData);
//       await file.writeAsString(stringToWrite);
//     }
//   }

//   Future<Map<String, dynamic>> loadTimers() async {
//     if (!kIsWeb) {
//       final directory = await getApplicationDocumentsDirectory();
//       final File file = File('${directory.path}/timers.json');
//       if (await file.exists()) {
//         String fileString = decryptMyData(await file.readAsString()) ?? '';
//         return json.decode(fileString);
//       } else {
//         return {};
//       }
//     } else {
//       return {};
//     }
//     //notifyListeners();
//   }
// }
