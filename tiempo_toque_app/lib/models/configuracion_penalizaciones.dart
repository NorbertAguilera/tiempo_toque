import 'package:hive/hive.dart';

part 'configuracion_penalizaciones.g.dart';

@HiveType(typeId: 1)
class ConfiguracionPenalizaciones extends HiveObject {
  @HiveField(0)
  double valorToque;

  @HiveField(1)
  double valorPoste;

  ConfiguracionPenalizaciones({
    this.valorToque = 2.0,
    this.valorPoste = 50.0,
  });
}
