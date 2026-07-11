import 'package:flutter/material.dart';
import '../models/competidor.dart';

class CompetidorTile extends StatelessWidget {
  final Competidor competidor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isActive;

  const CompetidorTile({
    super.key,
    required this.competidor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(competidor.dorsal.toString()),
        ),
        title: Text(
          competidor.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(competidor.categoria ?? 'Sin categoría'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
