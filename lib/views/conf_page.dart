import 'dart:io';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/connection_data.dart';
import 'package:gestione_domotica/models/configurazioni/remote_layer.dart';
import 'package:gestione_domotica/models/hw/hw_model.dart';
import 'package:gestione_domotica/models/hw/schema_hw_model.dart';
import 'package:gestione_domotica/repositories/enrollment_client.dart';
//import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
//import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
//import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/allow_new_connection_button.dart';
import 'package:gestione_domotica/widget/allowed_button.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';
//import 'package:gestione_domotica/widget/icons_indicator.dart';
import 'package:gestione_domotica/widget/remote_device_manager.dart';
import 'package:gestione_domotica/widget/rf_manager_button.dart';
import 'package:provider/provider.dart';

import 'main_drawer.dart';

class ConfPage extends StatefulWidget {
  ConfPage({Key? key}) : super(key: key) {
    mqttClientWrapper = MQTTClientWrapper();
    mqttClientWrapper!.wrapperState = MqttWrapperState.ACTIVE;
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

  void _disconnect() {
    mqttClientWrapper!.disconnect();
  }

  @override
  _ConfPageState createState() => _ConfPageState();
}

class _ConfPageState extends State<ConfPage> with WidgetsBindingObserver {
  final PageController _controller = PageController(
    initialPage: 0,
  );

  // int _counter = 0;

  // static const _kDuration = const Duration(milliseconds: 300);

  // static const _kCurve = Curves.ease;

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  // final _formAllowedKey = GlobalKey<FormState>();

  bool _vediDettagli = false;

  OverlayEntry? _menuOverlay;
  BuildContext? _context;
  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // AppLifecycleState _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.ACTIVE;
        widget._connect();
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.INACTIVE;
        widget._disconnect();
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.INACTIVE;
        widget._disconnect();
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.INACTIVE;
        widget._disconnect();
        break;
    }
  }

  @override
  void initState() {
    // multiMessageProvider.addMessage(
    //     'request/set', "{\"status\": \"sensori\"}", ['sensori/get']);
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    widget.mqttClientWrapper!
        .unsubscribeToGenericTopic(totalTopic: 'configRemote/get');
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _context = context;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AllowedDevices>(
            create: (_) => AllowedDevices(),
          ),
        ],
        child: Scaffold(
            appBar: AppBar(
              leadingWidth: 100,
              leading: ConnectionIcon(),
              title: const Text('Gestione Domotica'),
            ),
            endDrawer: const MainDrawer(),
            body:
                // SingleChildScrollView(
                //     child:
                Column(children: <Widget>[
              selectConnection(),
              enrollmentNotice(),
              IconButton(
                  icon: _vediDettagli
                      ? const Icon(Icons.arrow_circle_up_rounded,
                          color: Colors.black, size: 30.0)
                      : const Icon(Icons.arrow_circle_down_rounded,
                          color: Colors.black, size: 30.0),
                  onPressed: () {
                    setState(() {
                      _vediDettagli = !_vediDettagli;
                    });
                  }),

              // Row(children: [
              //   const Icon(Icons.expand_circle_down_outlined,
              //       color: Colors.black54, size: 30.0),
              //   Switch(
              //     value: _vediDettagli,
              //     onChanged: (value) {
              //       setState(() {
              //         _vediDettagli = value;
              //       });
              //     },
              //   ),
              // ]),
              (_vediDettagli) ? remoteConnection() : const SizedBox.shrink(),
              const Divider(color: Colors.black),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: rfButton(),
              ),
              const Divider(color: Colors.black),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: const AllowNewConnectionButton(),
              ),
              const Divider(color: Colors.black),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: AllowedButton(),
              ),
              const Divider(color: Colors.black),
              allowedDevice(),
              const Divider(color: Colors.black),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: RemoteDeviceManager(),
              )
            ])
            //)
            ));
  }

  Widget selectConnection() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      return Row(children: [
        Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            width: 200,
            child: remoteConnection.connectionDataList.length > 0
                ? DropdownButton(
                    hint: const Text('Scegli uno'),
                    value: remoteConnection.id,
                    items: remoteConnection.connectionDataList
                        .map((ConnectionData element) {
                      return DropdownMenuItem(
                          value: element.id,
                          child: Text(element.connectionName));
                    }).toList(),
                    onChanged: (int? selectedId) {
                      remoteConnection.activeId = selectedId ?? -1;
                      remoteConnection.saveConnectionConf();
                      // remoteConnection.activeIndex = Convert.ToInt32(selectedIndex)!;
                      // if (selectedName.isEmpty) {
                      //       return "can't empty";
                      //     } else {
                      //       return null;
                      //     }
                    },
                  )
                : const Text('Nessuna Connessione')),
        IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 30.0),
            onPressed: () {
              _menuOverlay = _MenuOverlay(remoteConnection);
              Overlay.of(context)?.insert(_menuOverlay!);
              //remoteConnection.addItem();
            }),
        IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 30.0),
            onPressed: () {
              remoteConnection.removeItem();
            }),
      ]);
    });
  }

  Widget enrollmentNotice() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      final active = remoteConnection.activeConnectionData;
      if (active == null || active.hasCredentials) {
        return const SizedBox.shrink();
      }
      return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
              'Registrazione richiesta: aggiungi la connessione con il token '
              'di pairing.',
              style: TextStyle(color: Colors.red)));
    });
  }

  Widget remoteConnection() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      final nameController =
          TextEditingController(text: remoteConnection.localServerName);
      final wiFiController =
          TextEditingController(text: remoteConnection.localWiFiConnectionName);
      final _formfKey = GlobalKey<FormState>();
      return Form(
        key: _formfKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
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
                    remoteConnection.localServerName = value;
                  },
                )),
            Row(
              children: [
                Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(5),
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
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formfKey.currentState!.validate()) {
                    // if (await remoteConnection.checkLocalName(
                    //     nameValue: nameController.text)) {
                    //   if (await remoteConnection.checkLocalWiFi(
                    //       wiFiValue: wiFiController.text)) {
                    try {
                      _formfKey.currentState!.save();
                      remoteConnection.saveConnectionInfo();
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      mostraSnackBar('Aggiornato', context);
                    } on Exception catch (e) {
                      mostraSnackBar('Problema nel salvataggio $e', context);
                      throw Exception(e);
                    }
                    //   } else {
                    //     mostraSnackBar('Problema nel WiFi', context);
                    //   }
                    // } else {
                    //   mostraSnackBar('Problema nel trovare il Server', context);
                    // }
                  } else {
                    mostraSnackBar('Problema nella validazione', context);
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

  Widget rfButton() {
    return Consumer<SchemaHwModel>(
        builder: (BuildContext context, SchemaHwModel hw, Widget? child) {
      List<HwModel> hwLista = hw.getModel("ReceiverHF") ?? [];
      if (hwLista.isNotEmpty) {
        return RfManagerButton();
      } else {
        return SizedBox.shrink();
      }
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
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5),
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
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        List<String?> deviceNameList = [];
                        for (TextEditingController controller in _controllers) {
                          deviceNameList.add(controller.text);
                        }
                        allowedDevices.setNomiDevices(deviceNameList);
                        allowedDevices.saveAllowedDevices();
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

  Widget _enrollmentField(TextEditingController controller, String hint,
      {bool obscure = false, TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      width: 200,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        autocorrect: false,
        enableSuggestions: !obscure,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          hintText: hint,
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  OverlayEntry _MenuOverlay(RemoteConnection remoteConnection) {
    RenderBox renderBox = _context!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    final pairingCodeController = TextEditingController();
    final serverNameController = TextEditingController();
    final serverPortController = TextEditingController(text: '8443');
    final deviceNameController =
        TextEditingController(text: 'App Domotica ${Platform.operatingSystem}');
    return OverlayEntry(
        builder: (_context) => Positioned(
              left: offset.dx + 5,
              top: offset.dy + 50,
              child: Material(
                  elevation: 4,
                  child: Container(
                      alignment: Alignment.topCenter,
                      constraints: const BoxConstraints(maxHeight: 480),
                      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _enrollmentField(
                                pairingCodeController, 'Token di pairing',
                                obscure: true),
                            _enrollmentField(serverNameController,
                                'Server (hostname MagicDNS)'),
                            _enrollmentField(
                                serverPortController, 'Porta HTTPS',
                                keyboardType: TextInputType.number),
                            _enrollmentField(
                                deviceNameController, 'Nome dispositivo'),
                            Row(children: [
                              IconButton(
                                  icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 30.0),
                                  onPressed: () async {
                                    final String? error = await _addConnection(
                                        remoteConnection,
                                        pairingCodeController.text,
                                        serverNameController.text,
                                        serverPortController.text,
                                        deviceNameController.text);
                                    if (error == null) {
                                      mostraSnackBar('Aggiornato', context);
                                      _menuOverlay!.remove();
                                    } else {
                                      mostraSnackBar(error, context);
                                    }
                                  }),
                              IconButton(
                                  icon: const Icon(Icons.backspace_outlined,
                                      size: 30.0),
                                  onPressed: () {
                                    _menuOverlay!.remove();
                                  }),
                            ])
                          ],
                        ),
                      ))),
            ));
  }

  /// Registra il dispositivo via HTTPS (mai HTTP in chiaro); restituisce un
  /// messaggio di errore oppure null se la registrazione e' riuscita.
  Future<String?> _addConnection(
      RemoteConnection remoteConnection,
      String pairingCode,
      String serverName,
      String port,
      String deviceName) async {
    final int? httpsPort = int.tryParse(port.trim());
    if (httpsPort == null) {
      return 'Porta HTTPS non valida';
    }
    try {
      final String deviceId =
          await remoteConnection.credentialsStore.deviceId();
      final ConnectionData connectionData = await EnrollmentClient().enroll(
          serverName: serverName,
          httpsPort: httpsPort,
          pairingCode: pairingCode,
          deviceId: deviceId,
          deviceName: deviceName.trim().isEmpty
              ? 'App Domotica ${Platform.operatingSystem}'
              : deviceName);
      await remoteConnection.addConnection(connectionData);
      return null;
    } on EnrollmentException catch (e) {
      return e.message;
    } on Exception catch (e) {
      print('RemoteConnectionError :: ${e.runtimeType}');
      return 'Problema nella CONNESSIONE';
    }
  }

  // Widget connectionState() {
  //   if (mqttClientWrapper == null ||
  //       mqttClientWrapper!.connectionState !=
  //           MqttCurrentConnectionState.CONNECTED) {
  //     return Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
  //   } else {
  //     return Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
  //   }
  // }
}
