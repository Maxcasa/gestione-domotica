import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/allarme/allarme.dart';
import 'package:provider/provider.dart';
import 'main_drawer.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione degli allarmi
class AllarmPage extends StatelessWidget {
  AllarmPage({Key? key}) : super(key: key);

  // varible for visualization control
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<Allarme>(
        builder: (BuildContext context, Allarme allarme, Widget? child) {
      return visalizzaAllarme(allarme);
      // SizedBox(
      //     height: 200.0,
      //     width: 200.0,
      //     child: IconButton(
      //       icon: Icon(allarme.icona, color: allarme.colore, size: 200.0),
      //       onPressed: () {
      //         allarme.cambiaStatoAllarme();
      //       },
      //     ));
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  Widget visalizzaAllarme(Allarme allarme) {
    return SizedBox(
        height: 200.0,
        width: 200.0,
        child: IconButton(
          icon: Icon(allarme.icona, color: allarme.colore, size: 200.0),
          onPressed: () {
            allarme.cambiaStatoAllarme();
          },
        ));
  }
}
