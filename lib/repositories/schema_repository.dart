import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:path_provider/path_provider.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestione_domotica/conf/conf_cost.dart';
import 'package:network_info_plus/network_info_plus.dart';

const String localFileUri = 'domo_conf.json';
const String localBackUri = 'domo_conf.jpg';
const String remoteFileUri = 'http://$remoteServerUri:8080/get/domo_json';
const String remoteBackUri = 'http://$remoteServerUri:8080/get/domo_image';

/// Classe che contiene lo schema del sistema
class SchemaRepository extends PropertyChangeNotifier<String> {
  // costruttori
  static final SchemaRepository _instance = SchemaRepository._internal();

  factory SchemaRepository() {
    return _instance;
  }

  SchemaRepository._internal() {
    print('Istanzio il getter dello schema');
  }

  //variabili
  Map<String, dynamic> schemaTree = {};
  Image? _sensoriBack;
  final info = NetworkInfo();

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
    if (kIsWeb) {
      schemaTree = await getSchemaFromRemote();
    } else {
      schemaTree = await getSchemaFromLocal();
      if (schemaTree.isEmpty) {
        var wifiName = await info.getWifiName();
        if (wifiName == localWiFiConnectionName) {
          schemaTree = await getSchemaFromRemote();
        }
      }
    }
  }

  Future<void> _getSensoriBack() async {
    if (kIsWeb) {
      _sensoriBack = await getSensoriBackFromRemote();
    } else {
      _sensoriBack = await getSensoriBackFromLocal();
      if (_sensoriBack == null) {
        var wifiName = await info.getWifiName();
        if (wifiName == localWiFiConnectionName) {
          _sensoriBack = await getSensoriBackFromRemote();
        }
      }
    }
  }

  Future<Map<String, dynamic>> getSchemaFromLocal() async {
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

  Future<Image?> getSensoriBackFromLocal() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$localBackUri');
    if (await file.exists()) {
      return Image.file(file);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getSchemaFromRemote() async {
    // HttpClient httpClient = HttpClient()
    //   ..badCertificateCallback =
    //       ((X509Certificate cert, String host, int port) => true);
    // io_client.IOClient ioClient = io_client.IOClient(httpClient);
    http.Response httpResponse = await http.get(Uri.parse(remoteFileUri));
    //http.Response httpResponse = await ioClient.get(Uri.parse(remoteFileUri));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return json.decode(httpResponse.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return {};
    }
  }

  Future<Image?> getSensoriBackFromRemote() async {
    http.Response httpResponse = await http.get(Uri.parse(remoteBackUri));
    //http.Response httpResponse = await ioClient.get(Uri.parse(remoteFileUri));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Image.memory(httpResponse.bodyBytes);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return const Image(image: AssetImage('sfondo_vuoto.png'));
    }
  }

  Future<void> saveSchema() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$localFileUri');
    await file.writeAsString(json.encode(schemaTree));
  }
}
