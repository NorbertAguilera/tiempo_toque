import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/configuracion_penalizaciones.dart';

class ConfiguracionProvider with ChangeNotifier {
  static const String _boxName = 'configuracion';

  late ConfiguracionPenalizaciones _config;

  ConfiguracionProvider({ConfiguracionPenalizaciones? initialConfig}) {
    if (initialConfig != null) {
      _config = initialConfig;
    } else {
      _init();
    }
  }

  Future<void> _init() async {
    var box = await Hive.openBox<ConfiguracionPenalizaciones>(_boxName);
    _config = box.get('settings') ?? ConfiguracionPenalizaciones();
    notifyListeners();
  }

  double get valorToque => _config.valorToque;
  double get valorPoste => _config.valorPoste;

  void actualizarValores(double toque, double poste) async {
    _config.valorToque = toque;
    _config.valorPoste = poste;

    var box = Hive.box<ConfiguracionPenalizaciones>(_boxName);
    await box.put('settings', _config);

    notifyListeners();
  }
}
