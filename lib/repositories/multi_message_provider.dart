import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';

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

  void addMessage(String topic, String message, List<String> listeners) {
    if (checkListeners(listeners)) {
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
