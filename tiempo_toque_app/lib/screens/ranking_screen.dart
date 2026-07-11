import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ranking_provider.dart';
import '../providers/configuracion_provider.dart';
import '../models/competidor.dart';
import '../widgets/fila_ranking.dart';
import '../widgets/display_tiempo.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  void _mostrarDetalleTiempo(BuildContext context, Competidor c, double total) {
    final configProv = Provider.of<ConfiguracionProvider>(context, listen: false);
    final valorToque = configProv.valorToque;
    final valorPoste = configProv.valorPoste;

    final tiempoBase = c.tiempoBase ?? 0.0;
    final toquesS = c.toques * valorToque;
    final postesS = c.postes * valorPoste;

    final String valorToqueTxt = valorToque.toString().replaceAll(RegExp(r'\.0$'), '');
    final String valorPosteTxt = valorPoste.toString().replaceAll(RegExp(r'\.0$'), '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desglose de ${c.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow('Tiempo Base', tiempoBase),
            _buildDetalleRow('Toques (${c.toques}x${valorToqueTxt}s)', toquesS),
            _buildDetalleRow('Postes (${c.postes}x${valorPosteTxt}s)', postesS),
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

  Future<void> _exportarCSV(BuildContext context, List<Competidor> ranking, RankingProvider rankingProv) async {
    try {
      final StringBuffer csv = StringBuffer();
      csv.writeln('Posicion,Dorsal,Nombre,Tiempo Base (s),Toques,Postes,Tiempo Total (s)');
      for (int i = 0; i < ranking.length; i++) {
        final c = ranking[i];
        final total = rankingProv.getTiempoTotal(c);
        csv.writeln('${i + 1},${c.dorsal},"${c.nombre.replaceAll('"', '""')}",${c.tiempoBase?.toStringAsFixed(2) ?? ""},${c.toques},${c.postes},${total.toStringAsFixed(2)}');
      }

      if (!context.mounted) return;

      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exportar CSV (Web)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Copia el contenido CSV a continuación:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    csv.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87),
                  ),
                ),
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
        return;
      }

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/ranking_tiempo_toque.csv');
      await file.writeAsString(csv.toString());

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ranking exportado a: ${file.path}'),
          action: SnackBarAction(
            label: 'Cerrar',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar CSV: $e')),
      );
    }
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
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: () => _exportarCSV(context, clasificados, rankingProv),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => rankingProv.refrescarRanking(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
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
        ),
      ),
    );
  }
}
