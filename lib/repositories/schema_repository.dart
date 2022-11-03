import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:gestione_domotica/models/logger.dart';
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
      await lock_sensori.synchronized(_getSchema);
      _reloadBack = true;
      await lock_back.synchronized(_getBack);
    }, [
      'activeIndex',
      'connectivity',
      'connectionInfo',
      'connectionConf',
      'connectionActive'
    ]);
    remoteConnection!.getConnectionInfo();
    if (kDebugMode) {
      print('Istanzio il getter dello schema');
    }
  }

  //variabili
  Map<String, dynamic>? _schemaTree;
  //Map<String, dynamic> _backSchemaTree = {};
  bool _reloadSchema = true;

  final log = logger(SchemaRepository);

  DoubleImage? _sensoriBack;
  //Image? _backSensoriBack;
  bool _reloadBack = true;

  final info = NetworkInfo();
  RemoteConnection? remoteConnection;
  String? remoteFileUri;
  String? remoteBackUri;

  late final _directory;
  bool _isDirectoryInitialized = false;

  var lock_sensori = Lock();
  var lock_back = Lock();
  String _encodedString = '';
  String _uriJsonFile = '';
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

  Future<Map<String, dynamic>?> get schema async {
    await lock_sensori.synchronized(_getSchema);
    return _schemaTree;
  }

  Future<Image?> get sensoriBack async {
    await lock_back.synchronized(_getBack);
    if (_sensoriBack == null) {
      return null;
    } else {
      return _sensoriBack!.image;
    }
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
        Map<String, dynamic>? _localSchemaTree;
        if (!kIsWeb) {
          _localSchemaTree = await _getJsonFromLocal(
              '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
          log.v('Caricato schema locale.');
          log.d('${json.encode(_localSchemaTree)}');
        }
        // se c'è il remote carico anche da li
        if (await remoteConnection!.checkLocal()) {
          // String? localWiFi = await remoteConnection!.getWifiName();
          // //  await info.getWifiName();
          // String? savedWiFi = remoteConnection!.localWiFiConnectionName;
          Map<String, dynamic>? _remoteSchemaTree = await _getJsonFromRemote(
              'domo_json',
              '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
          log.v('Caricato schema remoto.');
          if (_remoteSchemaTree != null &&
              !(checkDoubleMaps(_remoteSchemaTree, _localSchemaTree))) {
            _localSchemaTree = _remoteSchemaTree;
            log.d(json.encode(_localSchemaTree));
            saveJson(json.encode(_localSchemaTree),
                '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
          }
        }
        if (_localSchemaTree != null &&
            !(checkDoubleMaps(_localSchemaTree, _schemaTree))) {
          log.v('Imposto lo schema.');
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
        DoubleImage? _localSensoriBack;
        if (!kIsWeb) {
          _localSensoriBack = await _getImageFromLocal(
              '${_directory.path}/domo_${remoteConnection!.connectionName}.jpg');
        }
        // se c'è il remote carico anche da li
        if (await remoteConnection!.checkLocal()) {
          // String? localWiFi = await remoteConnection!.getWifiName();
          // //  await info.getWifiName();
          // String? savedWiFi = remoteConnection!.localWiFiConnectionName;
          DoubleImage? _remoteSensoriBack = await _getImageFromRemote(
              'domo_image',
              '${_directory.path}/domo_${remoteConnection!.connectionName}.jpg');
          if (_remoteSensoriBack != null &&
              (_localSensoriBack == null ||
                  _remoteSensoriBack.data != _localSensoriBack.data)) {
            _localSensoriBack = _remoteSensoriBack;
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
        if (_localSensoriBack != null &&
            (_sensoriBack == null ||
                _sensoriBack!.data != _localSensoriBack.data)) {
          _sensoriBack = _localSensoriBack;
          notifyListeners();
        }
        _reloadBack = false;
      }
    }
  }

  Future<Map<String, dynamic>?> _getJsonFromLocal(String fileName) async {
    final File file = File(fileName);
    try {
      if (await file.exists()) {
        String fileString = await file.readAsString();
        return json.decode(fileString);
      } else {
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }

    //notifyListeners();
  }

  Future<DoubleImage?> _getImageFromLocal(String fileName) async {
    final File file = File(fileName);
    try {
      if (await file.exists()) {
        Uint8List _imageBase64 = await file.readAsBytes();
        return DoubleImage(Image.memory(_imageBase64), _imageBase64);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getJsonFromRemote(
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
      return null;
    }
  }

  Future<DoubleImage?> _getImageFromRemote(
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
      return null;
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

  Future<void> saveSchema(Map<String, dynamic>? schemaToMerge) async {
    if (_schemaTree != null && schemaToMerge != null) {
      log.d('Schema: ${json.encode(_schemaTree)}');
      log.d('Merge: ${json.encode(schemaToMerge)}');
      Map<String, dynamic> _localSchemaTree = {
        ..._schemaTree!,
        ...schemaToMerge
      };
      if (!(checkDoubleMaps(_schemaTree, _localSchemaTree))) {
        _schemaTree = _localSchemaTree;
        log.i('Salvo lo schema.');
        log.d('${json.encode(_localSchemaTree)}');
        await saveJson(json.encode(_localSchemaTree),
            '${_directory.path}/domo_${remoteConnection!.connectionName}.json');
      }
    }
  }

  Future<void> saveJson(String stringToWrite, String _uriJsonFile) async {
    if (!kIsWeb) {
      final File file = File(_uriJsonFile);
      //String stringToWrite = _encodedString;
      log.d(stringToWrite);
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

  bool checkDoubleMaps(dynamic a, dynamic b) {
    if (checkSingleMaps(a, b) && checkSingleMaps(b, a)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkSingleMaps(dynamic a, dynamic b) {
    if (a is List) {
      if (b is List) {
        if (a.length == b.length) {
          for (var la in a) {
            bool ret = false;
            for (var lb in b) {
              if (checkSingleMaps(la, lb)) {
                ret = true;
                break;
              }
            }
            if (!ret) {
              return false;
            }
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (a is Map) {
      if (b is Map) {
        if (a.length == b.length) {
          for (var aKey in a.keys) {
            bool ret = false;
            for (var bKey in b.keys) {
              if (checkSingleMaps(a[aKey], b[bKey])) {
                ret = true;
                break;
              }
            }
            if (!ret) {
              return false;
            }
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (a == b) {
      return true;
    } else {
      return false;
    }
  }
}
