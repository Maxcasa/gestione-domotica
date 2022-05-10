import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/connection_data.dart';
import 'package:gestione_domotica/models/configurazioni/remote_layer.dart';
import 'package:gestione_domotica/repositories/keep_alive_provider.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
//import 'package:gestione_domotica/repositories/mqtt_client_wrapper.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/allowed_button.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';
import 'package:gestione_domotica/widget/icons_indicator.dart';
import 'package:gestione_domotica/widget/remote_device_manager.dart';
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
  PageController _controller = PageController(
    initialPage: 0,
  );

  int _counter = 0;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  final _formAllowedKey = GlobalKey<FormState>();

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
              title: Text('Gestione Domotica'),
            ),
            endDrawer: const MainDrawer(),
            body: Column(children: <Widget>[
              selectConnection(),
              Row(children: [
                Icon(Icons.expand_circle_down_outlined,
                    color: Colors.black54, size: 30.0),
                Switch(
                  value: _vediDettagli,
                  onChanged: (value) {
                    setState(() {
                      _vediDettagli = value;
                    });
                  },
                ),
              ]),
              (_vediDettagli) ? remoteConnection() : const SizedBox.shrink(),
              Divider(color: Colors.black),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: AllowedButton(),
              ),
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

  Widget selectConnection() {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      return Row(children: [
        Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(5),
            width: 200,
            child: DropdownButton(
              hint: Text('Scegli uno'),
              value: remoteConnection.activeIndex,
              items: remoteConnection.connectionDataList
                  .map((ConnectionData element) {
                return DropdownMenuItem(
                    value: element.id, child: Text(element.connectionName));
              }).toList(),
              onChanged: (int? selectedId) {
                remoteConnection.activeIndex = selectedId ?? 0;
                remoteConnection.saveConnectionConf();
                // remoteConnection.activeIndex = Convert.ToInt32(selectedIndex)!;
                // if (selectedName.isEmpty) {
                //       return "can't empty";
                //     } else {
                //       return null;
                //     }
              },
            )),
        IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, size: 30.0),
            onPressed: () {
              _menuOverlay = _MenuOverlay(remoteConnection);
              Overlay.of(context)?.insert(_menuOverlay!);
              //remoteConnection.addItem();
            }),
        IconButton(
            icon: Icon(Icons.remove_circle_outline_rounded, size: 30.0),
            onPressed: () {
              remoteConnection.removeItem();
            }),
      ]);
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
                    remoteConnection.localServerName = value;
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

  OverlayEntry _MenuOverlay(RemoteConnection remoteConnection) {
    RenderBox renderBox = _context!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    final serverCodeController = TextEditingController();
    return OverlayEntry(
        builder: (_context) => Positioned(
              left: offset.dx + 5,
              top: offset.dy + size.height + 50,
              child: Material(
                  elevation: 4,
                  child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(
                          //top: size.height * .58,
                          right: 20.0,
                          left: 20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: serverCodeController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Server Name',
                            ),
                            // The validator receives the text that the user has entered.
                          ),
                          Row(children: [
                            IconButton(
                                icon: Icon(Icons.add_circle_outline_rounded,
                                    size: 30.0),
                                onPressed: () async {
                                  if (await remoteConnection.addConnection(
                                      serverCodeController.text)) {
                                    mostraSnackBar('Aggiornato', context);
                                    serverCodeController.dispose();
                                    _menuOverlay!.remove();
                                  } else {
                                    mostraSnackBar(
                                        'Problema nella CONNESSIONE', context);
                                  }

                                  //remoteConnection.addItem();
                                }),
                            IconButton(
                                icon:
                                    Icon(Icons.backspace_outlined, size: 30.0),
                                onPressed: () {
                                  serverCodeController.dispose();
                                  _menuOverlay!.remove();
                                }),
                          ])
                        ],
                      ))),
            ));
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
