// import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/views/home_page.dart';
import 'package:gestione_domotica/views/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/stati/stato.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
import 'models/drawer/main_drawer_provider.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //SchemaSensori(id: 0);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<Stato>(
      create: (_) => Stato(id: 0),
    ),
    ChangeNotifierProvider<MainDrawerProvider>(
      create: (_) => MainDrawerProvider('assets/json/drawer_list.json'),
    ),
    ChangeNotifierProvider<SchemaSensoriModel>(
        //   create: (_) => SchemaSensori(id: 0),
        create: (_) => SchemaSensoriModel()),
    // nome: 'test sensori',
    // sensori: [
    //   SensoreInfisso(id: 1, nome: 'Sensore 1'),
    //   SensoreLuce(id: 2, nome: 'Sensore 2'),
    // ])),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    mqttClientWrapper = MQTTClientWrapper();
    // if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
    //   _connect();
    // }
    // mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  MQTTClientWrapper? mqttClientWrapper;

  void _connect() {
    mqttClientWrapper!.connectMqttClient();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gestione Domotica',
        scrollBehavior: AppScrollBehavior(),
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
    //connectionState() ? HomePage() : null
  }

  bool connectionState() {
    if (mqttClientWrapper == null ||
        mqttClientWrapper!.connectionState !=
            MqttCurrentConnectionState.CONNECTED) {
      return false;
    } else {
      return true;
    }
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
