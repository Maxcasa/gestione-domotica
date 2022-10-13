import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:gestione_domotica/models/utils.dart';
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
      _reloadSchema = true;
      await lock.synchronized(_getSchema);
      _reloadBack = true;
      await lock.synchronized(_getBack);
    }, [
      'activeIndex',
      'connectivity',
      'connectionInfo',
      'connectionConf',
      'connectionActive'
    ]);
    remoteConnection!.getConnectionInfo();
    print('Istanzio il getter dello schema');
  }

  //variabili
  Map<String, dynamic> _schemaTree = {};
  //Map<String, dynamic> _backSchemaTree = {};
  bool _reloadSchema = true;

  Image? _sensoriBack;
  //Image? _backSensoriBack;
  bool _reloadBack = true;

  final info = NetworkInfo();
  RemoteConnection? remoteConnection;
  String? remoteFileUri;
  String? remoteBackUri;

  late final _directory;
  bool _isDirectoryInitialized = false;

  var lock = Lock();
  //var lockJson = Lock();

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
    await lock.synchronized(_getSchema);
    return _schemaTree;
  }

  Future<Image?> get sensoriBack async {
    await lock.synchronized(_getBack);
    return _sensoriBack;
  }

  // prendo le info
  // prendo le info
  Future<void> _getSchema() async {
    if (_reloadSchema) {
      if (remoteConnection != null &&
          !remoteConnection!.connectionDataNull &&
          remoteConnection!.connectionPresent) {
        // schemaTree = {};
        //_sensoriBack = null;
        if (!_isDirectoryInitialized) {
          _directory = await getApplicationDocumentsDirectory();
          _isDirectoryInitialized = true;
        }
        // carico il dato local se c'è
        Map<String, dynamic> _localSchemaTree = {};
        if (!kIsWeb) {
          _localSchemaTree = await _getJsonFromLocal(
              '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
        }
        // se c'è il remote carico anche da li
        if (await remoteConnection!.checkLocal()) {
          // String? localWiFi = await remoteConnection!.getWifiName();
          // //  await info.getWifiName();
          // String? savedWiFi = remoteConnection!.localWiFiConnectionName;
          Map<String, dynamic> _remoteSchemaTree = await _getJsonFromRemote(
              'domo_json',
              '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
          if (_remoteSchemaTree != {} &&
              _remoteSchemaTree != _localSchemaTree) {
            _localSchemaTree = _remoteSchemaTree;
            saveJson(json.encode(_localSchemaTree),
                '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
          }
        }
        if (_localSchemaTree != {} && _localSchemaTree != _schemaTree) {
          _schemaTree = _localSchemaTree;
          notifyListeners();
        }
        _reloadSchema = false;
      }
    }
  }

  Future<void> _getBack() async {
    if (_reloadBack) {
      if (remoteConnection != null &&
          !remoteConnection!.connectionDataNull &&
          remoteConnection!.connectionPresent) {
        // schemaTree = {};
        //_sensoriBack = null;
        if (!_isDirectoryInitialized) {
          _directory = await getApplicationDocumentsDirectory();
          _isDirectoryInitialized = true;
        }
        // carico il dato local se c'è
        Image? _localSensoriBack;
        if (!kIsWeb) {
          _localSensoriBack = await _getImageFromLocal(
              '${_directory.path}/domo_${remoteConnection!.connectionName}.jpg');
        }
        // se c'è il remote carico anche da li
        if (await remoteConnection!.checkLocal()) {
          // String? localWiFi = await remoteConnection!.getWifiName();
          // //  await info.getWifiName();
          // String? savedWiFi = remoteConnection!.localWiFiConnectionName;
          DoubleImage _remoteSensoriBack = await _getImageFromRemote(
              'domo_image',
              '${_directory.path}/domo_${remoteConnection!.connectionName}.jpg');
          if (_remoteSensoriBack.image != null &&
              _remoteSensoriBack.image != _localSensoriBack) {
            _localSensoriBack = _remoteSensoriBack.image;
            if (!kIsWeb) {
              saveFile(_remoteSensoriBack.data,
                  '${_directory.path}/domo_${remoteConnection!.connectionName}.jpg');
            }
          }
          if (remoteConnection!.caFile != null) {
            _getAndSaveFileFromRemote('caFile',
                '${_directory.path}/${remoteConnection!.connectionName}${remoteConnection!.caFile}.pfx');
          }
          if (remoteConnection!.certFile != null) {
            _getAndSaveFileFromRemote('certFile',
                '${_directory.path}/${remoteConnection!.connectionName}${remoteConnection!.certFile}.pfx');
          }
          if (remoteConnection!.keyFile != null) {
            _getAndSaveFileFromRemote('keyFile',
                '${_directory.path}/${remoteConnection!.connectionName}${remoteConnection!.keyFile}.key');
          }
        }
        if (_localSensoriBack != null && _sensoriBack != _localSensoriBack) {
          _sensoriBack = _localSensoriBack;
          notifyListeners();
        }
        _reloadBack = false;
      }
    }
  }

  Future<Map<String, dynamic>> _getJsonFromLocal(String fileName) async {
    final File file = File(fileName);
    try {
      if (await file.exists()) {
        String fileString = await file.readAsString();
        return json.decode(fileString);
      } else {
        return {};
      }
    } catch (e) {
      print('Exception: $e');
      return {};
    }

    //notifyListeners();
  }

  Future<Image?> _getImageFromLocal(String fileName) async {
    final File file = File(fileName);
    try {
      if (await file.exists()) {
        return Image.file(file);
      } else {
        return null;
      }
    } catch (e) {
      print('Exception: $e');
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
      return json.decode(httpResponse.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return {};
    }
  }

  Future<DoubleImage> _getImageFromRemote(
      String urlName, String fileName) async {
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
      Uint8List _imageBase64 = httpResponse.bodyBytes;
      return DoubleImage(Image.memory(_imageBase64), _imageBase64);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      return DoubleImage(null, null);
    }
  }

  Future<void> _getAndSaveFileFromRemote(
      String urlName, String fileName) async {
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
      await saveFile(httpResponse.bodyBytes, fileName);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
    }
  }

  Future<void> saveSchema(Map<String, dynamic> schemaToMerge) async {
    final directory = await getApplicationDocumentsDirectory();
    Map<String, dynamic> _localSchemaTree = {..._schemaTree, ...schemaToMerge};
    Map<String, dynamic> _loadedSchemaTree = await _getJsonFromLocal(
        '${directory.path}/domo_${remoteConnection!.connectionName}.json');
    if (_loadedSchemaTree != _localSchemaTree) {
      _schemaTree = _localSchemaTree;
      await saveJson(json.encode(_localSchemaTree),
          '${directory.path}/domo_${remoteConnection!.connectionName}.json');
    }
  }

  Future<void> saveJson(schemaData, String fileName) async {
    if (!kIsWeb) {
      final File file = File(fileName);
      String stringToWrite = schemaData;
      await file.writeAsString(stringToWrite);
    }
  }

  // Future<void> saveBackImage() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   await saveFile(_sensoriBack,
  //       '${remoteConnection!.certDirBase}domo_${remoteConnection!.connectionName}.jpg');
  // }

  Future<void> saveFile(imageData, String fileName) async {
    if (!kIsWeb) {
      final File file = File(fileName);
      await file.writeAsBytes(imageData);
    }
  }
}
