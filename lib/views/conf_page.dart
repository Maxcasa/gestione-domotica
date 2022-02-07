import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_layer.dart';
import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
//import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';
import 'package:gestione_domotica/widget/dot_indicator.dart';
import 'package:gestione_domotica/widget/remote_device_manager.dart';
import 'package:provider/provider.dart';

import 'main_drawer.dart';

class ConfPage extends StatelessWidget {
  ConfPage({Key? key}) : super(key: key) {
    mqttClientWrapper = MQTTClientWrapper();
    if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
      _connect();
    }
    mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  // variabili
  MQTTClientWrapper? mqttClientWrapper;

  void _connect() {
    mqttClientWrapper!.connectMqttClient();
  }

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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AllowedDevices>(
            create: (_) => AllowedDevices(),
          ),
          ChangeNotifierProvider<RemoteConnection>(
            create: (_) => RemoteConnection(),
          )
        ],
        child: Scaffold(
            appBar: AppBar(
              leading: ConnectionIcon(),
              title: Text('Gestione Domotica'),
            ),
            endDrawer: const MainDrawer(),
            body: Column(children: <Widget>[
              remoteConnection(),
              Divider(color: Colors.black),
              allowedDevice(),
              Divider(color: Colors.black),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: RemoteDeviceManage(),
              )
            ])));
  }

  Widget remoteConnection() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      final nameController =
          TextEditingController(text: remoteConnection.remoteServerName);
      final wiFiController =
          TextEditingController(text: remoteConnection.localWiFiConnectionName);
      final _formfKey = GlobalKey<FormState>();
      return Form(
        key: _formfKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                width: 200,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Server Name',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    remoteConnection.remoteServerName = value;
                  },
                )),
            Row(
              children: [
                Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    width: 200,
                    child: TextFormField(
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
                    )),
                ElevatedButton(
                  onPressed: () async {
                    wiFiController.text =
                        await remoteConnection.getWifiName() ?? "";
                  },
                  child: const Text('Local WiFi'),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formfKey.currentState!.validate() &&
                      await remoteConnection.checkLocalName(
                          nameValue: nameController.text) &&
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
      List<TextEditingController> _controllers = [];
      for (AllowedDevice device in allowedDevices.allowedDevices) {
        _controllers.add(TextEditingController(text: device.nome));
      }
      return Flexible(
          child: ListView.builder(
              itemCount: allowedDevices.allowedDevices.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (allowedDevices.allowedDevices.isEmpty) {
                  return const Text('nessuna autorizzazione trovata');
                }
                Widget item;
                if (index != allowedDevices.allowedDevices.length) {
                  item = Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.black,
                        value: allowedDevices.allowedDevices[index].auth,
                        onChanged: (bool? value) {
                          allowedDevices.allowedDevice(value, index);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        width: 200,
                        child: TextFormField(
                          controller: _controllers[index],
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Device name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                      ),
                      Text(allowedDevices.allowedDevices[index].name,
                          textAlign: TextAlign.center),
                    ],
                  );
                } else {
                  item = Container(
                    width: 100,
                    margin: EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        List<String?> deviceNameList = [];
                        for (TextEditingController controller in _controllers) {
                          deviceNameList.add(controller.text);
                        }
                        allowedDevices.setNomiDevices(deviceNameList);
                        allowedDevices.saveAllowedDevice();
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        mostraSnackBar('Aggiornato', context);
                      },
                      child: const Text('Submit'),
                    ),
                  );
                }
                return item;
              }));
      // Align(
      //   alignment: Alignment.bottomCenter,
      //   child: Container(
      //     margin: EdgeInsets.all(10),
      //     padding: const EdgeInsets.symmetric(vertical: 16.0),
      //     child: ElevatedButton(
      //       onPressed: () {
      //         // Validate returns true if the form is valid, or false otherwise.
      //         List<String?> deviceNameList = [];
      //         for (TextEditingController controller in _controllers) {
      //           deviceNameList.add(controller.text);
      //         }
      //         allowedDevices.setNomiDevices(deviceNameList);
      //         allowedDevices.saveAllowedDevice();
      //         // If the form is valid, display a snackbar. In the real world,
      //         // you'd often call a server or save the information in a database.
      //         mostraSnackBar('Aggiornato', context);
      //       },
      //       child: const Text('Submit'),
      //     ),
      //   ),
      // ),
      //]);
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

  Widget connectionState() {
    if (mqttClientWrapper == null ||
        mqttClientWrapper!.connectionState !=
            MqttCurrentConnectionState.CONNECTED) {
      return Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
    } else {
      return Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
    }
  }
}
