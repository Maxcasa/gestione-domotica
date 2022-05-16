import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/widget/schema_sensori.dart';
import 'package:provider/provider.dart';
//import '../widget/AzioneForm.dart';

/// Classe WIDGET che contiene la gestione di riepilogo degli schemi dei sensori
class SensorPage extends StatelessWidget {
  SensorPage({Key? key}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider.addMessage(
    //     'request/set', "{\"status\": \"sensori\"}", ['sensori/get']);
  }

  // varible for visualization control
  //final ScrollController scrollController = ScrollController();
  // final List<Map<String, dynamic>> drawerTree = [];

  @override
  Widget build(BuildContext context) {
    //_planProviderState.id = idPlan;
    return Consumer<SchemaSensoriModel>(builder: (BuildContext context,
        SchemaSensoriModel schemaSensori, Widget? child) {
      return
          // RefreshIndicator(
          //     // reload page
          //     onRefresh: () => _refresh(),
          //     child: SingleChildScrollView(
          //         //physics: const AlwaysScrollableScrollPhysics(),
          //         scrollDirection: Axis.vertical,
          //         child:
          SchemaSensori(schemaSensoriModel: schemaSensori);
    });
    //floatingActionButton: _buildAddTaskButton(),
  }

  Future<void> _refresh() async {
    print("REFRESH");
  }
}
