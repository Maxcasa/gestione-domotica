//import 'dart:html';

import 'package:gestione_domotica/models/model_data.dart';

/// Classe astratta per il salvataggio delle informazioni
abstract class Repository {
  // Future<ModelData> create();
  String get nome;
  set nome(String nome);
  Future<List<ModelData>> getAll();
  Future<ModelData> get(int id);
  Future<ModelData> update(ModelData item);
  Future<int> delete(ModelData item);
  Future<void> clear();
}
