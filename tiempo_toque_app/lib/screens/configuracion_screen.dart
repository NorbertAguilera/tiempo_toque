import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configuracion_provider.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late TextEditingController _toqueController;
  late TextEditingController _posteController;

  @override
  void initState() {
    super.initState();
    final config = context.read<ConfiguracionProvider>();
    _toqueController = TextEditingController(text: config.valorToque.toString());
    _posteController = TextEditingController(text: config.valorPoste.toString());
  }

  @override
  void dispose() {
    _toqueController.dispose();
    _posteController.dispose();
    super.dispose();
  }

  void _guardar() {
    final toque = double.tryParse(_toqueController.text) ?? 2.0;
    final poste = double.tryParse(_posteController.text) ?? 50.0;

    context.read<ConfiguracionProvider>().actualizarValores(toque, poste);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Valores de Penalizaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _toqueController,
              decoration: const InputDecoration(
                labelText: 'Valor Toque (segundos)',
                prefixIcon: Icon(Icons.touch_app),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _posteController,
              decoration: const InputDecoration(
                labelText: 'Valor Poste (segundos)',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Configuración'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
