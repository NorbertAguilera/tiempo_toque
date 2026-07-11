import '../models/competidor.dart';

class RankingService {
  /// Calcula el tiempo total de un competidor basándose en los valores configurados.
  double calcularTiempoTotal(Competidor c, double valorToque, double valorPoste) {
    if (c.tiempoBase == null) {
      return double.infinity;
    }
    return c.tiempoBase! + (c.toques * valorToque) + (c.postes * valorPoste);
  }

  /// Retorna una lista de competidores ordenada de menor a mayor tiempo total.
  /// Recibe los valores de penalización para el cálculo.
  List<Competidor> obtenerRanking(List<Competidor> todos, double valorToque, double valorPoste) {
    // Filtrar solo los que han corrido
    final clasificados = todos.where((c) => c.tiempoBase != null).toList();

    // Ordenar por tiempo total ascendente
    clasificados.sort((a, b) {
      final totalA = calcularTiempoTotal(a, valorToque, valorPoste);
      final totalB = calcularTiempoTotal(b, valorToque, valorPoste);
      return totalA.compareTo(totalB);
    });

    return clasificados;
  }
}
