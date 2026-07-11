import '../models/competidor.dart';

class RankingService {
  /// Calcula el tiempo total de un competidor basándose en la fórmula:
  /// Total = tiempoBase + (toques * 2) + (postes * 50)
  double calcularTiempoTotal(Competidor c) {
    if (c.tiempoBase == null) {
      return double.infinity;
    }
    return c.tiempoBase! + (c.toques * 2) + (c.postes * 50);
  }

  /// Retorna una lista de competidores ordenada de menor a mayor tiempo total.
  /// Excluye a los competidores que no tengan tiempoBase asignado.
  List<Competidor> obtenerRanking(List<Competidor> todos) {
    // Filtrar solo los que han corrido
    final clasificados = todos.where((c) => c.tiempoBase != null).toList();

    // Ordenar por tiempo total ascendente
    clasificados.sort((a, b) {
      final totalA = calcularTiempoTotal(a);
      final totalB = calcularTiempoTotal(b);
      return totalA.compareTo(totalB);
    });

    return clasificados;
  }
}
