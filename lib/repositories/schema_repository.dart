import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:path_provider/path_provider.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestione_domotica/repositories/encrypt_data.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:synchronized/synchronized.dart';

// http constant
// const String localFileUri = 'domo_conf.json';
// const String localBackUri = 'domo_conf.jpg';
const String port = '8085';

/// Classe che contiene lo schema del sistema
class SchemaRepository extends ChangeNotifier {
  // costruttori
  static final SchemaRepository _instance = SchemaRepository._internal();

  factory SchemaRepository() {
    return _instance;
  }

  SchemaRepository._internal() {
    remoteConnection = RemoteConnection();
    remoteConnection!.addListener(() async {
      reload = true;
      await lock.synchronized(_getInfo);
    }, ['activeIndex', 'connectivity', 'connectionInfo', 'connectionConf']);
    remoteConnection!.getConnectionInfo();
    print('Istanzio il getter dello schema');
  }

  //variabili
  Map<String, dynamic> schemaTree = {};
  Image? _sensoriBack;
  final info = NetworkInfo();
  RemoteConnection? remoteConnection;
  String? remoteFileUri;
  String? remoteBackUri;
  bool reload = true;
  var lock = Lock();

  // Future<void> setRemoteVariables() async {
  //   if (remoteConnection != null) {
  //     if (remoteConnection!.localWiFiConnectionName != null &&
  //         remoteConnection!.remoteServerUri != null) {
  //       remoteFileUri =
  //           'http://${remoteConnection!.remoteServerUri}:$port/get/domo_json';
  //       remoteBackUri =
  //           'http://${remoteConnection!.remoteServerUri}:$port/get/domo_image';
  //       notifyListeners();
  //     }
  //   }
  // }

  Future<Map<String, dynamic>> get schema async {
    await lock.synchronized(_getInfo);
    return schemaTree;
  }

  Future<Image?> get sensoriBack async {
    await lock.synchronized(_getInfo);
    return _sensoriBack;
  }

  // prendo le info
  Future<void> _getInfo() async {
    if (reload) {
      schemaTree = {};
      _sensoriBack = null;
      await _getSchema();
      await _getSensoriBack();
      reload = false;
      notifyListeners();
    }
  }

  Future<void> _getSchema() async {
    final directory = await getApplicationDocumentsDirectory();
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent) {
      if (await remoteConnection!.checkLocal()) {
        // String? localWiFi = await remoteConnection!.getWifiName();
        // //  await info.getWifiName();
        // String? savedWiFi = remoteConnection!.localWiFiConnectionName;
        schemaTree = await _getJsonFromRemote('domo_json',
            '${directory.path}/domo_${remoteConnection!.connectionName}.json');
      } else if (!kIsWeb) {
        schemaTree = await _getJsonFromLocal(
            '${directory.path}/domo_${remoteConnection!.connectionName}.json');
      }
    }
  }

  Future<void> _getSensoriBack() async {
    final directory = await getApplicationDocumentsDirectory();
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent) {
      if (await remoteConnection!.checkLocal()) {
        // String? localWiFi = await remoteConnection!.getWifiName();
        // String? savedWiFi = remoteConnection!.localWiFiConnectionName;
        _sensoriBack = await _getImageFromRemote('domo_image',
            '${directory.path}/domo_${remoteConnection!.connectionName}.jpg');
      } else if (!kIsWeb) {
        _sensoriBack = await _getImageFromLocal(
            '${directory.path}/domo_${remoteConnection!.connectionName}.jpg');
      }
    }
  }

  Future<Map<String, dynamic>> _getJsonFromLocal(String fileName) async {
    final File file = File(fileName);
    if (await file.exists()) {
      String fileString = await file.readAsString();
      return json.decode(fileString);
    } else {
      return {};
    }
    //notifyListeners();
  }

  Future<Image?> _getImageFromLocal(String fileName) async {
    final File file = File(fileName);
    if (await file.exists()) {
      return Image.file(file);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJsonFromRemote(
      String urlName, String fileName) async {
    // HttpClient httpClient = HttpClient()
    //   ..badCertificateCallback =
    //       ((X509Certificate cert, String host, int port) => true);
    // io_client.IOClient ioClient = io_client.IOClient(httpClient);
    remoteFileUri =
        'http://${remoteConnection!.localServerName}:$port/get/${urlName}';
    // http.Response? httpResponse = await lock.synchronized(() async {
    //   return http.get(Uri.parse(remoteFileUri!));
    // });
    http.Response httpResponse = await http.get(Uri.parse(remoteFileUri!));
    //http.Response httpResponse = await ioClient.get(Uri.parse(remoteFileUri));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      saveJson(httpResponse.body, fileName);
      return json.decode(httpResponse.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return {};
    }
  }

  Future<Image?> _getImageFromRemote(String urlName, String fileName) async {
    remoteBackUri =
        'http://${remoteConnection!.localServerName}:$port/get/${urlName}';
    // http.Response? httpResponse = await lock.synchronized(() async {
    //   return http.get(Uri.parse(remoteBackUri!));
    // });
    http.Response httpResponse = await http.get(Uri.parse(remoteBackUri!));
    //http.Response httpResponse = await ioClient.get(Uri.parse(remoteFileUri));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      saveImage(httpResponse.bodyBytes, fileName);
      return Image.memory(httpResponse.bodyBytes);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return null;
    }
  }

  Future<void> saveJson(schemaData, String fileName) async {
    if (!kIsWeb) {
      final File file = File(fileName);
      String stringToWrite = schemaData;
      await file.writeAsString(stringToWrite);
    }
  }

  Future<void> saveImage(imageData, String fileName) async {
    if (!kIsWeb) {
      final File file = File(fileName);
      await file.writeAsBytes(imageData);
    }
  }
}
