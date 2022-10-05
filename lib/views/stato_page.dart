import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/attivazioni/attivazione_model.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/stati/stati_layer.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/widget/time_slider.dart';
import 'package:provider/provider.dart';
import 'main_drawer.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione degli stati, con tipoStato decido
/// che tipo di stato voglio visualizzare
class StatoPage extends StatefulWidget {
  StatoPage({Key? key, String? tipoStato})
      : tipoStato = tipoStato ?? "Stato",
        super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  String tipoStato;

  @override
  _StatoPageState createState() => _StatoPageState();
}

class _StatoPageState extends State<StatoPage> {
  // varible for visualization control
  // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];
  RangeValues _values = RangeValues(0.3, 0.7);

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<SchemaStatiModel>(
        builder: (BuildContext context, SchemaStatiModel stati, Widget? child) {
      List<StatoModel> statiLista = stati.getModel(widget.tipoStato);
      if (statiLista.length > 0) {
        int indexStato = 0;
        StatoModel stato = statiLista[indexStato];
        int num_timers = stato.timers?.timers.length ?? 0;
        return Stack(children: [
          Positioned(
            top: 20.0,
            left: 20.0,
            child: visualizzaAttiviAllarme(
                stato, context, indexStato, 0, Icons.alarm_rounded),
          ),
          Positioned(
            top: 20.0,
            right: 80.0,
            child: visualizzaAttiviAllarme(
                stato, context, indexStato, 1, Icons.notifications_on_rounded),
          ),
          Center(
            child: visalizzaAllarme(stato),
          ),
          Positioned(
              bottom: 90.0,
              left: 20.0,
              child: Container(
                  // padding: const EdgeInsets.all(20.0),
                  child: Row(children: [
                (num_timers > 0)
                    ? Icon(
                        Icons.access_time_rounded,
                        color: Colors.red,
                      )
                    : const SizedBox.shrink(),
                (num_timers > 0)
                    ? Switch(
                        value: stato.timers?.isActivated ?? false,
                        activeColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            //stato.timers!.isActivated = value;
                            stato.attivaTimer(-1, value);
                          });
                        })
                    : const SizedBox.shrink(),
                (num_timers > 0 && stato.timers!.isActivated)
                    ? Switch(
                        value: stato.timers?.timers[0].isActivated ?? false,
                        inactiveThumbColor: Colors.red[100],
                        activeColor: Colors.red,
                        onChanged: (value) {
                          setState(() {
                            stato.attivaTimer(0, value);
                            //stato.timers?.timers[0].isActivated = value;
                          });
                        })
                    : const SizedBox.shrink(),
                (num_timers > 1 && stato.timers!.isActivated)
                    ? Switch(
                        value: stato.timers?.timers[1].isActivated ?? false,
                        inactiveThumbColor: Colors.yellow[100],
                        activeColor: Colors.yellow,
                        onChanged: (value) {
                          setState(() {
                            stato.attivaTimer(1, value);
                            //stato.timers?.timers[1].isActivated = value;
                          });
                        })
                    : const SizedBox.shrink()
              ])))
        ]);
      } else {
        return Center(
          child: const Image(
            image: AssetImage('assets/images/sfondo_vuoto.png'),
            height: 150,
            width: 150,
          ),
        );
      }
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  Widget visalizzaAllarme(StatoModel stato) {
    return (stato.timers != null && stato.timers!.isActivated)
        ? TimeSlider(
            stato: stato,
            child: SizedBox.fromSize(
              size: const Size(150, 150),
              child: ClipOval(
                child: Material(
                  color: Colors.amber[50],
                  child: InkWell(
                    splashColor: Colors.green[50],
                    onTap: () {
                      stato.cambiaStato(-1, 0);
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
                stato.cambiaStato(-1, 0);
              },
            ),
          );
  }

  Widget visualizzaAttiviAllarme(StatoModel stato, BuildContext context,
      int indexStato, int attivazione, IconData icona) {
    return Consumer<SchemaSensoriModel>(builder: (BuildContext context,
        SchemaSensoriModel schemaSensori, Widget? child) {
      bool isSensoreInfisso = false;
      bool isSensoreInfissoAttivo = false;
      bool isSensorePresenza = false;
      bool isSensorePresenzaAttivo = false;
      for (SensoreModel sensore in schemaSensori.sensori) {
        if (sensore is SensoreInfisso) {
          if (sensore.attivazioni.isNotEmpty) {
            isSensoreInfisso = true;
            for (AttivazioneModel attivazioneModel in sensore.attivazioni) {
              if (attivazioneModel.id == attivazione &&
                  attivazioneModel.valore > 0) {
                isSensoreInfissoAttivo = true;
              }
            }
            // AttivazioneModel sensore.attivazioni.
            // isSensoreInfissoAttivo = false;
          }
        }
        if (sensore is SensorePresenza) {
          if (sensore.attivazioni.isNotEmpty) {
            isSensorePresenza = true;
            for (AttivazioneModel attivazioneModel in sensore.attivazioni) {
              if (attivazioneModel.id == attivazione &&
                  attivazioneModel.valore > 0) {
                isSensorePresenzaAttivo = true;
              }
            }
            // AttivazioneModel sensore.attivazioni.
            // isSensoreInfissoAttivo = false;
          }
        }
      }
      // if (sensore is SensorePresenza) {
      //   isSensorePresenza = true;
      //   if (sensore.attiva & attivazione == 0) {
      //     isSensorePresenzaAttivo = false;
      //   }
      // }
      return
          // RefreshIndicator(
          //     // reload page
          //     onRefresh: () => _refresh(),
          //     child: SingleChildScrollView(
          //         //physics: const AlwaysScrollableScrollPhysics(),
          //         scrollDirection: Axis.vertical,
          //         child:
          Row(children: [
        (isSensoreInfisso || isSensorePresenza)
            ? IconButton(
                icon: Icon(icona, size: 20, color: stato.colore),
                onPressed: () {
                  stato.cambiaStato(-1, attivazione);
                })
            : const SizedBox.shrink(),
        isSensoreInfisso
            ? IconButton(
                icon: Icon(Icons.sensor_window_outlined,
                    size: 20,
                    color:
                        (isSensoreInfissoAttivo) ? Colors.red : Colors.black),
                onPressed: () {
                  schemaSensori.attivaSensori(
                      'SensoreInfisso', attivazione, !isSensoreInfissoAttivo);
                })
            : const SizedBox.shrink(),
        // (isSensoreInfisso && isSensorePresenza)
        //             ? TextButton(
        //               child: Text(stati.stati[indexStato].operatori[0] == 0 ? '&&' : '||'),
        //         onPressed: () {
        //           stati.toggleOperatore(indexStato, attivazione
        //               isSensoreInfissoAttivo ? -attivazione : attivazione);
        //         })
        //     : const SizedBox.shrink(),
        isSensorePresenza
            ? IconButton(
                icon: Icon(Icons.directions_walk_rounded,
                    size: 20,
                    color:
                        (isSensorePresenzaAttivo) ? Colors.red : Colors.black),
                onPressed: () {
                  schemaSensori.attivaSensori(
                      'SensorePresenza', attivazione, !isSensorePresenzaAttivo);
                })
            : const SizedBox.shrink(),
      ]);
    });
  }
}
