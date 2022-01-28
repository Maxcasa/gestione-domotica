import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/widget/domo_button.dart';

// /// Widget di visualizzazione del Sensore
class Sensore extends StatelessWidget {
  // costruttori
  Sensore({Key? key, required this.sensore}) : super(key: key);

  // variabili
  SensoreModel sensore;
  BuildContext? _context;
  OverlayEntry? menuOverlay;

  @override
  Widget build(BuildContext context) {
    _context = context;
    //_planProviderState.id = idPlan;
    return SizedBox(
        // height: sensore.size.toDouble(),
        // width: sensore.size.toDouble(),
        child: ElevatedButton.icon(
      icon: Icon(sensore.icona,
          color: sensore.colore, size: sensore.size.toDouble()),
      label: Text(sensore.nome),
      onPressed: () {
        sensore.cambiaStato(1);
      },
      // onLongPress: () {
      //   showMenuOverlay();
      // },
    ));
    //floatingActionButton: _buildAddTaskButton(),
  }

  void showMenuOverlay() {
    menuOverlay = OverlayEntry(
        builder: (_context) => Positioned(
              left: sensore.posTop + 5,
              top: sensore.posLeft + 5,
              child: Container(
                  alignment: Alignment.topCenter,
                  padding: new EdgeInsets.only(
                      top: _context.size!.height * .58,
                      right: 20.0,
                      left: 20.0),
                  child: Row(children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        if (sensore.abilitato) {
                          sensore.disabilita();
                        } else {
                          sensore.abilita();
                        }
                      },
                    ),
                  ])),
            ));
    final overlay = Overlay.of(_context!)!;
    overlay.insert(menuOverlay!);
  }
}
