class AllowedDevice {
  // costruttori
  AllowedDevice(
      {required this.name, required this.nameArp, required this.auth});

  String name;
  String nameArp;
  bool auth = false;

// conversione Json
  AllowedDevice.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        nameArp = json['name_arp'],
        auth = json['auth'] ?? false;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'name': name,
      'name_arp': nameArp,
      'auth': auth
    };
    return result;
  }
}
