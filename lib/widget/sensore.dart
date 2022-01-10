import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';

// /// Widget di visualizzazione del Sensore
class Sensore extends StatelessWidget {
  // costruttori
  Sensore({Key? key, required this.sensore}) : super(key: key);

  // variabili
  SensoreModel sensore;

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return SizedBox(
        height: sensore.size.toDouble(),
        width: sensore.size.toDouble(),
        child: IconButton(
          icon: Icon(sensore.icona,
              color: sensore.colore, size: sensore.size.toDouble()),
          onPressed: () {
            sensore.cambiaStato(1);
          },
        ));
    //floatingActionButton: _buildAddTaskButton(),
  }
}
