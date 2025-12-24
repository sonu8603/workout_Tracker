// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayConfigAdapter extends TypeAdapter<DayConfig> {
  @override
  final int typeId = 2;

  @override
  DayConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayConfig(
      name: fields[0] as String,
      shortName: fields[1] as String,
      enabled: fields[2] as bool,
      weekdayNumber: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DayConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.shortName)
      ..writeByte(2)
      ..write(obj.enabled)
      ..writeByte(3)
      ..write(obj.weekdayNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
