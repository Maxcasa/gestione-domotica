import 'repository.dart';
import 'package:gestione_domotica/models/model_data.dart';

/// Classe per il salvataggio delle informazioni in memoria
class InMemoryCache implements Repository {
  InMemoryCache({Map<int, ModelData>? storage})
      : this.storage = storage ?? <int, ModelData>{};

  // variabili
  Map<int, ModelData> storage;
  String _nome = 'InMemoryCache';

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
    ModelData localModel = storage[id] ?? ModelData(id: id, data: {'id': id});
    print('Get ' + localModel.toString());
    //await Future.delayed(const Duration(seconds: 3));
    return localModel;
  }

  @override
  Future<List<ModelData>> getAll() async {
    return storage.values.toList(growable: false);
  }

  @override
  Future<ModelData> update(ModelData item) async {
    // Creation of a new element
    if (item.id == 0) {
      final ids = storage.keys.toList()..sort();
      final id = (ids.isEmpty) ? 1 : ids.last + 1;
      item.data['id'] = id;
      ModelData newModel = ModelData(id: id, data: item.data);
      item = newModel;
    }
    storage[item.id] = item;
    ModelData localModel = storage[item.id] ?? ModelData(id: -1);
    print('Update ' + localModel.toString());
    //await Future.delayed(const Duration(seconds: 3));
    return localModel;
  }

  @override
  Future<int> delete(ModelData item) async {
    storage.remove(item.id);
    return 0;
  }

  @override
  Future<void> clear() async {
    storage.clear();
  }
}
