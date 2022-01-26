import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_layer.dart';
//import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';
import 'package:gestione_domotica/widget/dot_indicator.dart';
import 'package:gestione_domotica/widget/remote_device_manager.dart';
import 'package:provider/provider.dart';

import 'main_drawer.dart';

class ConfPage extends StatelessWidget {
  ConfPage({Key? key}) : super(key: key) {
    // mqttClientWrapper = MQTTClientWrapper();
    // if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
    //   _connect();
    // }
    // mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  // variabili
  // MQTTClientWrapper? mqttClientWrapper;

  // void _connect() {
  //   mqttClientWrapper!.connectMqttClient();
  // }

  PageController _controller = PageController(
    initialPage: 0,
  );

  int _counter = 0;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  final _formAllowedKey = GlobalKey<FormState>();
  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: ConnectionIcon(),
          title: Text('Gestione Domotica'),
        ),
        endDrawer: const MainDrawer(),
        body: MultiProvider(
            providers: [
              ChangeNotifierProvider<AllowedDevices>(
                create: (_) => AllowedDevices(),
              ),
              ChangeNotifierProvider<RemoteConnection>(
                create: (_) => RemoteConnection(),
              )
            ],
            child: Column(children: <Widget>[
              remoteConnection(),
              allowedDevice(),
              RemoteDeviceManage(),
            ])));
  }

  Widget remoteConnection() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      final ipController =
          TextEditingController(text: remoteConnection.remoteServerUri);
      final wiFiController =
          TextEditingController(text: remoteConnection.localWiFiConnectionName);
      final _formfKey = GlobalKey<FormState>();
      return Form(
        key: _formfKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: ipController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Server IP',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (value) {
                remoteConnection.remoteServerUri = value;
              },
            ),
            Row(
              children: [
                TextFormField(
                  controller: wiFiController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Local WiFi Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    remoteConnection.localWiFiConnectionName = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    wiFiController.text =
                        await remoteConnection.getWifiName() ?? "";
                  },
                  child: const Text('Local WiFi'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formfKey.currentState!.validate() &&
                      await remoteConnection.checkLocalIP(
                          ipValue: ipController.text) &&
                      await remoteConnection.checkLocalWiFi(
                          wiFiValue: wiFiController.text)) {
                    _formfKey.currentState!.save();
                    remoteConnection.saveConnectionInfo();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    mostraSnackBar('Aggiornato', context);
                  } else {
                    mostraSnackBar('Problema nell\'aggiornamento', context);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget allowedDevice() {
    return Consumer<AllowedDevices>(builder:
        (BuildContext context, AllowedDevices allowedDevices, Widget? child) {
      return Expanded(
        child: ListView.builder(
          itemCount: allowedDevices.allowedDevices.length,
          itemBuilder: (BuildContext context, int index) {
            if (allowedDevices.allowedDevices.isEmpty) {
              return const Text('nessuna autorizzazione trovata');
            }
            final item = Row(
              children: [
                Checkbox(
                  checkColor: Colors.black,
                  value: allowedDevices.allowedDevices[index].auth,
                  onChanged: (bool? value) {
                    allowedDevices.allowedDevice(value, index);
                  },
                ),
                Text(allowedDevices.allowedDevices[index].name,
                    textAlign: TextAlign.center),
                Text(allowedDevices.allowedDevices[index].nameArp,
                    textAlign: TextAlign.center),
              ],
            );
            return item;
          },
        ),
      );
    });
  }

  void mostraSnackBar(String testo, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(testo),
      // action: SnackBarAction(
      //   label: 'Undo',
      //   onPressed: () {
      //     // Some code to undo the change.
      //   },
      // ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  // Widget connectionState() {
  //   if (widget.mqttClientWrapper == null ||
  //     widget.mqttClientWrapper!.connectionState != MqttCurrentConnectionState.CONNECTED) {
  //       return Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
  //   } else {
  //     return Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
  //   }
  // }
}
