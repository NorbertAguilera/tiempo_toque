import 'package:flutter/material.dart';
import '../models/competidor.dart';
import '../widgets/display_tiempo.dart';

class FilaRanking extends StatelessWidget {
  final Competidor competidor;
  final int posicion;
  final double tiempoTotal;
  final VoidCallback onTap;
  final bool esPrimero;

  const FilaRanking({
    super.key,
    required this.competidor,
    required this.posicion,
    required this.tiempoTotal,
    required this.onTap,
    this.esPrimero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: esPrimero ? Theme.of(context).colorScheme.primaryContainer : null,
      elevation: esPrimero ? 4 : 1,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: esPrimero ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: esPrimero ? Colors.white : null,
          child: Text(
            posicion == 1 ? '🥇' : '$posicion',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          competidor.nombre,
          style: TextStyle(
            fontWeight: esPrimero ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('Dorsal: ${competidor.dorsal}'),
        trailing: DisplayTiempo(
          duration: Duration(milliseconds: (tiempoTotal * 1000).toInt()),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: esPrimero ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}
