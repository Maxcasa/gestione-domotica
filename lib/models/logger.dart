import 'dart:convert';

import 'package:logger/logger.dart';
//import 'package:universal_html/html.dart';

// enum Level {
//   verbose,
//   debug,
//   info,
//   warning,
//   error,
//   wtf,
//   nothing,
// }

// class AppLogger {
//   static final AppLogger _instance = AppLogger._internal();
//   late Logger _logger;
//   Level _level = Level.info;
//   Type type;

//   factory AppLogger() {
//     return _instance;
//   }

//   static Logger getLogger(Type ) => _logger;

//   AppLogger._internal() {
//     _logger = Logger(
//       printer: CustomPrinter(type.toString()),
//       level: _level
//     );
//   }

//set
//getStatus();
// timerRepository = TimersRepository();
// timerRepository!.addListener(_getTimer);
// if (timerRepository != null) {
//   _getTimer();
// }

// static Logger getLogger(Type type) => Logger(
//       printer: CustomPrinter(type.toString()),
//     );
//}

final logger = (Type type) =>
    Logger(printer: CustomPrinter(type.toString()), level: Level.info);

class CustomPrinter extends LogPrinter {
  CustomPrinter(this.className);

  final String className;

  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.levelColors[event.level];
    final emoji = PrettyPrinter.levelEmojis[event.level];
    final message = _stringifyMessage(event.message);

    return [color!('$emoji $className: $message')];
  }

  String _stringifyMessage(dynamic message) {
    if (message is Map || message is Iterable) {
      var encoder = const JsonEncoder.withIndent(null);
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }
}
