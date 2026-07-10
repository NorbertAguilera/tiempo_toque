import 'package:hive/hive.dart';

part 'competidor.g.dart';

@HiveType(typeId: 0)
class Competidor extends HiveObject {
  @HiveField(0)
  int dorsal;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  double tiempoBase;

  @HiveField(3)
  int toques;

  @HiveField(4)
  int postes;

  Competidor({
    required this.dorsal,
    required this.nombre,
    required this.tiempoBase,
    required this.toques,
    required this.postes,
  });
}
