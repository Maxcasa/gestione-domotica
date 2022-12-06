import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/widget/schema_sensori.dart';
import 'package:gestione_domotica/widget/video_stream.dart';
import 'package:provider/provider.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione di riepilogo degli schemi dei sensori
class CameraPage extends StatelessWidget {
  CameraPage({Key? key, this.id = -1}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  int id;

  List<SensoreCamera> sensoriCamera = [];

  VideoStream? videoStream;

  // varible for visualization control
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<SchemaSensoriModel>(builder: (BuildContext context,
        SchemaSensoriModel schemaSensori, Widget? child) {
      List<SensoreCamera> sensoriCamera =
          schemaSensori.getModel('SensoreCamera') as List<SensoreCamera>;
      int i = 0;
      if (sensoriCamera.isNotEmpty) {
        if (id == -1) {
          id = sensoriCamera[0].id;
        } else {
          i = sensoriCamera.indexWhere((element) => element.id == id);
        }
        videoStream ??= VideoStream(sensoreCamera: sensoriCamera[i]);
        return Row(
          children: [
            selectCamera(),
            videoStream ?? const CircularProgressIndicator()
          ],
        );
      } else {
        return const CircularProgressIndicator();
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
        child: sensoriCamera.length > 0
            ? DropdownButton(
                hint: const Text('Scegli uno'),
                value: id,
                items: sensoriCamera.map((SensoreCamera element) {
                  return DropdownMenuItem(
                      value: element.id, child: Text(element.nome));
                }).toList(),
                onChanged: (int? selectedId) {
                  if (videoStream != null) {
                    id = selectedId ?? 0;
                    videoStream!.disconnect();
                    int i =
                        sensoriCamera.indexWhere((element) => element.id == id);
                    videoStream = VideoStream(sensoreCamera: sensoriCamera[i]);
                  }
                  //   activateStream(selectedId);
                },
              )
            : const Text('Nessuna Camera'));
  }
}
