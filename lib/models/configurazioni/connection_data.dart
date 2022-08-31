/// Classe che contiene i dati delle connessioni
class ConnectionData {
  // costruttori
  ConnectionData({
    required this.id,
    required this.connectionName,
    required this.localServerName,
    required this.remoteServerName,
    required this.remoteUser,
    required this.remotePassword,
    required this.certDirBase,
    required this.caFile,
    required this.certFile,
    required this.keyFile,
    required this.remoteDomain,
    required this.localWiFiConnectionName,
  });

  // variabili
  int id;
  String connectionName;
  String localServerName;
  String remoteServerName;
  String remoteUser;
  String remotePassword;
  String certDirBase;
  String caFile;
  String certFile;
  String keyFile;
  String remoteDomain;
  String localWiFiConnectionName;

  // conversione Json
  ConnectionData.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? -1,
        connectionName = json['connectionName'] ?? 'Vuoto',
        localServerName = json['localServerName'] ?? '',
        remoteServerName = json['remoteServerName'] ?? '',
        remoteUser = json['remoteUser'] ?? '',
        remotePassword = json['remotePassword'] ?? '',
        certDirBase = json['certDirBase'] ?? '',
        caFile = json['caFile'] ?? '',
        certFile = json['certFile'] ?? '',
        keyFile = json['keyFile'] ?? '',
        remoteDomain = json['remoteDomain'] ?? '',
        localWiFiConnectionName = json['localWiFiConnectionName'] ?? '';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'connectionName': connectionName,
      'localServerName': localServerName,
      'remoteServerName': remoteServerName,
      'remoteUser': remoteUser,
      'remotePassword': remotePassword,
      'certDirBase': certDirBase,
      'caFile': caFile,
      'certFile': certFile,
      'keyFile': keyFile,
      'remoteDomain': remoteDomain,
      'localWiFiConnectionName': localWiFiConnectionName,
    };
    return result;
  }
}
