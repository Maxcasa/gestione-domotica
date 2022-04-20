import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:provider/provider.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'sensore.dart';

class SchemaSensori extends StatelessWidget {
  // costruttori
  SchemaSensori({Key? key, required this.schemaSensoriModel}) : super(key: key);

  // variabili
  SchemaSensoriModel schemaSensoriModel;
  List<Sensore> sensoreList = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<RemoteConnection>(builder: (BuildContext context,
        RemoteConnection remoteConnection, Widget? child) {
      sensoreList = [];
      for (var item in schemaSensoriModel.sensori) {
        if (remoteConnection.sensoriVisibili || item.sensoreVisibile) {
          sensoreList.add(Sensore(sensore: item));
        }
      }
      reorderListaSensori();
      return GestureDetector(
          onTap: () {
            // When the icon is pressed the OverlayEntry
            // is removed from Overlay
            for (var item in sensoreList) {
              if (item.overlayVisible) {
                item.removeOverlay();
              }
            }
          },
          // Icon(Icons.close,
          //     color: Colors.green,
          //     size: MediaQuery.of(context).size.height * 0.025),
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                      child: schemaSensoriModel.sensoriBack ??
                          const Image(
                            image: AssetImage('assets/images/sfondo_vuoto.png'),
                            height: 150,
                            width: 150,
                          ))),
              for (var item in sensoreList) item,

              // Column(children: <Widget>[
              //   Expanded(
              //     child: ListView.builder(
              //       itemCount: schemaSensoriModel.sensori.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         if (schemaSensoriModel.sensori.isEmpty) {
              //           return const Text('nessun sensore connesso');
              //         }
              //         final item =
              //             Sensore(sensore: schemaSensoriModel.sensori[index]);
              //         return item;
              //       },
              //     ),
              //   ),
              // ])
            ],
          ));
    });
  }

  void reorderListaSensori() {
    if (sensoreList.isNotEmpty) {
      // ignore: unnecessary_null_comparison
      return sensoreList.sort((a, b) => a == null
          ? 1
          : b == null
              ? -1
              : a.sensore.zIndex.compareTo(b.sensore.zIndex));
    }
  }
}
