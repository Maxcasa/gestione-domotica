import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/views/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/allarme/allarme.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import '../repositories/mqtt_client_wrapper.dart';
import 'models/drawer/main_drawer_provider.dart';

void main() {
  //SchemaSensori(id: 0);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<Allarme>(
      create: (_) => Allarme(id: 0),
    ),
    ChangeNotifierProvider<MainDrawerProvider>(
      create: (_) => MainDrawerProvider('assets/json/drawer_list.json'),
    ),
    ChangeNotifierProvider<SchemaSensoriModel>(
        //   create: (_) => SchemaSensori(id: 0),
        create: (context) => SchemaSensoriModel(id: 0)),
    // nome: 'test sensori',
    // sensori: [
    //   SensoreInfisso(id: 1, nome: 'Sensore 1'),
    //   SensoreLuce(id: 2, nome: 'Sensore 2'),
    // ])),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter Demo Home Page'),
          ),
          body: MyHomePage(),
        )

        //     Consumer<MainDrawerProvider>(builder: (BuildContext context,
        //   MainDrawerProvider mainDrawerProvider, Widget? child) {
        // return
        // Scaffold(
        //     appBar: AppBar(
        //       title: Text(mainDrawerProvider.pageName),
        //     ),
        //     drawer: const MainDrawer(),
        //     body: MyHomePage(title: 'Flutter Demo Home Page'),);
        // })

        );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key) {
    mqttClientWrapper = MQTTClientWrapper();
    if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
      _connect();
    }
    // mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  MQTTClientWrapper? mqttClientWrapper;

  void _connect() {
    mqttClientWrapper!.connectMqttClient();
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // : super(key: key);
  PageController _controller = PageController(
    initialPage: 0,
  );

  int _counter = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        SensorPage(),
        AllarmPage(),
      ],
    );

    // Scaffold(
    //     appBar: AppBar(
    //       title: Text('Test sensori'),
    //     ),
    //     body: Column(children: [
    // CONSUMER SENSORI
    // --------------------
    // Consumer<SchemaSensori>(builder: (BuildContext context,
    //     SchemaSensori schemaSensori, Widget? child) {
    //   return Column(children: <Widget>[
    //     Expanded(
    //       child: ListView.builder(
    //         itemCount: schemaSensori.sensori.length,
    //         itemBuilder: (BuildContext context, int index) {
    //           if (schemaSensori.sensori.isEmpty) {
    //             return Text('nessun sensore connesso');
    //           }
    //           final item = schemaSensori.sensori[index];
    //           return ListTile(
    //             leading: Icon(
    //               item.icona,
    //               color: item.colore,
    //             ),
    //             title: Text(item.nome),
    //             subtitle: Text('Valore: ${item.valore.toString()}'),
    //             onTap: () {
    //               if (schemaSensori.sensori[index].tipo != 0) {
    //                 schemaSensori.cambiaStatoSensore(index);
    //               }
    //             },
    //           );
    //         },
    //       ),
    //     ),
    //   ]);
    // }),
    //   Consumer<Allarme>(
    //       builder: (BuildContext context, Allarme allarme, Widget? child) {
    //     return SizedBox(
    //         height: 200.0,
    //         width: 200.0,
    //         child: IconButton(
    //           icon: Icon(allarme.icona, color: allarme.colore, size: 200.0),
    //           onPressed: () {
    //             allarme.cambiaStatoAllarme();
    //           },
    //         ));
    //   })
    // ]));

    // SchemaSensoriProvider(
    //   schemaSensori: ,
    //   child: MaterialApp(
    //     title: 'Project Domotica',
    //     theme: ThemeData(
    //       // This is the theme of your application.
    //       //
    //       // Try running your application with "flutter run". You'll see the
    //       // application has a blue toolbar. Then, without quitting the app, try
    //       // changing the primarySwatch below to Colors.green and then invoke
    //       // "hot reload" (press "r" in the console where you ran "flutter run",
    //       // or simply save your changes to "hot reload" in a Flutter IDE).
    //       // Notice that the counter didn't reset back to zero; the application
    //       // is not restarted.
    //       primarySwatch: Colors.blue,
    //     ),
    //     home: AllarmPage(),
    //   ),
    // );
  }
}
