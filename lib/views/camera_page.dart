import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/logger.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/repositories/video_socket_stream.dart';
import 'package:gestione_domotica/widget/schema_sensori.dart';
import 'package:provider/provider.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione di riepilogo degli schemi dei sensori
class CameraPage extends StatefulWidget {
  CameraPage({Key? key, this.id = -1}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  int id;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<SensoreCamera> sensoriCamera = [];

  VideoSocketStream? videoSocketStream;
  SensoreCamera? sensoreCamera;

  final log = logger(_CameraPageState);

  @override
  void initState() {
    videoSocketStream = VideoSocketStream();
    videoSocketStream!.addListener(connected, ['connected']);
    videoSocketStream!.addListener(disconnected, ['disconnected']);
    super.initState();
  }
  // varible for visualization control
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<SchemaSensoriModel>(builder: (BuildContext context,
        SchemaSensoriModel schemaSensori, Widget? child) {
      sensoriCamera =
          schemaSensori.getModel('SensoreCamera').cast<SensoreCamera>();
      int i = 0;
      if (sensoriCamera.isNotEmpty) {
        if (widget.id == -1) {
          widget.id = sensoriCamera[0].id;
        } else {
          i = sensoriCamera.indexWhere((element) => element.id == widget.id);
        }
        sensoreCamera = sensoriCamera[i];
        log.d('SensoreCamera: $sensoreCamera');
        log.v('Token: ${sensoreCamera?.token}');
        if (sensoreCamera?.token != null) {
          videoSocketStream!.token = sensoreCamera?.token!;
        } else {
          log.d('Richiedo il Token.');
          richiediToken();
        }
        if (sensoreCamera?.token != null &&
            videoSocketStream!.token != null &&
            (videoSocketStream!.connectionState ==
                    SocketCurrentConnectionState.DISCONNECTED ||
                videoSocketStream!.connectionState ==
                    SocketCurrentConnectionState.IDLE)) {
          videoSocketStream!.connect();
        }
        return Row(children: [
          selectCamera(),
          (videoSocketStream != null &&
                  videoSocketStream!.connectionState ==
                      SocketCurrentConnectionState.CONNECTED)
              ? Container(
                  child: StreamBuilder(
                    stream: videoSocketStream!.getResponse,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      return Image.memory(
                        Uint8List.fromList(
                          base64Decode(
                            (snapshot.data.toString()),
                          ),
                        ),
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                      );
                      // return Container(
                      //   child: snapshot.data ??  ,
                      // );
                    },
                  ),
                )
              : const CircularProgressIndicator()
        ]);
      } else {
        return const Text('Nessuna Camera');
      }
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  // Future<void> _refresh() async {
  //   print("REFRESH");
  // }

  Widget selectCamera() {
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        width: 200,
        child: sensoriCamera.isNotEmpty
            ? DropdownButton(
                hint: const Text('Scegli uno'),
                value: widget.id,
                items: sensoriCamera.map((SensoreCamera element) {
                  return DropdownMenuItem(
                      value: element.id, child: Text(element.nome));
                }).toList(),
                onChanged: (int? selectedId) {
                  if (widget.id != selectedId) {
                    sensoreCamera?.cambiaValore(-20);
                    videoSocketStream!.token = null;
                    setState(() {
                      widget.id = selectedId ?? 0;
                    });
                  }

                  // if (videoSocketStream!.connected) {

                  //   videoSocketStream!.disconnect();
                  //   //   int i =
                  //   //       sensoriCamera.indexWhere((element) => element.id == id);
                  //   //   videoStream = VideoStream(sensoreCamera: sensoriCamera[i]);
                  // }
                  //   activateStream(selectedId);
                },
              )
            : const Text('Nessuna Camera'));
  }

  void connected() {
    setState(() {});
  }

  void disconnected() {
    setState(() {});
  }

  void richiediToken() {
    // il valore -10 corrisponde alla richiesta di un token
    sensoreCamera?.cambiaValore(-10);
  }
}
