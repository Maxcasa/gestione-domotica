import 'dart:convert';

/// Classe che contiene il modello dei dati da salvare e inviare
class ModelData {
  // costruttori
  const ModelData({
    required this.id,
    this.data = const {},
  });

  // variabili
  final int id;
  final Map<String, dynamic> data;

  // conversione String
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory ModelData.fromString(String string) {
    Map<String, dynamic> jsonData = jsonDecode(string);
    return ModelData.fromJson(jsonData);
  }

  // conversione Json
  ModelData.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.data = json['data'] ?? '';
  //       {
  //   json['azioni']?.forEach((dynamic azione) {
  //     azioni.add(Azione.fromJson(azione));
  //   });
  // }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
    };
  }
}
