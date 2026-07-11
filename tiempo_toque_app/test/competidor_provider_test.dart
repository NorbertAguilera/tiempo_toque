import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_toque_app/models/competidor.dart';
import 'package:tiempo_toque_app/providers/competidor_provider.dart';
import 'package:tiempo_toque_app/services/competidor_service.dart';

// Mock simple para evitar dependencias de Hive en tests unitarios
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
    if (c != null) c.tiempoBase = tiempo;
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
  late CompetidorProvider provider;
  late MockCompetidorService mockService;

  setUp(() {
    mockService = MockCompetidorService();
    provider = CompetidorProvider(service: mockService);
  });

  group('Penalizaciones', () {
    test('agregarToque incrementa correctamente el contador y persiste', () async {
      final c = Competidor(dorsal: 1, nombre: 'Test');
      await provider.agregarCompetidor(c);
      provider.seleccionarCompetidorActivo(c);
      await provider.agregarToque();
      expect(provider.competidorActivo!.toques, 1);
      expect(mockService.obtenerCompetidores().first.toques, 1);
    });

    test('agregarPoste incrementa correctamente el contador y persiste', () async {
      final c = Competidor(dorsal: 1, nombre: 'Test');
      await provider.agregarCompetidor(c);
      provider.seleccionarCompetidorActivo(c);
      await provider.agregarPoste();
      expect(provider.competidorActivo!.postes, 1);
      expect(mockService.obtenerCompetidores().first.postes, 1);
    });

    test('deshacerUltimaPenalizacion remueve el último elemento correctamente (mezcla)', () async {
      final c = Competidor(dorsal: 1, nombre: 'Test');
      provider.seleccionarCompetidorActivo(c);
      await provider.agregarToque();
      await provider.agregarToque();
      await provider.agregarPoste();

      await provider.deshacerUltimaPenalizacion(); // quita poste
      expect(provider.competidorActivo!.toques, 2);
      expect(provider.competidorActivo!.postes, 0);

      await provider.deshacerUltimaPenalizacion(); // quita toque
      expect(provider.competidorActivo!.toques, 1);
    });

    test('resetPenalizaciones deja todo en cero y limpia historial', () async {
      final c = Competidor(dorsal: 1, nombre: 'Test');
      provider.seleccionarCompetidorActivo(c);
      await provider.agregarToque();
      await provider.agregarPoste();

      await provider.resetPenalizaciones();

      expect(provider.competidorActivo!.toques, 0);
      expect(provider.competidorActivo!.postes, 0);
      expect(provider.historialPenalizaciones, isEmpty);
    });

    test('agregarCompetidor lanza excepción si el dorsal ya existe', () async {
      final c1 = Competidor(dorsal: 1, nombre: 'User 1');
      await provider.agregarCompetidor(c1);

      expect(
        () async => await provider.agregarCompetidor(Competidor(dorsal: 1, nombre: 'User 2')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
