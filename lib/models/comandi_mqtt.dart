// import 'dart:convert';

// import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';

// /// Classe che contiene il modello dei dati da salvare e inviare
// class ComandiMQTT {
//   // costruttori
//   ComandiMQTT(this.topicSurName, {
//     Function(int)? this.onSet,
//     Function(int)? this.onGet
//   }) {
//     mqttClientWrapper = MQTTClientWrapper();
//     if (mqttClientWrapper!.connectionState ==
//         MqttCurrentConnectionState.CONNECTED) {
//       _connect();
//     }
//     mqttClientWrapper!.addListener(_connect, ['connection.stateConnected']);

//   }

//   // variabili
//   final String topicSurName;
//   final Function(int)? onSet;
//   final Function(int)? onGet;

//   MQTTClientWrapper? mqttClientWrapper;

//   void _connect() {
//     mqttClientWrapper!.subscribeToTopic(
//         topicSurName: topicSurName,
//         onDataReceived: (messageData) => _onSensorChanged(messageData));
//   }

//   _onSensorChanged(String messageData) {
//     if (getSensore(modelData.id).tipo > 0) {
//       getSensore(modelData.id).valore = modelData.data['valore'];
//       notifyListeners();
//     }
//   }

//   void set(int data) {
    
//   }
//   // conversione String
//   @override
//   String toString() {
//     return jsonEncode(toJson());
//   }

//   factory ModelData.fromString(String string) {
//     Map<String, dynamic> jsonData = jsonDecode(string);
//     return ModelData.fromJson(jsonData);
//   }

//   // conversione Json
//   ModelData.fromJson(Map<String, dynamic> json)
//       : this.id = json['id'],
//         this.data = json['data'] ?? '';
//   //       {
//   //   json['azioni']?.forEach((dynamic azione) {
//   //     azioni.add(Azione.fromJson(azione));
//   //   });
//   // }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'data': data,
//     };
//   }
// }