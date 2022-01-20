import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_layer.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/dot_indicator.dart';
import 'package:provider/provider.dart';

class ConfPage extends StatelessWidget {
  ConfPage({Key? key}) : super(key: key) {
    // mqttClientWrapper = MQTTClientWrapper();
    // if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
    //   _connect();
    // }
    // mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  // MQTTClientWrapper? mqttClientWrapper;

  // void _connect() {
  //   mqttClientWrapper!.connectMqttClient();
  // }

  // : super(key: key);
  PageController _controller = PageController(
    initialPage: 0,
  );

  int _counter = 0;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

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
        child: Column(children: <Widget>[
          allowedDevice(),
        ]));
  }

  Widget remoteConnection() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      return Column(children: [
        TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Server IP',
            ),
            initialValue: remoteConnection.remoteServerUri,
            onFieldSubmitted: (String value) =>
                remoteConnection.remoteServerUri = value),
        TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Local WiFi Name',
            ),
            initialValue: remoteConnection.localWiFiConnectionName,
            onFieldSubmitted: (String value) =>
                remoteConnection.localWiFiConnectionName = value),
      ]);
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

  // Widget connectionState() {
  //   if (widget.mqttClientWrapper == null ||
  //     widget.mqttClientWrapper!.connectionState != MqttCurrentConnectionState.CONNECTED) {
  //       return Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
  //   } else {
  //     return Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
  //   }
  // }
}
