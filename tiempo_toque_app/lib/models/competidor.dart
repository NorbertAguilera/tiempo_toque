import 'package:hive/hive.dart';

part 'competidor.g.dart';

@HiveType(typeId: 0)
class Competidor extends HiveObject {
  @HiveField(0)
  int dorsal;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String? categoria;

  @HiveField(3)
  double? tiempoBase;

  @HiveField(4)
  int toques;

  @HiveField(5)
  int postes;

  Competidor({
    required this.dorsal,
    required this.nombre,
    this.categoria,
    this.tiempoBase,
    this.toques = 0,
    this.postes = 0,
  });
}
