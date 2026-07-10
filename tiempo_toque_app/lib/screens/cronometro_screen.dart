import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/competidor_provider.dart';
import '../providers/cronometro_provider.dart';
import '../widgets/display_tiempo.dart';

class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key});

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Forzar actualización de la UI al volver al primer plano
      final provider = Provider.of<CronometroProvider>(context, listen: false);
      provider.actualizarTiempo();
    }
  }

  void _confirmarGuardado(BuildContext context, CompetidorProvider compProv, CronometroProvider cronoProv) {
    final tiempoSegundos = cronoProv.tiempoTranscurrido.inMilliseconds / 1000.0;
    final competidor = compProv.competidorActivo;

    if (competidor == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar tiempo'),
        content: Text('¿Guardar ${tiempoSegundos.toStringAsFixed(2)}s para ${competidor.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              compProv.guardarTiempoBase(competidor.dorsal, tiempoSegundos);
              cronoProv.detener();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tiempo guardado correctamente')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compProv = context.watch<CompetidorProvider>();
    final cronoProv = context.watch<CronometroProvider>();
    final activeComp = compProv.competidorActivo;

    if (activeComp == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cronómetro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'No hay un competidor seleccionado',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver a la lista'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronómetro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cabecera Competidor
          Text(
            'Dorsal: ${activeComp.dorsal}',
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            activeComp.nombre,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),

          // Display del Tiempo
          DisplayTiempo(duration: cronoProv.tiempoTranscurrido),

          const SizedBox(height: 48),

          // Controles
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // Botón Iniciar
              if (!cronoProv.enMarcha)
                ElevatedButton.icon(
                  onPressed: () => cronoProv.iniciar(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),

              // Botón Pausar / Reanudar
              if (cronoProv.enMarcha)
                ElevatedButton.icon(
                  onPressed: () {
                    if (cronoProv.pausado) {
                      cronoProv.reanudar();
                    } else {
                      cronoProv.pausar();
                    }
                  },
                  icon: Icon(cronoProv.pausado ? Icons.play_arrow : Icons.pause),
                  label: Text(cronoProv.pausado ? 'Reanudar' : 'Pausar'),
                ),

              // Botón Detener
              if (cronoProv.enMarcha)
                ElevatedButton.icon(
                  onPressed: () => _confirmarGuardado(context, compProv, cronoProv),
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),

              // Botón Reset
              ElevatedButton.icon(
                onPressed: (!cronoProv.enMarcha) ? () => cronoProv.reset() : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
