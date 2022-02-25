import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/stati/stato.dart';
import 'package:gestione_domotica/repositories/multi_message_provider.dart';
import 'package:provider/provider.dart';
import 'main_drawer.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione degli allarmi
class AllarmPage extends StatelessWidget {
  AllarmPage({Key? key}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  // varible for visualization control
  // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<Stato>(
        builder: (BuildContext context, Stato allarme, Widget? child) {
      return visalizzaAllarme(allarme);
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  Widget visalizzaAllarme(Stato allarme) {
    return SizedBox(
      height: 200.0,
      width: 200.0,
      child: Column(children: [
        IconButton(
          icon:
              Icon(Icons.add_circle_rounded, color: Colors.black, size: 200.0),
          onPressed: () {
            allarme.cambiaStatoAllarme();
          },
        ),
        // IconButton(
        //   icon: Icon(allarme.icona, color: allarme.colore, size: 50.0),
        //   onPressed: () {
        //     allarme.getStatus();
        //   },
        // )
      ]),
    );
  }
}
