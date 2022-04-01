import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/stati/stato.dart';
import 'package:gestione_domotica/models/timer/timers.dart';
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
        builder: (BuildContext context, Stato stato, Widget? child) {
      int num_timers = stato.timers?.timers.length ?? 0;
      return Stack(children: [
        Center(
          child: visalizzaAllarme(stato),
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
              (num_timers > 0)
                  ? Switch(
                      value: stato.timers?.isActivated ?? false,
                      activeColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          stato.timers!.isActivated = value;
                        });
                      })
                  : const SizedBox.shrink(),
              (num_timers > 0 && stato.timers!.isActivated)
                  ? Switch(
                      value: stato.timers?.timers![0].isActivated ?? false,
                      inactiveThumbColor: Colors.red[50],
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          stato.timers?.timers[0].isActivated = value;
                        });
                      })
                  : const SizedBox.shrink(),
              (num_timers > 1 && stato.timers!.isActivated)
                  ? Switch(
                      value: stato.timers?.timers[1].isActivated ?? false,
                      inactiveThumbColor: Colors.yellow[50],
                      activeColor: Colors.yellow,
                      onChanged: (value) {
                        setState(() {
                          stato.timers?.timers[1].isActivated = value;
                        });
                      })
                  : const SizedBox.shrink()
            ])))
      ]);
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  Widget visalizzaAllarme(Stato stato) {
    return (stato.timers != null && stato.timers!.isActivated)
        ? TimeSlider(
            timers: stato.timers!,
            child: SizedBox.fromSize(
              size: const Size(150, 150),
              child: ClipOval(
                child: Material(
                  color: Colors.amber[50],
                  child: InkWell(
                    splashColor: Colors.green[50],
                    onTap: () {
                      stato.cambiaStatoAllarme();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(stato.icona,
                            color: stato.colore, size: 150.0) // <-- Icon
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
              icon: Icon(stato.icona, color: stato.colore, size: 200.0),
              onPressed: () {
                stato.cambiaStatoAllarme();
              },
            ),
          );
  }
}
