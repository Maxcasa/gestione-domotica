class AllowedDevice {
  // costruttori
  AllowedDevice(
      {required this.nome,
      required this.name,
      required this.mac,
      required this.auth});

  String nome;
  String name;
  String mac;
  bool auth = false;

// conversione Json
  AllowedDevice.fromJson(Map<String, dynamic> json)
      : nome = json['nome'],
        name = json['name'],
        mac = json['mac'],
        auth = json['auth'] ?? false;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'nome': nome,
      'name': name,
      'mac': mac,
      'auth': auth
    };
    return result;
  }
}
