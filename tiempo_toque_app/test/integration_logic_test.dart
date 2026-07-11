import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_toque_app/models/competidor.dart';
import 'package:tiempo_toque_app/models/configuracion_penalizaciones.dart';
import 'package:tiempo_toque_app/providers/competidor_provider.dart';
import 'package:tiempo_toque_app/providers/configuracion_provider.dart';
import 'package:tiempo_toque_app/providers/ranking_provider.dart';
import 'package:tiempo_toque_app/services/competidor_service.dart';

// Mock simple para evitar dependencias de Hive en tests de integración lógica
class MockCompetidorService extends CompetidorService {
  final Map<int, Competidor> _data = {};

  @override
  List<Competidor> obtenerCompetidores() => _data.values.toList();

  @override
  Future<void> crearCompetidor(Competidor c) async => _data[c.dorsal] = c;

  @override
  Future<void> actualizarCompetidor(Competidor c) async => _data[c.dorsal] = c;

  @override
  Future<void> eliminarCompetidor(int dorsal) async => _data.remove(dorsal);

  @override
  bool existeDorsal(int dorsal) => _data.containsKey(dorsal);

  @override
  Future<void> guardarTiempoBase(int dorsal, double tiempo) async {
    final c = _data[dorsal];
    if (c != null) {
      c.tiempoBase = tiempo;
    }
  }

  @override
  Future<void> actualizarPenalizaciones(int dorsal, int toques, int postes) async {
    final c = _data[dorsal];
    if (c != null) {
      c.toques = toques;
      c.postes = postes;
    }
  }
}

void main() {
  test('Flujo Completo: Crear -> Cronometrar -> Penalizar -> Ranking', () async {
    final mockService = MockCompetidorService();
    final compProv = CompetidorProvider(service: mockService);
    final configProv = ConfiguracionProvider(
      initialConfig: ConfiguracionPenalizaciones(valorToque: 2.0, valorPoste: 50.0),
    );
    final rankProv = RankingProvider();
    rankProv.updateProviders(compProv, configProv);

    // 1. Crear dos competidores
    final c1 = Competidor(dorsal: 1, nombre: 'la rapidez', tiempoBase: null);
    final c2 = Competidor(dorsal: 2, nombre: 'el lento', tiempoBase: null);

    await compProv.agregarCompetidor(c1);
    await compProv.agregarCompetidor(c2);

    // 2. Simular manga del C1: 10s + 1 toque (+2s) = 12s
    compProv.seleccionarCompetidorActivo(c1);
    await compProv.guardarTiempoBase(c1.dorsal, 10.0);
    await compProv.agregarToque();

    // 3. Simular manga del C2: 20s + 0 penalizaciones = 20s
    compProv.seleccionarCompetidorActivo(c2);
    await compProv.guardarTiempoBase(c2.dorsal, 20.0);

    // 4. Refrescar ranking
    rankProv.refrescarRanking();

    // 5. Verificar resultados
    expect(rankProv.ranking.length, 2);
    expect(rankProv.ranking[0].dorsal, 1); // C1 debe ser el primero
    expect(rankProv.getTiempoTotal(rankProv.ranking[0]), 12.0);
    expect(rankProv.ranking[1].dorsal, 2); // C2 segundo
    expect(rankProv.getTiempoTotal(rankProv.ranking[1]), 20.0);
  });
}
