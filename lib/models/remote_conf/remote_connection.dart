import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:gestione_domotica/models/remote_conf/allowed_device.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';
// import 'package:wifi_iot/wifi_iot.dart';

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
  String? remoteServerName;
  String? localWiFiConnectionName;
  // PermissionWithService locationPermission = Permission.locationWhenInUse;
  var lock = Lock();

  Future<void> setRemoteServerName(String remoteServerName) async {
    List<InternetAddress> ipValues =
        await InternetAddress.lookup(remoteServerName);
    if (ipValues != null && ipValues.length > 0) {
      remoteServerUri = ipValues[0].address;
    }
  }

  String? getRemoteServerUri() {
    // await lock.synchronized(_getConnectionInfo);
    return remoteServerUri;
  }

  String? getRemoteServerName() {
    // await lock.synchronized(_getConnectionInfo);
    return remoteServerName;
  }

  String? getLocalWiFiConnectionName() {
    // await lock.synchronized(_getConnectionInfo);
    return localWiFiConnectionName;
  }

  //metodi

  // prendo le info di connessioni
  Future<void> getConnectionInfo() async {
    //if (localWiFiConnectionName == null && remoteServerUri == null) {
    if (kIsWeb) {
      await _getAssetsInfo();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/connection_info.json');
      if (await file.exists()) {
        String fileString = await file.readAsString();
        Map<String, dynamic> jsonData = json.decode(fileString);
        remoteServerUri = jsonData['remoteServerUri'];
        remoteServerName = jsonData['remoteServerName'];
        localWiFiConnectionName = jsonData['localWiFiConnectionName'];
      } else {
        await _getAssetsInfo();
      }
    }
    notifyListeners();
    //}
  }

  Future<void> _getAssetsInfo() async {
    try {
      String fileString =
          await rootBundle.loadString('assets/json/remote_connection.json');
      Map<String, dynamic> jsonData = json.decode(fileString);
      remoteServerUri = jsonData['remoteServerUri'];
      remoteServerName = jsonData['remoteServerName'];
      localWiFiConnectionName = jsonData['localWiFiConnectionName'];
      print(
          'RemoteConnection :: $remoteServerName, $remoteServerUri, $localWiFiConnectionName');
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
          '{""remoteServerName": "$remoteServerName, remoteServerUri": "$remoteServerUri, "remoteServerUri": "$remoteServerUri, "localWiFiConnectionName": $localWiFiConnectionName}');
    }
    getConnectionInfo();
    return true;
  }

  Future<bool> checkLocalIP({String? nameValue}) async {
    bool ipOK = false;
    String? ipValue;
    nameValue ?? remoteServerName;
    List<InternetAddress> ipValues = await InternetAddress.lookup(nameValue!);
    if (ipValues != null && ipValues.length > 0) {
      ipValue = ipValues[0].address;
      try {
        http.Response httpResponse =
            await http.get(Uri.parse('http://$ipValue:$port/'));
        if (httpResponse.statusCode == 200 &&
            httpResponse.body == 'Domo_Server is here!') {
          ipOK = true;
        }
      } on Exception catch (e) {
        print('RemoteConnection :: $e');
      }
    }
    return ipOK;
  }

  Future<bool> checkLocalWiFi({String? wiFiValue}) async {
    wiFiValue ??= localWiFiConnectionName;
    if (wiFiValue != null && wiFiValue == await getWifiName()) {
      return true;
    }
    return false;
  }

  Future<String?> getWifiName() async {
    return await lock.synchronized(_getWifiName);
  }

  Future<String?> _getWifiName() async {
    if (kIsWeb) {
      return null;
    } else {
      var permissionStatus = await Permission.location.status;
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await Permission.location.request();
      }

      //   if (permissionStatus == PermissionStatus.denied) {
      //     permissionStatus = await locationPermission.request();
      //   }
      // }

      // // Removed piece of code here, since the variable mentioned in it was not included

      if (permissionStatus == PermissionStatus.granted) {
        bool isLocationServiceOn =
            await Permission.location.serviceStatus.isEnabled;
        if (isLocationServiceOn) {
          final info = NetworkInfo();
          String? wifiName = await info.getWifiName();
          return wifiName;
        } else {
          return null;
        }
      }
      return null;
    }
  }
}
