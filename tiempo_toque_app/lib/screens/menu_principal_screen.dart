import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'lista_competidores_screen.dart';
import 'cronometro_screen.dart';
import 'ranking_screen.dart';
import 'configuracion_screen.dart';

class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiempo & Toque'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Switch(
            value: themeProv.isDarkMode,
            onChanged: (val) => themeProv.toggleTheme(),
            activeThumbColor: Colors.deepPurple,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _MenuButton(
            label: 'Participantes',
            icon: Icons.people,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaCompetidoresScreen())),
          ),
          _MenuButton(
            label: 'Cronómetro',
            icon: Icons.timer,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CronometroScreen())),
          ),
          _MenuButton(
            label: 'Ranking',
            icon: Icons.emoji_events,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingScreen())),
          ),
          _MenuButton(
            label: 'Configuración',
            icon: Icons.settings,
            color: Colors.grey,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracionScreen())),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: color.withAlpha(51),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
