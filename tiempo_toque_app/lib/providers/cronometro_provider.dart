import 'dart:async';
import 'package:flutter/material.dart';
import '../models/estado_cronometro.dart';

class CronometroProvider with ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  Duration _tiempoTranscurrido = Duration.zero;
  bool _enMarcha = false;
  bool _pausado = false;

  Duration get tiempoTranscurrido => _tiempoTranscurrido;
  bool get enMarcha => _enMarcha;
  bool get pausado => _pausado;

  EstadoCronometro get estado => EstadoCronometro(
    tiempoTranscurrido: _tiempoTranscurrido,
    enMarcha: _enMarcha,
    pausado: _pausado,
  );

  void iniciar() {
    if (!_enMarcha) {
      _stopwatch.reset();
      _stopwatch.start();
      _enMarcha = true;
      _pausado = false;
      _iniciarTimer();
      notifyListeners();
    }
  }

  void pausar() {
    if (_enMarcha && !_pausado) {
      _stopwatch.stop();
      _detenerTimer();
      _pausado = true;
      notifyListeners();
    }
  }

  void reanudar() {
    if (_enMarcha && _pausado) {
      _stopwatch.start();
      _iniciarTimer();
      _pausado = false;
      notifyListeners();
    }
  }

  void detener() {
    _stopwatch.stop();
    _detenerTimer();
    _enMarcha = false;
    _pausado = false;
    _tiempoTranscurrido = _stopwatch.elapsed;
    notifyListeners();
  }

  void reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _detenerTimer();
    _tiempoTranscurrido = Duration.zero;
    _enMarcha = false;
    _pausado = false;
    notifyListeners();
  }

  void actualizarTiempo() {
    _tiempoTranscurrido = _stopwatch.elapsed;
    notifyListeners();
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _tiempoTranscurrido = _stopwatch.elapsed;
      notifyListeners();
    });
  }

  void _detenerTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _detenerTimer();
    super.dispose();
  }
}
