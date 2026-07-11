import 'package:flutter_test/flutter_test.dart';
import 'package:tiempo_toque_app/providers/cronometro_provider.dart';

void main() {
  group('CronometroProvider Tests', () {
    test('iniciar cambia el estado a enMarcha y comienza a contar', () async {
      final provider = CronometroProvider();

      expect(provider.enMarcha, false);
      expect(provider.tiempoTranscurrido, Duration.zero);

      provider.iniciar();
      expect(provider.enMarcha, true);

      // Esperamos un poco para verificar que el tiempo avanza
      await Future.delayed(Duration(milliseconds: 100));
      expect(provider.tiempoTranscurrido.inMilliseconds, greaterThan(0));
    });

    test('pausar y reanudar detienen y retoman el tiempo', () async {
      final provider = CronometroProvider();
      provider.iniciar();

      await Future.delayed(Duration(milliseconds: 50));
      provider.pausar();

      final tiempoAlPausar = provider.tiempoTranscurrido;
      expect(provider.pausado, true);

      await Future.delayed(Duration(milliseconds: 50));
      // El tiempo no debería haber avanzado mientras estaba pausado
      expect(provider.tiempoTranscurrido, tiempoAlPausar);

      provider.reanudar();
      expect(provider.pausado, false);

      await Future.delayed(Duration(milliseconds: 50));
      expect(provider.tiempoTranscurrido, isNot(equals(tiempoAlPausar)));
    });

    test('detener congela el tiempo y cambia el estado', () async {
      final provider = CronometroProvider();
      provider.iniciar();
      await Future.delayed(Duration(milliseconds: 50));

      provider.detener();
      final tiempoFinal = provider.tiempoTranscurrido;

      expect(provider.enMarcha, false);
      expect(provider.pausado, false);

      await Future.delayed(Duration(milliseconds: 50));
      expect(provider.tiempoTranscurrido, tiempoFinal);
    });

    test('reset pone el tiempo a cero y reinicia estados', () async {
      final provider = CronometroProvider();
      provider.iniciar();
      await Future.delayed(Duration(milliseconds: 50));

      provider.reset();

      expect(provider.tiempoTranscurrido, Duration.zero);
      expect(provider.enMarcha, false);
      expect(provider.pausado, false);
    });
  });
}
