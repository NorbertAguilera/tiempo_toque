import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_toque_app/models/competidor.dart';
import 'package:tiempo_toque_app/services/ranking_service.dart';

void main() {
  late RankingService rankingService;

  setUp(() {
    rankingService = RankingService();
  });

  group('RankingService Tests', () {
    test('calcularTiempoTotal calcula correctamente la suma de base y penalizaciones', () {
      final c = Competidor(
        dorsal: 1,
        nombre: 'Test',
        tiempoBase: 10.0,
        toques: 1, // +2s
        postes: 1, // +50s
      );

      // 10 + 2 + 50 = 62.0
      expect(rankingService.calcularTiempoTotal(c), 62.0);
    });

    test('calcularTiempoTotal retorna infinito si tiempoBase es null', () {
      final c = Competidor(
        dorsal: 1,
        nombre: 'Test',
        tiempoBase: null,
        toques: 1,
        postes: 1,
      );
      expect(rankingService.calcularTiempoTotal(c), double.infinity);
    });

    test('obtenerRanking ordena correctamente de menor a mayor tiempo total', () {
      final c1 = Competidor(dorsal: 1, nombre: 'Lento', tiempoBase: 60.0, toques: 0, postes: 0);
      final c2 = Competidor(dorsal: 2, nombre: 'Rapido', tiempoBase: 10.0, toques: 0, postes: 0);
      final c3 = Competidor(dorsal: 3, nombre: 'Medio', tiempoBase: 30.0, toques: 0, postes: 0);

      final ranking = rankingService.obtenerRanking([c1, c2, c3]);

      expect(ranking[0].dorsal, 2); // El más rápido (10s)
      expect(ranking[1].dorsal, 3); // El medio (30s)
      expect(ranking[2].dorsal, 1); // El lento (60s)
    });

    test('obtenerRanking excluye competidores con tiempoBase nulo', () {
      final c1 = Competidor(dorsal: 1, nombre: 'Corrió', tiempoBase: 10.0, toques: 0, postes: 0);
      final c2 = Competidor(dorsal: 2, nombre: 'Pendiente', tiempoBase: null, toques: 0, postes: 0);

      final ranking = rankingService.obtenerRanking([c1, c2]);

      expect(ranking.length, 1);
      expect(ranking[0].dorsal, 1);
    });

    test('obtenerRanking mantiene estabilidad en caso de empates exactos', () {
      final c1 = Competidor(dorsal: 1, nombre: 'A', tiempoBase: 10.0, toques: 0, postes: 0);
      final c2 = Competidor(dorsal: 2, nombre: 'B', tiempoBase: 10.0, toques: 0, postes: 0);

      final ranking = rankingService.obtenerRanking([c1, c2]);

      expect(ranking.length, 2);
      expect(ranking[0].tiempoBase, 10.0);
      expect(ranking[1].tiempoBase, 10.0);
    });
  });
}
