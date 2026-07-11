import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_toque_app/models/competidor.dart';
import 'package:tiempo_toque_app/providers/competidor_provider.dart';
import 'package:tiempo_toque_app/services/competidor_service.dart';

// Fake service para evitar dependencias de Mockito y generación de código en tests
class FakeCompetidorService extends CompetidorService {
  int? savedToques;
  int? savedPostes;
  int callCount = 0;

  @override
  Future<void> actualizarPenalizaciones(int dorsal, int toques, int postes) async {
    savedToques = toques;
    savedPostes = postes;
    callCount++;
  }

  @override
  bool existeDorsal(int dorsal) => false;
}

void main() {
  late CompetidorProvider provider;
  late FakeCompetidorService fakeService;
  late Competidor testCompetidor;

  setUp(() {
    fakeService = FakeCompetidorService();
    provider = CompetidorProvider(service: fakeService);
    testCompetidor = Competidor(
      dorsal: 1,
      nombre: 'Test User',
      tiempoBase: 0.0,
      toques: 0,
      postes: 0,
    );
    provider.seleccionarCompetidorActivo(testCompetidor);
  });

  group('Penalizaciones', () {
    test('agregarToque incrementa correctamente el contador y persiste', () async {
      provider.agregarToque();
      expect(provider.competidorActivo!.toques, 1);
      expect(fakeService.savedToques, 1);
      expect(fakeService.callCount, 1);
    });

    test('agregarPoste incrementa correctamente el contador y persiste', () async {
      provider.agregarPoste();
      expect(provider.competidorActivo!.postes, 1);
      expect(fakeService.savedPostes, 1);
      expect(fakeService.callCount, 1);
    });

    test('deshacerUltimaPenalizacion remueve el último elemento correctamente (mezcla)', () async {
      provider.agregarToque(); // 1,0
      provider.agregarToque(); // 2,0
      provider.agregarPoste(); // 2,1

      provider.deshacerUltimaPenalizacion(); // Debe quitar el poste
      expect(provider.competidorActivo!.toques, 2);
      expect(provider.competidorActivo!.postes, 0);
      expect(fakeService.savedPostes, 0);

      provider.deshacerUltimaPenalizacion(); // Debe quitar un toque
      expect(provider.competidorActivo!.toques, 1);
      expect(provider.competidorActivo!.postes, 0);
      expect(fakeService.savedToques, 1);
    });

    test('resetPenalizaciones deja todo en cero y limpia historial', () async {
      provider.agregarToque();
      provider.agregarPoste();

      provider.resetPenalizaciones();

      expect(provider.competidorActivo!.toques, 0);
      expect(provider.competidorActivo!.postes, 0);
      expect(provider.historialPenalizaciones, isEmpty);
      expect(fakeService.savedToques, 0);
      expect(fakeService.savedPostes, 0);
    });
  });
}
