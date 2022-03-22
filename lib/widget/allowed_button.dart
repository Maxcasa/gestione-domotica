import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_connection.dart';
import 'package:gestione_domotica/models/remote_conf/remote_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';

/// Classe WIDGET che contiene la gestione per abilitare
/// il join remoto dei dispositivi
class AllowedButton extends StatefulWidget {
  AllowedButton({Key? key}) : super(key: key);

  @override
  _AllowedButtonState createState() => _AllowedButtonState();
}

class _AllowedButtonState extends State<AllowedButton> {
  // RemoteConnection? remoteConnection;
  AllowedDevice? allowedDevice;
  ElevatedButton _button =
      const ElevatedButton(onPressed: null, child: Text('Non collegato'));

  @override
  void initState() {
    // remoteConnection = RemoteConnection();
    allowedDevice = AllowedDevice.fromRemote();
    allowedDevice!.addListener(_setButton);
    print('Istanzio il getter dello schema');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _button;
  }

  @override
  void dispose() {
    allowedDevice!.removeListener(_setButton);
    super.dispose();
  }

  void _setButton() {
    setState(() {
      if (allowedDevice!.nome != null) {
        if (allowedDevice!.auth) {
          _button = ElevatedButton(
              onPressed: () {
                _autorizza(false);
              },
              child: Text('NON AUTORIZZA'));
        } else {
          _button = ElevatedButton(
              onPressed: () {
                _autorizza(true);
              },
              child: Text('AUTORIZZA'));
        }
      }
    });
  }

  void _autorizza(bool auth) {
    allowedDevice!.auth = auth;
    allowedDevice!.saveAllowedDevice();
  }
}
