import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestione_domotica/models/configurazioni/connection_data.dart';
import 'package:gestione_domotica/models/configurazioni/local_data.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
// import 'package:gestione_domotica/models/remote_conf/allowed_device.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:synchronized/synchronized.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gestione_domotica/repositories/encrypt_data.dart';

//import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
//import 'package:gestione_domotica/models/remote_conf/connection_data.dart';
// import 'package:wifi_iot/wifi_iot.dart';

const String port = '8085';

/// Classe che contiene la gestione dei dispositivi autorizzati
// ignore: mixin_inherits_from_not_object
class RemoteConnection extends PropertyChangeNotifier<String> {
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
  LocalData localData = LocalData();
  //String? connectionName;
  //String? localServerName;
  //String? remoteServerName;
  //String? remoteUser;
  //String? remoteDomain;
  //String? localWiFiConnectionName;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  // PermissionWithService locationPermission = Permission.locationWhenInUse;
  var lock = Lock(reentrant: true);

  String _serverCodeController = '';

  // getter & setter
  int get activeIndex => localData.activeIndex;

  set activeIndex(int activeIndex) {
    bool changeFire = false;
    if (activeIndex != localData.activeIndex) {
      // if (connectionDataList.token == '') {
      //   connectionDataList.last.token = (await FirebaseMessaging.instance.getToken())!;
      //   FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
      // }
      //unSubscribeFirebase();
      changeFire = true;
    }
    if (connectionDataList.length < activeIndex) {
      localData.activeIndex = connectionDataList.length - 1;
    } else if (activeIndex < 0) {
      localData.activeIndex = 0;
    } else {
      localData.activeIndex = activeIndex;
    }
    // if (changeFire) {
    //   subscribeFirebase();
    // }
    notifyListeners('activeIndex');
  }

  String? get connectionName {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].connectionName;
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

  ConnectionData? get activeConnectionData {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex];
    } else {
      return null;
    }
  }

  String? get localServerName {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].localServerName;
    } else {
      return null;
    }
  }

  set localServerName(String? localServerName) {
    connectionDataList[localData.activeIndex].localServerName =
        localServerName ?? '';
  }

  String? get remoteServerName {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].remoteServerName;
    } else {
      return null;
    }
  }

  String? get remoteUser {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].remoteUser;
    } else {
      return null;
    }
  }

  String? get remotePassword {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0 &&
        connectionDataList[localData.activeIndex].remotePassword != '') {
      return connectionDataList[localData.activeIndex].remotePassword;
    } else {
      return null;
    }
  }

  String? get certDirBase {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0 &&
        connectionDataList[localData.activeIndex].certDirBase != '') {
      return connectionDataList[localData.activeIndex].certDirBase;
    } else {
      return null;
    }
  }

  String? get caFile {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0 &&
        connectionDataList[localData.activeIndex].caFile != '') {
      return connectionDataList[localData.activeIndex].caFile;
    } else {
      return null;
    }
  }

  String? get certFile {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0 &&
        connectionDataList[localData.activeIndex].caFile != '') {
      return connectionDataList[localData.activeIndex].certFile;
    } else {
      return null;
    }
  }

  String? get keyFile {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0 &&
        connectionDataList[localData.activeIndex].keyFile != '') {
      return connectionDataList[localData.activeIndex].keyFile;
    } else {
      return null;
    }
  }

  String? get remoteDomain {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].remoteDomain;
    } else {
      return null;
    }
  }

  String? get localWiFiConnectionName {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].localWiFiConnectionName;
    } else {
      return null;
    }
  }

  set localWiFiConnectionName(String? localWiFiConnectionName) {
    connectionDataList[localData.activeIndex].localWiFiConnectionName =
        localWiFiConnectionName ?? '';
  }

  int get id {
    if (connectionDataList.length > localData.activeIndex &&
        localData.activeIndex >= 0) {
      return connectionDataList[localData.activeIndex].id;
    } else {
      return -1;
    }
  }

  set activeId(int id) {
    activeIndex = connectionDataList.indexWhere((element) => element.id == id);
  }

  bool get connectionDataNull {
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

  bool get sensoriVisibili => localData.sensoriVisibili;

  set sensoriVisibili(bool sensoriVisibili) {
    if (localData.sensoriVisibili != sensoriVisibili) {
      localData.sensoriVisibili = sensoriVisibili;
      notifyListeners();
    }
  }

  String get token => localData.token;

  //metodi

  addConnection(ConnectionData connectionData) {
    if (connectionData.id < 0) {
      if (connectionDataList.isNotEmpty) {
        connectionData.id =
            connectionDataList[connectionDataList.length - 1].id + 1;
      } else {
        connectionData.id = 0;
      }
    }
    int indexFinded = connectionDataList.indexWhere(
        (element) => element.remoteDomain == connectionData.remoteDomain);
    if (indexFinded < 0) {
      connectionDataList.add(connectionData);
      resetId();
      activeIndex = connectionDataList.length - 1;
      // localData.activeIndex = connectionDataList.length - 1;
      saveConnectionInfo();
    } else {
      connectionDataList[indexFinded] = connectionData;
      resetId();
      activeIndex = indexFinded;
      saveConnectionInfo();
    }
  }

  // metodo per gestire il cambio di connettività
  void resultConnectivityHandler(ConnectivityResult result) {
    _connectivityResult = result;
    subscribeFirebase();
    notifyListeners('connectivity');
  }

  // subscribe a FireBase
  Future<void> subscribeFirebase() async {
    if (connectivity != 0 && connectionDataList.isNotEmpty) {
//      FirebaseMessaging.instance.subscribeToTopic('${remoteDomain}_sirena');
      for (ConnectionData connection in connectionDataList) {
        await FirebaseMessaging.instance
            .subscribeToTopic('${connection.remoteDomain}_allarme');
        print('Firebase subscribe :: ${connection.remoteDomain}_allarme');
        await FirebaseMessaging.instance
            .subscribeToTopic('${connection.remoteDomain}_sensori');
        print('Firebase subscribe :: ${connection.remoteDomain}_sensori');
      }
    }
  }

//   Future<void> unSubscribeFirebase() async {
//     if (connectivity != 0 && remoteDomain != null) {
// //      FirebaseMessaging.instance.subscribeToTopic('${remoteDomain}_sirena');
//       await FirebaseMessaging.instance
//           .subscribeToTopic('${remoteDomain}_allarme');
//       print('Firebase unSubscribe :: ${remoteDomain}_allarme');
//     }
//   }

  // prendo le info di connessioni
  Future<void> getConnectionInfo() async {
    await lock.synchronized(_getConnectionInfo);
    await lock.synchronized(_getConnectionConf);
    subscribeFirebase();
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
          try {
            String fileString = decryptMyData(await file.readAsString()) ?? '';
            List<dynamic> jsonData = json.decode(fileString);
            // remoteServerUri = jsonData['remoteServerUri'];
            for (int i = 0; i < jsonData.length; i++) {
              ConnectionData localConnectionData =
                  ConnectionData.fromJson(jsonData[i]);
              localConnectionData.id = i;
              connectionDataList.add(localConnectionData);
            }
          } on Exception catch (e) {
            print('ConnectionInfo::client exception - $e');
            await _getAssetsInfo();
          }
          // localServerName = jsonData['localServerName'];
          // remoteServerName = jsonData['remoteServerName'];
          // remoteUser = jsonData['remoteUser'];
          // remoteDomain = jsonData['remoteDomain'];
          // localWiFiConnectionName = jsonData['localWiFiConnectionName'];
        } else {
          await _getAssetsInfo();
        }
      }
      notifyListeners('connectionInfo');
    }
    //}
  }

  Future<void> _getConnectionConf() async {
    //if (localWiFiConnectionName == null && remoteServerUri == null) {
    // ricarico solo se necessario o forzato.
    if (localData.activeIndex < 0) {
      if (kIsWeb) {
        await _getAssetsConf();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/config.json');
        if (await file.exists()) {
          try {
            String fileString = decryptMyData(await file.readAsString()) ?? '';
            Map<String, dynamic> jsonConfig = json.decode(fileString);
            localData = LocalData.fromJson(jsonConfig);
            if (localData.activeIndex < 0 ||
                localData.activeIndex > connectionDataList.length - 1) {
              localData.activeIndex = 0;
            }
            String tmpToken = await FirebaseMessaging.instance.getToken() ?? '';
            if (localData.token == '' || localData.token != tmpToken) {
              localData.token = tmpToken;
              notifyListeners('token');
              //saveConnectionInfo();
            }
            FirebaseMessaging.instance.onTokenRefresh.listen((String? token) {
              localData.token = token ?? '';
              notifyListeners('token');
            });
          } on Exception catch (e) {
            print('ConnectionConf::client exception - $e');
            await _getAssetsConf();
          }
        } else {
          await _getAssetsConf();
        }
      }
      //await subscribeFirebase();
      notifyListeners('connectionConf');
    }
  }

  Future<void> _getAssetsInfo() async {
    try {
      String fileString =
          await rootBundle.loadString('assets/json/connection_info.json');
      List<dynamic> jsonData = json.decode(fileString);
      // remoteServerUri = jsonData['remoteServerUri'];
      for (var element in jsonData) {
        connectionDataList.add(ConnectionData.fromJson(element));
      }
    } on Exception catch (e) {
      print('RemoteConnection :: $e');
      throw Exception(e);
    }
  }

  Future<void> _getAssetsConf() async {
    localData.activeIndex = 0;
    print('RemoteConnection :: $localServerName, $localWiFiConnectionName');
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
      stringToWrite = encryptMyData(jsonEncode(localData.toJson()));
      await configFile.writeAsString(stringToWrite);
    }
    // forzo il ricaricare i valori
    connectionDataList = [];
    getConnectionInfo();
    return true;
  }

  Future<bool> saveConnectionConf() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/config.json');
      String stringToWrite = encryptMyData(jsonEncode(localData.toJson()));
      await file.writeAsString(stringToWrite);
    }
    // forzo il ricaricare i valori
    localData.activeIndex = -1;
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
      //return await checkLocalName();
      return ((await checkLocalWiFi()) && (await checkLocalName()));
    } else {
      return false;
    }
  }

  void removeItem() {
    connectionDataList.removeAt(localData.activeIndex);
    activeIndex = 0;
    resetId();
    saveConnectionInfo();
  }

  void resetId() {
    for (int i = 0; i < connectionDataList.length; i++) {
      connectionDataList[i].id = i;
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

  void connectionState(bool connectionState) {
    if (connectionState) {
      notifyListeners('connectionActive');
    } else {
      notifyListeners('connectionInactive');
    }
  }

  // final key = Key.fromUtf8('chiveDiMassimoCasarin1371Domotic'); //32 chars
  // final iv = IV.fromUtf8('MassimoDomotic13'); //16 chars

}
