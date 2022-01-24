import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_connection.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:path_provider/path_provider.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:network_info_plus/network_info_plus.dart';

// http constant
const String localFileUri = 'domo_conf.json';
const String localBackUri = 'domo_conf.jpg';
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
    remoteConnection!.addListener(() => {notifyListeners()});
    print('Istanzio il getter dello schema');
  }

  //variabili
  Map<String, dynamic> schemaTree = {};
  Image? _sensoriBack;
  final info = NetworkInfo();
  RemoteConnection? remoteConnection;
  String? remoteFileUri;
  String? remoteBackUri;

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
    if (schemaTree.isEmpty) {
      await _getSchema();
    }
    return schemaTree;
  }

  Future<Image?> get sensoriBack async {
    if (_sensoriBack == null) {
      await _getSensoriBack();
    }
    return _sensoriBack;
  }

  Future<void> _getSchema() async {
    if (remoteConnection != null &&
        await remoteConnection!.getLocalWiFiConnectionName() != null &&
        await remoteConnection!.getRemoteServerUri() != null) {
      remoteFileUri =
          'http://${await remoteConnection!.getRemoteServerUri()}:$port/get/domo_json';
      remoteBackUri =
          'http://${await remoteConnection!.getRemoteServerUri()}:$port/get/domo_image';
      String? localWiFi = await remoteConnection!.getWifiName();
      //  await info.getWifiName();
      String? savedWiFi = await remoteConnection!.getLocalWiFiConnectionName();
      if (kIsWeb || (savedWiFi == savedWiFi)) {
        schemaTree = await _getSchemaFromRemote();
      } else {
        schemaTree = await _getSchemaFromLocal();
      }
    }
  }

  Future<void> _getSensoriBack() async {
    if (remoteConnection != null &&
        await remoteConnection!.getLocalWiFiConnectionName() != null &&
        await remoteConnection!.getRemoteServerUri() != null) {
      remoteFileUri =
          'http://${await remoteConnection!.getRemoteServerUri()}:$port/get/domo_json';
      remoteBackUri =
          'http://${await remoteConnection!.getRemoteServerUri()}:$port/get/domo_image';
      String? localWiFi = await remoteConnection!.getWifiName();
      String? savedWiFi = await remoteConnection!.getLocalWiFiConnectionName();
      if (kIsWeb || (savedWiFi == savedWiFi)) {
        _sensoriBack = await _getSensoriBackFromRemote();
      } else {
        _sensoriBack = await _getSensoriBackFromLocal();
      }
    }
  }

  Future<Map<String, dynamic>> _getSchemaFromLocal() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$localFileUri');
    if (await file.exists()) {
      String fileString = await file.readAsString();
      return json.decode(fileString);
    } else {
      return {};
    }
    //notifyListeners();
  }

  Future<Image?> _getSensoriBackFromLocal() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$localBackUri');
    if (await file.exists()) {
      return Image.file(file);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getSchemaFromRemote() async {
    // HttpClient httpClient = HttpClient()
    //   ..badCertificateCallback =
    //       ((X509Certificate cert, String host, int port) => true);
    // io_client.IOClient ioClient = io_client.IOClient(httpClient);
    http.Response httpResponse = await http.get(Uri.parse(remoteFileUri!));
    //http.Response httpResponse = await ioClient.get(Uri.parse(remoteFileUri));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      saveSchema(httpResponse.body);
      return json.decode(httpResponse.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return {};
    }
  }

  Future<Image?> _getSensoriBackFromRemote() async {
    http.Response httpResponse = await http.get(Uri.parse(remoteBackUri!));
    //http.Response httpResponse = await ioClient.get(Uri.parse(remoteFileUri));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      saveSensoriBack(httpResponse.bodyBytes);
      return Image.memory(httpResponse.bodyBytes);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return null;
    }
  }

  Future<void> saveSchema(schemaData) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$localFileUri');
      await file.writeAsString(schemaData);
    }
  }

  Future<void> saveSensoriBack(imageData) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$localBackUri');
      await file.writeAsBytes(imageData);
    }
  }
}
