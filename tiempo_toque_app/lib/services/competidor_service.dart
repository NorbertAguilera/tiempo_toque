import 'package:hive/hive.dart';
import '../models/competidor.dart';

class CompetidorService {
  static const String _boxName = 'competidores';

  // Obtiene la box de competidores.
  // Hive.openBox es asíncrono, pero usualmente se abre en el main.
  // Aquí asumimos que ya está abierta o usamos Hive.box() para acceso síncrono.
  Box<Competidor> get _box => Hive.box<Competidor>(_boxName);

  List<Competidor> obtenerCompetidores() {
    return _box.values.toList();
  }

  Future<void> crearCompetidor(Competidor c) async {
    // Usamos el dorsal como llave para asegurar unicidad y facilitar la búsqueda/borrado.
    await _box.put(c.dorsal, c);
  }

  Future<void> actualizarCompetidor(Competidor c) async {
    await _box.put(c.dorsal, c);
  }

  Future<void> eliminarCompetidor(int dorsal) async {
    await _box.delete(dorsal);
  }

  bool existeDorsal(int dorsal) {
    return _box.containsKey(dorsal);
  }

  Future<void> guardarTiempoBase(int dorsal, double tiempoEnSegundos) async {
    final competidor = _box.get(dorsal);
    if (competidor != null) {
      competidor.tiempoBase = tiempoEnSegundos;
      await competidor.save();
    }
  }

  Future<void> actualizarPenalizaciones(int dorsal, int toques, int postes) async {
    final competidor = _box.get(dorsal);
    if (competidor != null) {
      competidor.toques = toques;
      competidor.postes = postes;
      await competidor.save();
    }
  }
}
