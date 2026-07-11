import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ranking_provider.dart';
import '../models/competidor.dart';
import '../widgets/fila_ranking.dart';
import '../widgets/display_tiempo.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  void _mostrarDetalleTiempo(BuildContext context, Competidor c, double total) {
    final tiempoBase = c.tiempoBase ?? 0.0;
    final toquesS = c.toques * 2.0;
    final postesS = c.postes * 50.0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desglose de ${c.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow('Tiempo Base', tiempoBase),
            _buildDetalleRow('Toques (${c.toques}x2s)', toquesS),
            _buildDetalleRow('Postes (${c.postes}x50s)', postesS),
            const Divider(),
            _buildDetalleRow('TOTAL', total, isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          DisplayTiempo(
            duration: Duration(milliseconds: (value * 1000).toInt()),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankingProv = context.watch<RankingProvider>();
    final clasificados = rankingProv.ranking;
    final pendientes = rankingProv.pendientes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => rankingProv.refrescarRanking(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (clasificados.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Aún no hay tiempos registrados'),
              ),
            )
          else ...[
            const Text(
              'Clasificados',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...clasificados.asMap().entries.map((entry) {
              final index = entry.key;
              final c = entry.value;
              return FilaRanking(
                posicion: index + 1,
                competidor: c,
                tiempoTotal: rankingProv.getTiempoTotal(c),
                esPrimero: index == 0,
                onTap: () => _mostrarDetalleTiempo(context, c, rankingProv.getTiempoTotal(c)),
              );
            }),
          ],
          if (pendientes.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Divider(),
            const Text(
              'Pendientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...pendientes.map((c) => ListTile(
              leading: CircleAvatar(child: Text(c.dorsal.toString())),
              title: Text(c.nombre),
              subtitle: const Text('Aún no ha corrido'),
              enabled: false,
            )),
          ],
        ],
      ),
    );
  }
}
