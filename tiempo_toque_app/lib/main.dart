import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/competidor.dart';
import 'models/configuracion_penalizaciones.dart';
import 'providers/competidor_provider.dart';
import 'providers/cronometro_provider.dart';
import 'providers/ranking_provider.dart';
import 'providers/configuracion_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/menu_principal_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Hive
  await Hive.initFlutter();

  // Registro de los adapters
  Hive.registerAdapter(CompetidorAdapter());
  Hive.registerAdapter(ConfiguracionPenalizacionesAdapter());

  // Abrir las boxes
  await Hive.openBox<Competidor>('competidores');
  await Hive.openBox<ConfiguracionPenalizaciones>('configuracion');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetidorProvider()),
        ChangeNotifierProvider(create: (_) => CronometroProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider2<CompetidorProvider, ConfiguracionProvider, RankingProvider>(
          create: (_) => RankingProvider(),
          update: (_, compProv, configProv, rankProv) {
            final p = rankProv ?? RankingProvider();
            p.updateProviders(compProv, configProv);
            return p;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Tiempo & Toque',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MenuPrincipalScreen(),
    );
  }
}

