import 'package:flutter/material.dart';
import '../models/competidor.dart';

class CompetidorProvider with ChangeNotifier {
  // Marcador de posición para la lógica de gestión de competidores
  List<Competidor> _competidores = [];

  List<Competidor> get competidores => _competidores;

  // Aquí se implementarán métodos como addCompetidor, removeCompetidor, etc.
}
