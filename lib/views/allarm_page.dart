import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/stati/stato.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/widget/time_slider.dart';
import 'package:provider/provider.dart';
import 'main_drawer.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione degli allarmi
class AllarmPage extends StatefulWidget {
  AllarmPage({Key? key}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  @override
  _AllarmPageState createState() => _AllarmPageState();
}

class _AllarmPageState extends State<AllarmPage> {
  // varible for visualization control
  // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];
  RangeValues _values = RangeValues(0.3, 0.7);

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<Stato>(
        builder: (BuildContext context, Stato allarme, Widget? child) {
      return Stack(children: [
        Center(
          child: visalizzaAllarme(allarme),
        ),
        Positioned(
            bottom: 90.0,
            left: 20.0,
            child: Container(
                // padding: const EdgeInsets.all(20.0),
                child: Row(children: [
              Icon(
                Icons.access_time_rounded,
                color: Colors.red,
              ),
              Switch(
                  value: allarme.timers!.isActivated,
                  onChanged: (value) {
                    setState(() {
                      allarme.timers!.isActivated = value;
                    });
                  })
            ])))
      ]);
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  Widget visalizzaAllarme(Stato allarme) {
    return allarme.timers!.isActivated
        ? TimeSlider(
            child: SizedBox.fromSize(
            size: const Size(150, 150),
            child: ClipOval(
              child: Material(
                color: Colors.amber[50],
                child: InkWell(
                  splashColor: Colors.green[50],
                  onTap: () {
                    allarme.cambiaStatoAllarme();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(allarme.icona,
                          color: allarme.colore, size: 150.0) // <-- Icon
                    ],
                  ),
                ),
              ),
            ),
          ))
        : SizedBox(
            height: 200.0,
            width: 200.0,
            child: IconButton(
              icon: Icon(allarme.icona, color: allarme.colore, size: 200.0),
              onPressed: () {
                allarme.cambiaStatoAllarme();
              },
            ),
          );
  }
}
