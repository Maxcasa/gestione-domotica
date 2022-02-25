import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
// import 'package:logger/logger.dart';

class MultiMessageProvider {
// class MQTTClientWrapper with ChangeNotifier {
  // costruttori
  static final MultiMessageProvider _instance =
      MultiMessageProvider._internal();

  factory MultiMessageProvider() {
    return _instance;
  }

  MultiMessageProvider._internal() {
    mqttClientWrapper = MQTTClientWrapper();
    mqttClientWrapper!.subscriptionCallback(onSubscription: onSubscription);
  }

  MQTTClientWrapper? mqttClientWrapper;
  List<Map<String, Object>> waitingMessageList = [];
  // var logger = Logger();

  void addMessage(String topic, String message, List<String> listeners) {
    // logger.v("Aggiungo il messaggio Topic: ${topic} ${message}");
    if (checkListeners(listeners)) {
      // logger.v("Pubblico subito il messaggio Topic: ${topic} ${message}");
      mqttClientWrapper!
          .publishMessage(topicSurName: topic, messageData: message);
    } else {
      waitingMessageList
          .add({'topic': topic, 'message': message, 'listeners': listeners});
    }
  }

  void onSubscription(String topicSurName, bool subscribe) {
    List<Map<String, Object>> waitingRemoveList = [];
    if (waitingMessageList.isNotEmpty) {
      for (var element in waitingMessageList) {
        if (checkListeners(element['listeners'] as List<String>)) {
          // logger.v(
          //     "Pubblico dopo il messaggio Topic: ${element['topic'] as String} ${element['message'] as String}");
          mqttClientWrapper!.publishMessage(
              topicSurName: element['topic'] as String,
              messageData: element['message'] as String);
          waitingRemoveList.add(element);
        }
      }
      if (waitingRemoveList.isNotEmpty) {
        for (var element in waitingRemoveList) {
          waitingMessageList.remove(element);
        }
      }
    }
  }

  bool checkListeners(List<String> listeners) {
    bool present = true;
    for (var element in listeners) {
      if (!(mqttClientWrapper!.subscribedSubTopicList.contains(element))) {
        present = false;
      }
    }
    return present;
  }
}
