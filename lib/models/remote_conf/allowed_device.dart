import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_connection.dart';

class AllowedDevice with ChangeNotifier {
  // costruttori
  AllowedDevice(
      {required this.nome,
      required this.name,
      required this.mac,
      required this.auth})
      : super();

  AllowedDevice.fromRemote() : super() {
    setupConnection();
  }

  String? nome;
  String name = '';
  String mac = '';
  bool auth = false;
  RemoteConnection? remoteConnection;

// conversione Json
  AllowedDevice.fromJson(Map<String, dynamic> json) : super() {
    setJson(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'nome': nome,
      'name': name,
      'mac': mac,
      'auth': auth
    };
    return result;
  }

  void setupConnection() {
    remoteConnection = RemoteConnection();
    remoteConnection!.addListener(getAllowedDevice);
    remoteConnection!.getConnectionInfo();
    if (!remoteConnection!.connectionDataNull) {
      getAllowedDevice();
    }
  }

  void setJson(Map<String, dynamic> json) {
    nome = json['nome'];
    name = json['name'];
    mac = json['mac'];
    auth = json['auth'] ?? false;
  }

  // prendo i device autorizzati dal web
  Future<void> getAllowedDevice() async {
    // abilito lo scaricamento da web o da rete locale
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent &&
        await remoteConnection!.checkLocal()) {
      dynamic localJson = await _getAllowedDeviceFromRemote();
      if (localJson.isNotEmpty) {
        setJson(localJson);
      }
    }
    notifyListeners();
  }

  Future<dynamic> _getAllowedDeviceFromRemote() async {
    String? serverUri = remoteConnection!.localServerName;
    http.Response httpResponse = await http
        .get(Uri.parse('http://${serverUri}:$port/get/allowed_device'));
    if (httpResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return json.decode(httpResponse.body);
    } else {
      // If the server did not return a 200 OK response,
      // return empty
      // Ecample of throw an exception.
      //throw Exception('Failed to load album');
      return {};
    }
  }

  // invio i dati device al server remoto
  Future<void> saveAllowedDevice() async {
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent &&
        await remoteConnection!.checkLocal()) {
      if (await _saveAllowedDeviceToRemote()) {
        await getAllowedDevice();
      }
    }
  }

  // invio i dati device al server remoto
  Future<bool> _saveAllowedDeviceToRemote() async {
    String? serverUri = remoteConnection!.localServerName;
    String stringToSave = jsonEncode(toJson());
    http.Response httpResponse = await http.post(
        Uri.parse('http://${serverUri}:$port/post/allowed_device'),
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
}
