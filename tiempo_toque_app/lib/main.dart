import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/competidor.dart';
import 'providers/competidor_provider.dart';
import 'providers/cronometro_provider.dart';
import 'screens/lista_competidores_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Hive
  await Hive.initFlutter();

  // Registro del adapter de Competidor (DEBE IR ANTES DE ABRIR LA BOX)
  Hive.registerAdapter(CompetidorAdapter());

  // Abrir la box de competidores
  await Hive.openBox<Competidor>('competidores');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetidorProvider()),
        ChangeNotifierProvider(create: (_) => CronometroProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiempo & Toque',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ListaCompetidoresScreen(),
    );
  }
}
