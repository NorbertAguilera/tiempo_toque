import 'package:flutter/material.dart';
import '../models/competidor.dart';
import '../services/competidor_service.dart';

class CompetidorProvider with ChangeNotifier {
  final CompetidorService _service;

  CompetidorProvider({CompetidorService? service})
      : _service = service ?? CompetidorService();

  List<Competidor> _competidores = [];
  Competidor? _competidorActivo;
  final List<String> _historialPenalizaciones = [];

  List<Competidor> get competidores => _competidores;
  Competidor? get competidorActivo => _competidorActivo;
  List<String> get historialPenalizaciones => _historialPenalizaciones;

  // Carga los competidores desde el servicio de Hive
  Future<void> cargarCompetidores() async {
    _competidores = _service.obtenerCompetidores();
    notifyListeners();
  }

  Future<void> agregarCompetidor(Competidor c) async {
    if (_service.existeDorsal(c.dorsal)) {
      throw Exception('El dorsal ${c.dorsal} ya existe.');
    }
    await _service.crearCompetidor(c);
    await cargarCompetidores();
  }

  Future<void> editarCompetidor(Competidor c) async {
    await _service.actualizarCompetidor(c);
    await cargarCompetidores();
  }

  Future<void> eliminarCompetidor(int dorsal) async {
    await _service.eliminarCompetidor(dorsal);
    if (_competidorActivo?.dorsal == dorsal) {
      _competidorActivo = null;
    }
    await cargarCompetidores();
  }

  Future<void> guardarTiempoBase(int dorsal, double tiempo) async {
    await _service.guardarTiempoBase(dorsal, tiempo);
    await cargarCompetidores();
  }

  void seleccionarCompetidorActivo(Competidor c) {
    _competidorActivo = c;
    _historialPenalizaciones.clear(); // Reset historial al cambiar competidor
    notifyListeners();
  }

  // --- Lógica de Penalizaciones ---

  Future<void> agregarToque() async {
    final c = _competidorActivo;
    if (c == null) return;

    c.toques++;
    _historialPenalizaciones.add('toque');
    await _service.actualizarPenalizaciones(c.dorsal, c.toques, c.postes);
    notifyListeners();
  }

  Future<void> agregarPoste() async {
    final c = _competidorActivo;
    if (c == null) return;

    c.postes++;
    _historialPenalizaciones.add('poste');
    await _service.actualizarPenalizaciones(c.dorsal, c.toques, c.postes);
    notifyListeners();
  }

  Future<void> deshacerUltimaPenalizacion() async {
    if (_historialPenalizaciones.isEmpty) return;

    final c = _competidorActivo;
    if (c == null) return;

    final ultima = _historialPenalizaciones.removeLast();
    if (ultima == 'toque' && c.toques > 0) {
      c.toques--;
    } else if (ultima == 'poste' && c.postes > 0) {
      c.postes--;
    }

    await _service.actualizarPenalizaciones(c.dorsal, c.toques, c.postes);
    notifyListeners();
  }

  Future<void> resetPenalizaciones() async {
    final c = _competidorActivo;
    if (c == null) return;

    c.toques = 0;
    c.postes = 0;
    _historialPenalizaciones.clear();
    await _service.actualizarPenalizaciones(c.dorsal, c.toques, c.postes);
    notifyListeners();
  }
}
