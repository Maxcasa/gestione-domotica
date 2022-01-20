import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'sensore.dart';

class SchemaSensori extends StatelessWidget {
  // costruttori
  SchemaSensori({Key? key, required this.schemaSensoriModel}) : super(key: key);

  // variabili
  SchemaSensoriModel schemaSensoriModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            child: Container(
                child: schemaSensoriModel.sensoriBack ??
                    const Image(
                      image: AssetImage('images/sfondo_vuoto.png'),
                      height: 150,
                      width: 150,
                    ))),
        for (var item in schemaSensoriModel.sensori)
          Positioned(
            top: item.posTop,
            left: item.posLeft, //give the values according to your requirement
            child: Sensore(sensore: item),
          ),
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
    );
  }
}
