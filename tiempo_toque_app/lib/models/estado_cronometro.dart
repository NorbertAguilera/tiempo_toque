class EstadoCronometro {
  final Duration tiempoTranscurrido;
  final bool enMarcha;
  final bool pausado;

  EstadoCronometro({
    required this.tiempoTranscurrido,
    required this.enMarcha,
    required this.pausado,
  });

  EstadoCronometro copyWith({
    Duration? tiempoTranscurrido,
    bool? enMarcha,
    bool? pausado,
  }) {
    return EstadoCronometro(
      tiempoTranscurrido: tiempoTranscurrido ?? this.tiempoTranscurrido,
      enMarcha: enMarcha ?? this.enMarcha,
      pausado: pausado ?? this.pausado,
    );
  }
}
