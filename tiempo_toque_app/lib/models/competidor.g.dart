// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competidor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompetidorAdapter extends TypeAdapter<Competidor> {
  @override
  final int typeId = 0;

  @override
  Competidor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Competidor(
      dorsal: fields[0] as int,
      nombre: fields[1] as String,
      categoria: fields[2] as String?,
      tiempoBase: fields[3] as double?,
      toques: fields[4] as int,
      postes: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Competidor obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dorsal)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.tiempoBase)
      ..writeByte(4)
      ..write(obj.toques)
      ..writeByte(5)
      ..write(obj.postes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetidorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
