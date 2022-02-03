class AllowedDevice {
  // costruttori
  AllowedDevice({required this.nome, required this.name, required this.auth});

  String nome;
  String name;
  bool auth = false;

// conversione Json
  AllowedDevice.fromJson(Map<String, dynamic> json)
      : nome = json['nome'],
        name = json['name'],
        auth = json['auth'] ?? false;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {'nome': nome, 'name': name, 'auth': auth};
    return result;
  }
}
