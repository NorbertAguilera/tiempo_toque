import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/competidor_provider.dart';
import '../widgets/competidor_tile.dart';
import 'formulario_competidor_screen.dart';
import 'cronometro_screen.dart';

class ListaCompetidoresScreen extends StatefulWidget {
  const ListaCompetidoresScreen({super.key});

  @override
  State<ListaCompetidoresScreen> createState() => _ListaCompetidoresScreenState();
}

class _ListaCompetidoresScreenState extends State<ListaCompetidoresScreen> {
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    // Cargar competidores al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetidorProvider>().cargarCompetidores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompetidorProvider>();
    final competidores = provider.competidores
        .where((c) =>
          c.nombre.toLowerCase().contains(_filtro.toLowerCase()) ||
          c.dorsal.toString().contains(_filtro))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competidores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar competidor...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _filtro = val;
                });
              },
            ),
          ),
          Expanded(
            child: competidores.isEmpty
              ? const Center(child: Text('No se encontraron competidores'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: competidores.length,
                  itemBuilder: (context, index) {
                    final c = competidores[index];
                    return CompetidorTile(
                      competidor: c,
                      isActive: provider.competidorActivo == c,
                      onTap: () => provider.seleccionarCompetidorActivo(c),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormularioCompetidorScreen(competidor: c),
                        ),
                      ),
                      onDelete: () {
                        _confirmarEliminacion(context, provider, c.dorsal);
                      },
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (provider.competidorActivo != null)
            FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CronometroScreen()),
              ),
              label: const Text('Iniciar Cronómetro'),
              icon: const Icon(Icons.timer),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormularioCompetidorScreen()),
            ),
            child: const Icon(Icons.add),
            tooltip: 'Agregar Competidor',
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, CompetidorProvider provider, int dorsal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Competidor'),
        content: const Text('¿Estás seguro de que deseas eliminar este participante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.eliminarCompetidor(dorsal);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
