import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestione_domotica/models/remote_conf/connection_data.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
// import 'package:gestione_domotica/models/remote_conf/allowed_device.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gestione_domotica/repositories/encrypt_data.dart';
import 'package:gestione_domotica/models/remote_conf/connection_data.dart';
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

  RemoteConnection._internal() : super() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      resultConnectivityHandler(result);
    });
  }

  // variabili
  //String? remoteServerUri;
  List<ConnectionData> connectionDataList = [];
  int _activeIndex = 0;
  //String? connectionName;
  //String? localServerName;
  //String? remoteServerName;
  //String? remoteUser;
  //String? remoteDomain;
  //String? localWiFiConnectionName;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  // PermissionWithService locationPermission = Permission.locationWhenInUse;
  var lock = Lock(reentrant: true);

  // getter & setter
  int get activeIndex => _activeIndex;

  set activeIndex(int activeIndex) {
    if (connectionDataList.length <= activeIndex) {
      _activeIndex = connectionDataList.length;
    } else if (activeIndex < 0) {
      _activeIndex = 0;
    } else {
      _activeIndex = activeIndex;
    }
    notifyListeners();
  }

  String? get connectionName {
    if (connectionDataList.length > _activeIndex) {
      return connectionDataList[_activeIndex].connectionName;
    } else {
      return null;
    }
  }

  List<String> get connectionNameList {
    final List<String> nameList = [];
    for (var element in connectionDataList) {
      nameList.add(element.connectionName);
    }
    return nameList;
  }

  String? get localServerName {
    if (connectionDataList.length > _activeIndex) {
      return connectionDataList[_activeIndex].localServerName;
    } else {
      return null;
    }
  }

  set localServerName(String? localServerName) {
    connectionDataList[_activeIndex].localServerName = localServerName ?? '';
  }

  String? get remoteServerName {
    if (connectionDataList.length > _activeIndex) {
      return connectionDataList[_activeIndex].remoteServerName;
    } else {
      return null;
    }
  }

  String? get remoteUser {
    if (connectionDataList.length > _activeIndex) {
      return connectionDataList[_activeIndex].remoteUser;
    } else {
      return null;
    }
  }

  String? get remoteDomain {
    if (connectionDataList.length > _activeIndex) {
      return connectionDataList[_activeIndex].remoteDomain;
    } else {
      return null;
    }
  }

  String? get localWiFiConnectionName {
    if (connectionDataList.length > _activeIndex) {
      return connectionDataList[_activeIndex].localWiFiConnectionName;
    } else {
      return null;
    }
  }

  set localWiFiConnectionName(String? localWiFiConnectionName) {
    connectionDataList[_activeIndex].localWiFiConnectionName =
        localWiFiConnectionName ?? '';
  }

  bool get connectionNull {
    if (connectionName != null &&
        localServerName != null &&
        remoteServerName != null &&
        remoteUser != null &&
        remoteDomain != null &&
        localWiFiConnectionName != null) {
      return false;
    }
    return true;
  }

  bool get connectionPresent {
    if (connectivity > 0 || kIsWeb) {
      return true;
    }
    return false;
  }

  int get connectivity {
    switch (_connectivityResult) {
      case ConnectivityResult.none:
        return 0;
      case ConnectivityResult.mobile:
        return 1;
      case ConnectivityResult.wifi:
        return 2;
      case ConnectivityResult.ethernet:
        return 3;
      default:
        return 0;
    }
  }

  //metodi

  // metodo per gestire il cambio di connettività
  void resultConnectivityHandler(ConnectivityResult result) {
    _connectivityResult = result;
    notifyListeners();
  }

  // prendo le info di connessioni
  Future<void> getConnectionInfo() async {
    await lock.synchronized(_getConnectionInfo);
  }

  Future<void> _getConnectionInfo() async {
    //if (localWiFiConnectionName == null && remoteServerUri == null) {
    // ricarico solo se necessario o forzato.
    if (connectionDataList.isEmpty) {
      if (kIsWeb) {
        await _getAssetsInfo();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/connection_info.json');
        if (await file.exists()) {
          String fileString = decryptMyData(await file.readAsString()) ?? '';
          List<dynamic> jsonData = json.decode(fileString);
          // remoteServerUri = jsonData['remoteServerUri'];
          for (var element in jsonData) {
            connectionDataList.add(ConnectionData.fromJson(element));
          }
          final File configFile = File('${directory.path}/config.json');
          fileString = decryptMyData(await configFile.readAsString()) ?? '';
          Map<String, dynamic> jsonConfig = json.decode(fileString);
          _activeIndex = jsonConfig['activeIndex'];
          // localServerName = jsonData['localServerName'];
          // remoteServerName = jsonData['remoteServerName'];
          // remoteUser = jsonData['remoteUser'];
          // remoteDomain = jsonData['remoteDomain'];
          // localWiFiConnectionName = jsonData['localWiFiConnectionName'];
        } else {
          await _getAssetsInfo();
        }
      }
      notifyListeners();
    }
    //}
  }

  Future<void> _getAssetsInfo() async {
    try {
      String fileString =
          await rootBundle.loadString('assets/json/remote_connection.json');
      List<dynamic> jsonData = json.decode(fileString);
      // remoteServerUri = jsonData['remoteServerUri'];
      for (var element in jsonData) {
        connectionDataList.add(ConnectionData.fromJson(element));
      }
      _activeIndex = 0;
      print('RemoteConnection :: $localServerName, $localWiFiConnectionName');
    } on Exception catch (e) {
      print('RemoteConnection :: $e');
      throw Exception(e);
    }
  }

  Future<bool> saveConnectionInfo() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/connection_info.json');
      // final dataToPrint = {
      //   "localServerName": localServerName,
      //   "remoteServerName": remoteServerName,
      //   "remoteUser": remoteUser,
      //   "remoteDomain": remoteDomain,
      //   "localWiFiConnectionName": localWiFiConnectionName
      // };
      String stringToWrite = encryptMyData(jsonEncode(connectionDataList));
      await file.writeAsString(stringToWrite);
      final File configFile = File('${directory.path}/config.json');
      stringToWrite = encryptMyData(jsonEncode({"activeIndex": _activeIndex}));
      await configFile.writeAsString(stringToWrite);
    }
    // forzo il ricaricare i valori
    connectionDataList = [];
    getConnectionInfo();
    return true;
  }

  Future<bool> checkLocalName({String? nameValue}) async {
    bool ipOK = false;
    // String? ipValue;
    // nameValue ?? remoteServerName;
    // List<InternetAddress> ipValues = await InternetAddress.lookup(nameValue!);
    nameValue ??= localServerName;
    if (nameValue != null) {
      try {
        http.Response httpResponse =
            await http.get(Uri.parse('http://$nameValue:$port/'));
        if (httpResponse.statusCode == 200 &&
            httpResponse.body == 'Domo_Server is here!') {
          ipOK = true;
        }
      } on Exception catch (e) {
        print('RemoteConnectionError :: $e');
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

  Future<bool> checkLocal() async {
    if (kIsWeb) {
      return await checkLocalName();
    } else if (connectivity == 2) {
      return await checkLocalWiFi();
    } else {
      return false;
    }
  }

  Future<String?> getWifiName() async {
    return await _getWifiName();
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
