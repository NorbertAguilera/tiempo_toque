import 'package:flutter/material.dart';
import '../models/competidor.dart';
import '../providers/competidor_provider.dart';
import '../services/ranking_service.dart';

class RankingProvider with ChangeNotifier {
  final RankingService _rankingService = RankingService();
  CompetidorProvider? _competidorProvider;

  RankingProvider({CompetidorProvider? provider}) {
    if (provider != null) {
      _competidorProvider = provider;
      _competidorProvider?.addListener(_onCompetidoresChanged);
      refrescarRanking();
    }
  }

  void updateCompetidorProvider(CompetidorProvider provider) {
    if (_competidorProvider != provider) {
      _competidorProvider?.removeListener(_onCompetidoresChanged);
      _competidorProvider = provider;
      _competidorProvider?.addListener(_onCompetidoresChanged);
      refrescarRanking();
    }
  }

  List<Competidor> _ranking = [];
  List<Competidor> _pendientes = [];

  List<Competidor> get ranking => _ranking;
  List<Competidor> get pendientes => _pendientes;

  void _onCompetidoresChanged() {
    refrescarRanking();
  }

  void refrescarRanking() {
    final provider = _competidorProvider;
    if (provider == null) return;

    final todos = provider.competidores;

    // Los que ya han corrido y están ordenados
    _ranking = _rankingService.obtenerRanking(todos);

    // Los que aún no tienen tiempoBase
    _pendientes = todos.where((c) => c.tiempoBase == null).toList();

    notifyListeners();
  }

  double getTiempoTotal(Competidor c) {
    return _rankingService.calcularTiempoTotal(c);
  }

  @override
  void dispose() {
    _competidorProvider?.removeListener(_onCompetidoresChanged);
    super.dispose();
  }
}
