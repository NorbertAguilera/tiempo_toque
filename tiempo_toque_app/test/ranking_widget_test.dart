import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tiempo_toque_app/providers/competidor_provider.dart';
import 'package:tiempo_toque_app/providers/configuracion_provider.dart';
import 'package:tiempo_toque_app/providers/ranking_provider.dart';
import 'package:tiempo_toque_app/models/competidor.dart';
import 'package:tiempo_toque_app/models/configuracion_penalizaciones.dart';
import 'package:tiempo_toque_app/screens/ranking_screen.dart';
import 'package:tiempo_toque_app/services/competidor_service.dart';

// Mock simple para evitar dependencias de Hive en tests de widgets
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
  Widget createRankingWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetidorProvider(service: MockCompetidorService())),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider(
          initialConfig: ConfiguracionPenalizaciones(valorToque: 2.0, valorPoste: 50.0),
        )),
        ChangeNotifierProxyProvider2<CompetidorProvider, ConfiguracionProvider, RankingProvider>(
          create: (_) => RankingProvider(),
          update: (_, compProv, configProv, rankProv) {
            final p = rankProv ?? RankingProvider();
            p.updateProviders(compProv, configProv);
            return p;
          },
        ),
      ],
      child: const MaterialApp(
        home: RankingScreen(),
      ),
    );
  }

  testWidgets('Verifica renderizado de RankingScreen vacio', (WidgetTester tester) async {
    await tester.pumpWidget(createRankingWidget());

    // Debe mostrar que aún no hay tiempos registrados
    expect(find.text('Aún no hay tiempos registrados'), findsOneWidget);
    expect(find.text('Clasificados'), findsNothing);
    expect(find.text('Pendientes'), findsNothing);
  });

  testWidgets('Verifica renderizado de RankingScreen ordenado y pendientes', (WidgetTester tester) async {
    await tester.pumpWidget(createRankingWidget());

    final compProv = Provider.of<CompetidorProvider>(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );

    // 1. Añadimos un competidor lento (20s) y uno rápido (10s) y uno pendiente
    final lento = Competidor(dorsal: 10, nombre: 'Competidor Lento', tiempoBase: 20.0);
    final rapido = Competidor(dorsal: 20, nombre: 'Competidor Rapido', tiempoBase: 10.0);
    final pendiente = Competidor(dorsal: 30, nombre: 'Competidor Pendiente', tiempoBase: null);

    await compProv.agregarCompetidor(lento);
    await compProv.agregarCompetidor(rapido);
    await compProv.agregarCompetidor(pendiente);

    await tester.pumpAndSettle();

    // Verificamos que se renderizan
    expect(find.text('Clasificados'), findsOneWidget);
    expect(find.text('Competidor Rapido'), findsOneWidget);
    expect(find.text('Competidor Lento'), findsOneWidget);

    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Competidor Pendiente'), findsOneWidget);
    expect(find.text('Aún no ha corrido'), findsOneWidget);

    // Verificamos el orden: el más rápido debe estar al principio.
    // Podemos buscar la lista de textos y confirmar que "Competidor Rapido" aparece antes de "Competidor Lento".
    final finderRapido = find.text('Competidor Rapido');
    final finderLento = find.text('Competidor Lento');
    
    expect(tester.getCenter(finderRapido).dy, lessThan(tester.getCenter(finderLento).dy));
  });
}
