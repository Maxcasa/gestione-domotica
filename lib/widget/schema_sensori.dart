import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:provider/provider.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'sensore.dart';

/// Classe WIDGET che contiene la gestione di riepilogo del singolo
/// schema dei sensori
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
      /// Lista dei sensori da visualizzare
      sensoreList = [];
      if (schemaSensoriModel.sensori != null) {
        for (var item in schemaSensoriModel.sensori!) {
          if (remoteConnection.sensoriVisibili || item.sensoreVisibile) {
            sensoreList.add(Sensore(sensore: item));
          }
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

                      /// Immagine di sfondo
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
              Positioned(
                  bottom: 90.0,
                  left: 20.0,
                  child: Row(children: [
                    Icon(Icons.home_rounded, color: Colors.black54, size: 30.0),

                    /// Switch per mostrare solo i Visibili o tutti.
                    Switch(
                      value: remoteConnection.sensoriVisibili,
                      onChanged: (value) {
                        remoteConnection.sensoriVisibili = value;
                      },
                    ),
                  ])),
            ],
          ));
    });
  }

  void reorderListaSensori() {
    if (sensoreList.isNotEmpty) {
      // ignore: unnecessary_null_comparison
      return sensoreList.sort((a, b) =>
          a == null ? 1 : a.sensore.zIndex.compareTo(b.sensore.zIndex));
    }
  }
}



            // FormField(
            //     initialValue: remoteConnection.sensoriVisibili,
            //     onSaved: (value) {
            //       remoteConnection.sensoriVisibili = value as bool;
            //     },
            //     builder: (FormFieldState<bool> field) {
            //       return SwitchListTile(
                //     title: Text("Visualizza i sensori non attivi"),
                //     value: field.value ?? false,
                //     onChanged: (val) {
                //       field.didChange(val);
                //     },
                //   );
                // }),
