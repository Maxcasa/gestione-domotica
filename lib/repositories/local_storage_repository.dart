import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';

import 'repository.dart';
import 'package:gestione_domotica/models/model_data.dart';

/// Classe per il salvataggio delle informazioni nel local storage
class LocalStorageRepository implements Repository {
  // costruttori
  LocalStorageRepository(String storageName)
      : _storage = LocalStorage(storageName, '.') {
    getIds();
    //print(_localPath);
  }

  // variabili
  List<int> _ids = [];
  final LocalStorage _storage;

  Future<void> getIds() async {
    String? idsString = await _storage.getItem('ids');
    if (idsString != null) {
      _ids = idsString
          .split(' ')
          .map((String string) => int.parse(string))
          .toList();
      _ids.sort();
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path);
    return directory.path;
  }

  @override
  String get nome => (_storage.getItem('nome'));

  @override
  set nome(String nome) => (_storage.setItem('nome', nome));

  @override
  Future<ModelData> get(int id) async {
    ModelData localModel = ModelData.fromString(
        _storage.getItem(id.toString()) ??
            '\'id\': ${id}, \'data\': {\'id\': ${id}}');
    print('Get ' + localModel.toString());
    //await Future.delayed(const Duration(seconds: 3));
    return localModel;
  }

  @override
  Future<List<ModelData>> getAll() async {
    List<ModelData> modelData = [];
    for (final id in _ids) {
      modelData.add((await get(id)));
    }
    return modelData;
  }

  @override
  Future<ModelData> update(ModelData item) async {
    // Creation of a new element
    if (item.id == 0) {
      //final ids = _ids.sort();
      final id = (_ids.length == 0) ? 1 : _ids.last + 1;
      item.data['id'] = id;
      ModelData newModel = ModelData(id: id, data: item.data);
      item = newModel;
    }
    await _storage.setItem(item.id.toString(), item.toString());
    ModelData localModel = await get(item.id);
    print('Update ' + localModel.toString());
    //await Future.delayed(const Duration(seconds: 3));
    return localModel;
  }

  @override
  Future<int> delete(ModelData item) async {
    await _storage.deleteItem(item.id.toString());
    return 0;
  }

  @override
  Future<void> clear() async {
    await _storage.clear();
  }
}
