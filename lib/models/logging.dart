import 'package:logger/logger.dart';
import 'package:universal_html/html.dart';

final logger = (Type type) => Logger(printer: CustomPrinter(type.toString()));

class CustomPrinter extends LogPrinter {
  CustomPrinter(this.className);

  final String className;

  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.levelColors[event.level];
    final emoji = PrettyPrinter.levelEmojis[event.level];
    final message = event.message;

    return [color!('$emoji $className: $message')];
  }
}
