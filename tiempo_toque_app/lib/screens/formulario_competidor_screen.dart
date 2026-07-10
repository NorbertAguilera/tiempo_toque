import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competidor.dart';
import '../providers/competidor_provider.dart';
import '../services/competidor_service.dart';

class FormularioCompetidorScreen extends StatefulWidget {
  final Competidor? competidor;

  const FormularioCompetidorScreen({super.key, this.competidor});

  @override
  State<FormularioCompetidorScreen> createState() => _FormularioCompetidorScreenState();
}

class _FormularioCompetidorScreenState extends State<FormularioCompetidorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dorsalController = TextEditingController();
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _service = CompetidorService();

  @override
  void initState() {
    super.initState();
    if (widget.competidor != null) {
      _dorsalController.text = widget.competidor!.dorsal.toString();
      _nombreController.text = widget.competidor!.nombre;
      _categoriaController.text = widget.competidor!.categoria ?? '';
    }
  }

  @override
  void dispose() {
    _dorsalController.dispose();
    _nombreController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final dorsal = int.tryParse(_dorsalController.text) ?? 0;
    final nombre = _nombreController.text.trim();
    final categoria = _categoriaController.text.trim();

    // Validación de unicidad del dorsal si es un competidor nuevo
    if (widget.competidor == null && _service.existeDorsal(dorsal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El dorsal ya está asignado a otro competidor')),
      );
      return;
    }

    final c = Competidor(
      dorsal: dorsal,
      nombre: nombre,
      categoria: categoria.isEmpty ? null : categoria,
      tiempoBase: widget.competidor?.tiempoBase,
      toques: widget.competidor?.toques ?? 0,
      postes: widget.competidor?.postes ?? 0,
    );

    final provider = context.read<CompetidorProvider>();
    if (widget.competidor == null) {
      provider.agregarCompetidor(c);
    } else {
      provider.editarCompetidor(c);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.competidor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Competidor' : 'Nuevo Competidor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dorsalController,
                decoration: const InputDecoration(
                  labelText: 'Dorsal',
                  hintText: 'Ej: 12',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'El dorsal es obligatorio';
                  if (int.tryParse(val) == null) return 'Debe ser un número entero';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Ej: Juan Pérez',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'El nombre es obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (Opcional)',
                  hintText: 'Ej: C1, K1...',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEditing ? 'Actualizar Datos' : 'Guardar Competidor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
