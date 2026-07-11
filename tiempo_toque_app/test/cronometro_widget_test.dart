import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tiempo_toque_app/providers/cronometro_provider.dart';
import 'package:tiempo_toque_app/providers/competidor_provider.dart';
import 'package:tiempo_toque_app/providers/configuracion_provider.dart';
import 'package:tiempo_toque_app/screens/cronometro_screen.dart';
import 'package:tiempo_toque_app/models/competidor.dart';
import 'package:tiempo_toque_app/models/configuracion_penalizaciones.dart';
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
  Widget createWidgetForTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetidorProvider(service: MockCompetidorService())),
        ChangeNotifierProvider(create: (_) => CronometroProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider(
          initialConfig: ConfiguracionPenalizaciones(valorToque: 2.0, valorPoste: 50.0),
        )),
      ],
      child: const MaterialApp(
        home: CronometroScreen(),
      ),
    );
  }

  testWidgets('Verifica estados de botones en CronometroScreen', (WidgetTester tester) async {
    // Configurar el tamaño físico de la pantalla para evitar problemas de scroll/fuera de pantalla en el test
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetForTest());

    // Al inicio no hay competidor activo, debe mostrar el aviso
    expect(find.text('No hay un competidor seleccionado'), findsOneWidget);

    // Accedemos al provider para configurar el estado
    final compProv = Provider.of<CompetidorProvider>(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );

    final c = Competidor(dorsal: 1, nombre: 'Test User');
    await compProv.agregarCompetidor(c);
    compProv.seleccionarCompetidorActivo(c);

    await tester.pumpAndSettle(); // Rebuild la pantalla

    // Ahora debe mostrar el cronómetro
    expect(find.text('Test User'), findsOneWidget);
    
    // Al inicio (Detenido / Reset):
    // - Iniciar: Visible (porque enMarcha = false)
    // - Pausar / Detener: Oculto
    // - Reset: Visible y Habilitado (onPressed != null)
    expect(find.text('Iniciar'), findsOneWidget);
    expect(find.text('Pausar'), findsNothing);
    expect(find.text('Detener'), findsNothing);
    
    final resetBtnInitial = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Reset'));
    expect(resetBtnInitial.onPressed, isNotNull);

    // Iniciar cronómetro
    await tester.tap(find.text('Iniciar'));
    await tester.pump();

    // En marcha (Corriendo):
    // - Iniciar: Oculto (porque enMarcha = true)
    // - Pausar: Visible
    // - Detener: Visible
    // - Reset: Visible pero Deshabilitado (onPressed == null)
    expect(find.text('Iniciar'), findsNothing);
    expect(find.text('Pausar'), findsOneWidget);
    expect(find.text('Detener'), findsOneWidget);
    
    final resetBtnRunning = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Reset'));
    expect(resetBtnRunning.onPressed, isNull);

    // Pausar
    await tester.tap(find.text('Pausar'));
    await tester.pump();

    // En marcha (Pausado):
    // - Reanudar: Visible
    // - Detener: Visible
    // - Reset: Visible pero Deshabilitado
    expect(find.text('Reanudar'), findsOneWidget);
    expect(find.text('Detener'), findsOneWidget);
    
    final resetBtnPaused = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Reset'));
    expect(resetBtnPaused.onPressed, isNull);

    // Reanudar
    await tester.tap(find.text('Reanudar'));
    await tester.pump();

    expect(find.text('Pausar'), findsOneWidget);
  });
}
