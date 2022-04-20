import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:gestione_domotica/models/configurazioni/allowed_device.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:path_provider/path_provider.dart';

const String port = '8085';

/// Classe che contiene la gestione dei dispositivi autorizzati
// ignore: mixin_inherits_from_not_object
class AllowedDevices with ChangeNotifier {
  // costruttori
  AllowedDevices() : super() {
    remoteConnection = RemoteConnection();
    remoteConnection!.addListener(getAllowedDevices,
        ['activeIndex', 'connectivity', 'connectionInfo', 'connectionConf']);
    remoteConnection!.getConnectionInfo();
    if (!remoteConnection!.connectionDataNull) {
      getAllowedDevices();
    }
  }

  // variabili
  List<AllowedDevice> allowedDevices = [];
  final info = NetworkInfo();
  RemoteConnection? remoteConnection;

  //metodi
  void allowedDevice(bool? set, int i) {
    allowedDevices[i].auth = set ?? false;
    notifyListeners();
  }

  void setNomeDevice(String? nome, int i) {
    allowedDevices[i].nome = nome ?? allowedDevices[i].name;
    notifyListeners();
  }

  void setNomiDevices(List<String?> nomi) {
    for (var i = 0; i < nomi.length; i++) {
      allowedDevices[i].nome = nomi[i] ?? allowedDevices[i].name;
    }
    notifyListeners();
  }

  // Salvo i devices e li ricarico
  Future<void> saveAllowedDevices() async {
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent &&
        await remoteConnection!.checkLocal()) {
      if (await _saveAllowedDevicesToRemote()) {
        await getAllowedDevices();
      }
    }
  }

  // prendo i device autorizzati dal web
  Future<void> getAllowedDevices() async {
    // abilito lo scaricamento da web o da rete locale
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent &&
        await remoteConnection!.checkLocal()) {
      List<dynamic> localJson = await _getAllowedDevicesFromRemote();
      if (localJson.isNotEmpty) {
        for (var element in localJson) {
          allowedDevices.add(AllowedDevice.fromJson(element));
        }
      }
    } else {
      allowedDevices = [];
    }
    notifyListeners();
  }

  Future<List<dynamic>> _getAllowedDevicesFromRemote() async {
    String? serverUri = remoteConnection!.localServerName;
    http.Response httpResponse = await http
        .get(Uri.parse('http://${serverUri}:$port/get/allowed_devices'));
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

  // invio i dati device al server remoto
  Future<bool> _saveAllowedDevicesToRemote() async {
    String? serverUri = remoteConnection!.localServerName;
    String stringToSave = jsonEncode(toJson());
    http.Response httpResponse = await http.post(
        Uri.parse('http://${serverUri}:$port/post/allowed_devices'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: stringToSave);
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return true;
    } else {
      // If the server did not return a 200 OK response,
      // return empty
      // Ecample of throw an exception.
      //throw Exception('Failed to load album');
      return false;
    }
  }

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> result = [];
    for (AllowedDevice device in allowedDevices) {
      result.add(device.toJson());
    }
    return result;
  }
}
