/// Classe che contiene i dati locali
class LocalData {
  // costruttori
  LocalData({
    this.activeIndex = -1,
    this.sensoriVisibili = false,
    this.token = '',
  });

  // variabili
  int activeIndex;
  bool sensoriVisibili;
  String token;

  // conversione Json
  LocalData.fromJson(Map<String, dynamic> json)
      : activeIndex = json['activeIndex'] ?? -1,
        sensoriVisibili = json['sensoriVisibili'] ?? false,
        token = json['tolken'] ?? '';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'activeIndex': activeIndex,
      'sensoriVisibili': sensoriVisibili,
      'token': token
    };
    return result;
  }
}
