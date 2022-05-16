import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/widget/domo_button.dart';

/// Classe WIDGET che contiene la gestione singolo sensore
class Sensore extends StatelessWidget {
  // costruttori
  Sensore({Key? key, required this.sensore}) : super(key: key);

  // variabili
  SensoreModel sensore;
  BuildContext? _context;
  OverlayEntry? _menuOverlay;
  bool overlayVisible = false;

  @override
  Widget build(BuildContext context) {
    _context = context;
    //_planProviderState.id = idPlan;
    return Positioned(
        top: sensore.posTop,
        left: sensore.posLeft,
        child: SizedBox(
            // height: sensore.size.toDouble(),
            // width: sensore.size.toDouble(),
            child: ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Colors.grey[50]!.withOpacity(0.2)),
          ),
          icon: Icon(sensore.icona,
              color: sensore.colore, size: sensore.visualSize.toDouble()),
          label: Text(sensore.text),
          onPressed: () {
            sensore.cambiaStato(1);
          },
          onLongPress: () {
            _menuOverlay = _MenuOverlay();
            Overlay.of(context)?.insert(_menuOverlay!);
            overlayVisible = true;
          },
        )));
    //floatingActionButton: _buildAddTaskButton(),
  }

  OverlayEntry _MenuOverlay() {
    RenderBox renderBox = _context!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
        builder: (_context) => Positioned(
            left: offset.dx + 5,
            top: offset.dy + size.height + 5,
            child: Material(
              elevation: 4,
              child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(
                      //top: size.height * .58,
                      right: 20.0,
                      left: 20.0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        if (sensore.abilitato) {
                          sensore.disabilita();
                        } else {
                          sensore.abilita();
                        }
                      },
                    ),
                    if (sensore is SensoreSirena)
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.highlight_rounded),
                          onPressed: () {
                            if (sensore.abilitato) {
                              sensore.cambiaStato(-1);
                            } else {
                              sensore.cambiaStato(-1);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.handyman_rounded),
                          onPressed: () {
                            if (sensore.abilitato) {
                              sensore.cambiaStato(-2);
                            } else {
                              sensore.cambiaStato(-2);
                            }
                          },
                        ),
                      ])
                  ])),
            )));
  }

  void removeOverlay() {
    if (_menuOverlay != null && overlayVisible) {
      _menuOverlay!.remove();
    }
  }
}
