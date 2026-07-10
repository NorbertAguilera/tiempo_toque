import 'package:flutter/material.dart';
import '../models/competidor.dart';
import '../services/competidor_service.dart';

class CompetidorProvider with ChangeNotifier {
  final CompetidorService _service = CompetidorService();

  List<Competidor> _competidores = [];
  Competidor? _competidorActivo;

  List<Competidor> get competidores => _competidores;
  Competidor? get competidorActivo => _competidorActivo;

  // Carga los competidores desde el servicio de Hive
  void cargarCompetidores() {
    _competidores = _service.obtenerCompetidores();
    notifyListeners();
  }

  void agregarCompetidor(Competidor c) async {
    if (_service.existeDorsal(c.dorsal)) {
      throw Exception('El dorsal ${c.dorsal} ya existe.');
    }
    await _service.crearCompetidor(c);
    cargarCompetidores();
  }

  void editarCompetidor(Competidor c) async {
    await _service.actualizarCompetidor(c);
    cargarCompetidores();
  }

  void eliminarCompetidor(int dorsal) async {
    await _service.eliminarCompetidor(dorsal);
    if (_competidorActivo?.dorsal == dorsal) {
      _competidorActivo = null;
    }
    cargarCompetidores();
  }

  void seleccionarCompetidorActivo(Competidor c) {
    _competidorActivo = c;
    notifyListeners();
  }
}
