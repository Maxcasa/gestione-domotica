export 'schema_sensori_model.dart';
export 'sensore_model.dart' hide factories;
export 'sensore_infisso.dart';
export 'sensore_luce.dart';
export 'sensore_TeH.dart';
export 'sensore_sirena.dart';
export 'sensore_presenza.dart';
export 'sensore_camera.dart';

enum AzioneSensore {
  rimuovi,
  disabilita,
  abilita,
  imposta,
}
