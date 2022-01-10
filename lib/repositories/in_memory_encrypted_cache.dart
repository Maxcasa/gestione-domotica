import 'dart:convert';

import 'repository.dart';
import 'package:gestione_domotica/models/model_data.dart';
import 'encrypt_data.dart';

/// Classe per il salvataggio delle informazioni in memoria CRIPTATA
class InMemoryEncryptedCache implements Repository {
  final _storage = Map<int, String>();

  String _nome = 'InMemoryEncryptedCache';

  // @override
  // Future<ModelData> create() async {
  //   final ids = _storage.keys.toList()..sort();
  //   final id = (ids.length == 0) ? 1 : ids.last + 1;
  //   final model = ModelData(id: id, data: {'id': id});
  //   _storage[id] = model;
  //   return model;
  // }
  @override
  String get nome => _nome;

  @override
  set nome(String nome) => _nome = nome;

  @override
  Future<ModelData> get(int id) async {
    if (_storage[id] != null) {
      ModelData localModel =
          ModelData(id: id, data: json.decode(decryptMyData(_storage[id])!));
      print('Get ' + localModel.toString());
      //await Future.delayed(const Duration(seconds: 3));
      return localModel;
    } else {
      return ModelData(id: -1, data: {'id': -1});
    }
  }

  @override
  Future<List<ModelData>> getAll() async {
    return [];
    //return _storage.values.toList(growable: false);
  }

  @override
  Future<ModelData> update(ModelData item) async {
    ModelData localModel = ModelData(id: -1);
    // Creation of a new element
    if (item.id == 0) {
      final ids = _storage.keys.toList()..sort();
      final id = (ids.length == 0) ? 1 : ids.last + 1;
      item.data['id'] = id;
      ModelData newModel = ModelData(id: id, data: item.data);
      item = newModel;
    }
    try {
      _storage[item.id] = encryptMyData(json.encode(item.data));
      localModel = ModelData(
          id: item.id,
          data: json.decode(decryptMyData(_storage[item.id]) ?? '{}'));
    } catch (e, stackTrace) {
      print(e.toString());
    } finally {
      print('Update ' + localModel.toString());
    }
    // print('Encripted' + encryptMyData(localModel.toString()));
    //await Future.delayed(const Duration(seconds: 3));
    return localModel;
  }

  @override
  Future<int> delete(ModelData item) async {
    _storage.remove(item.id);
    return 0;
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}
