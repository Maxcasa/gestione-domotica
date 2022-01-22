import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:gestione_domotica/models/remote_conf/allowed_device.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

const String port = '8085';

/// Classe che contiene la gestione dei dispositivi autorizzati
// ignore: mixin_inherits_from_not_object
class RemoteConnection extends ChangeNotifier {
  // costruttori
  static final RemoteConnection _instance = RemoteConnection._internal();

  factory RemoteConnection() {
    return _instance;
  }

  RemoteConnection._internal() : super();

  // variabili
  String? remoteServerUri;
  String? localWiFiConnectionName;
  final info = NetworkInfo();
  var lock = Lock();

  Future<String?> getRemoteServerUri() async {
    if (remoteServerUri == null) {
      await lock.synchronized(_getConnectionInfo);
    }
    return remoteServerUri;
  }

  Future<String?> getLocalWiFiConnectionName() async {
    if (localWiFiConnectionName == null) {
      await lock.synchronized(_getConnectionInfo);
    }
    return localWiFiConnectionName;
  }

  //metodi

  // prendo le info di connessioni
  Future<void> _getConnectionInfo() async {
    if (localWiFiConnectionName == null && remoteServerUri == null) {
      if (kIsWeb) {
        await _getAssetsInfo();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/connection_info.json');
        if (await file.exists()) {
          String fileString = await file.readAsString();
          Map<String, dynamic> jsonData = json.decode(fileString);
          remoteServerUri = jsonData['remoteServerUri'];
          localWiFiConnectionName = jsonData['localWiFiConnectionName'];
        } else {
          await _getAssetsInfo();
        }
      }
    }
  }

  Future<void> _getAssetsInfo() async {
    try {
      String fileString =
          await rootBundle.loadString('assets/json/remote_connection.json');
      Map<String, dynamic> jsonData = json.decode(fileString);
      if (await checkIPInfo(jsonData['remoteServerUri']) &&
          await checkWiFiInfo(jsonData['remoteServerUri'])) {
        remoteServerUri = jsonData['remoteServerUri'];
        localWiFiConnectionName = jsonData['localWiFiConnectionName'];
      }
    } on Exception catch (e) {
      print('RemoteConnection :: $e');
      throw Exception(e);
    }
  }

  Future<bool> saveConnectionInfo() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/connection_info.json');
      await file.writeAsString(
          '{"remoteServerUri": "$remoteServerUri, "localWiFiConnectionName": $localWiFiConnectionName}');
    }
    notifyListeners();
    return true;
  }

  Future<bool> checkIPInfo(String ipValue) async {
    bool ipOK = false;
    http.Response httpResponse =
        await http.get(Uri.parse('http://$ipValue:$port/'));
    if (httpResponse.statusCode == 200 &&
        httpResponse.body == 'Domo_Server is here!') {
      ipOK = true;
    }
    return ipOK;
  }

  Future<bool> checkWiFiInfo(String wiFiValue) async {
    bool wiFiOk = true;
    return wiFiOk;
  }
}
