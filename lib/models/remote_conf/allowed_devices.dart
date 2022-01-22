import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:gestione_domotica/models/remote_conf/allowed_device.dart';
import 'package:gestione_domotica/models/remote_conf/remote_connection.dart';
import 'package:path_provider/path_provider.dart';

/// Classe che contiene la gestione dei dispositivi autorizzati
// ignore: mixin_inherits_from_not_object
class AllowedDevices with ChangeNotifier {
  // costruttori
  AllowedDevices() : super() {
    remoteConnection = RemoteConnection();
    remoteConnection!.addListener(_getAllowedDevice);
    _getAllowedDevice();
  }

  // variabili
  List<AllowedDevice> allowedDevices = [];
  final info = NetworkInfo();
  RemoteConnection? remoteConnection;

  void allowedDevice(bool? set, int i) {
    allowedDevices[i].auth = set ?? false;
    notifyListeners();
  }

  //metodi
  // prendo i device autorizzati dal web
  Future<void> _getAllowedDevice() async {
    // abilito lo scaricamento da web o da rete locale
    if ((remoteConnection != null &&
            await remoteConnection!.getLocalWiFiConnectionName() != null &&
            await remoteConnection!.getRemoteServerUri() != null) &&
        (kIsWeb ||
            (await info.getWifiName() ==
                await remoteConnection!.getLocalWiFiConnectionName()))) {
      List<Map<String, dynamic>> localJson =
          await _getAllowedDeviceFromRemote();
      if (localJson.isNotEmpty) {
        for (var element in localJson) {
          allowedDevices.add(AllowedDevice.fromJson(element));
        }
      }
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _getAllowedDeviceFromRemote() async {
    String? serverUri = await remoteConnection!.getRemoteServerUri();
    http.Response httpResponse = await http
        .get(Uri.parse('http://${serverUri}:8080/get/allowed_device'));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return json.decode(httpResponse.body);
    } else {
      // If the server did not return a 200 OK response,
      // return empty
      // Ecample of throw an exception.
      //throw Exception('Failed to load album');
      return [];
    }
  }
}
