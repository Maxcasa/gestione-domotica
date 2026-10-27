/// Porta MQTT standard (LAN/Tailscale, senza TLS)
const int defaultMqttPort = 1883;

/// Classe che contiene i dati delle connessioni
///
/// Le credenziali MQTT (remoteUser/remotePassword) vivono solo in memoria e
/// nello storage sicuro del sistema operativo: [toJson] non le include.
class ConnectionData {
  // costruttori
  ConnectionData({
    required this.id,
    required this.connectionName,
    required this.localServerName,
    required this.remoteServerName,
    required this.remoteUser,
    required this.remotePassword,
    required this.remoteDomain,
    required this.localWiFiConnectionName,
    required this.intervalKeepAlive,
    required this.modeKeepAlive,
    this.mqttPort = defaultMqttPort,
  });

  // variabili
  int id;
  String connectionName;
  String localServerName;
  String remoteServerName;
  String remoteUser;
  String remotePassword;
  String remoteDomain;
  String localWiFiConnectionName;
  int intervalKeepAlive;
  int modeKeepAlive;
  int mqttPort;

  bool get hasCredentials => remoteUser.isNotEmpty && remotePassword.isNotEmpty;

  // conversione Json
  // remoteUser/remotePassword sono letti solo per migrare i vecchi file locali
  ConnectionData.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? -1,
        connectionName = json['connectionName'] ?? 'Vuoto',
        localServerName = json['localServerName'] ?? '',
        remoteServerName = json['remoteServerName'] ?? '',
        remoteUser = json['remoteUser'] ?? '',
        remotePassword = json['remotePassword'] ?? '',
        remoteDomain = json['remoteDomain'] ?? '',
        localWiFiConnectionName = json['localWiFiConnectionName'] ?? '',
        intervalKeepAlive = json['intervalKeepAlive'] ?? 1,
        modeKeepAlive = json['modeKeepAlive'] ?? 0,
        mqttPort = json['mqttPort'] ?? defaultMqttPort;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'connectionName': connectionName,
      'localServerName': localServerName,
      'remoteServerName': remoteServerName,
      'remoteDomain': remoteDomain,
      'localWiFiConnectionName': localWiFiConnectionName,
      'intervalKeepAlive': intervalKeepAlive,
      'modeKeepAlive': modeKeepAlive,
      'mqttPort': mqttPort,
    };
    return result;
  }
}
