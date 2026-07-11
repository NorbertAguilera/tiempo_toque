import 'package:flutter/material.dart';
import '../models/competidor.dart';
import '../providers/competidor_provider.dart';
import '../providers/configuracion_provider.dart';
import '../services/ranking_service.dart';

class RankingProvider with ChangeNotifier {
  final RankingService _rankingService = RankingService();
  CompetidorProvider? _competidorProvider;
  ConfiguracionProvider? _configProvider;

  RankingProvider() {
    // El provider se inyectará mediante ProxyProvider
  }

  void updateProviders(CompetidorProvider compProv, ConfiguracionProvider configProv) {
    if (_competidorProvider != compProv || _configProvider != configProv) {
      _competidorProvider?.removeListener(_onCompetidoresChanged);
      _competidorProvider = compProv;
      _configProvider = configProv;
      _competidorProvider?.addListener(_onCompetidoresChanged);
      refrescarRanking();
    }
  }

  void _onCompetidoresChanged() {
    refrescarRanking();
  }

  List<Competidor> _ranking = [];
  List<Competidor> _pendientes = [];

  List<Competidor> get ranking => _ranking;
  List<Competidor> get pendientes => _pendientes;

  void refrescarRanking() {
    final provider = _competidorProvider;
    final config = _configProvider;
    if (provider == null || config == null) return;

    final todos = provider.competidores;

    // Los que ya han corrido y están ordenados
    _ranking = _rankingService.obtenerRanking(todos, config.valorToque, config.valorPoste);

    // Los que aún no tienen tiempoBase
    _pendientes = todos.where((c) => c.tiempoBase == null).toList();

    notifyListeners();
  }

  double getTiempoTotal(Competidor c) {
    final config = _configProvider;
    if (config == null) return _rankingService.calcularTiempoTotal(c, 2.0, 50.0);
    return _rankingService.calcularTiempoTotal(c, config.valorToque, config.valorPoste);
  }

  @override
  void dispose() {
    _competidorProvider?.removeListener(_onCompetidoresChanged);
    super.dispose();
  }
}
