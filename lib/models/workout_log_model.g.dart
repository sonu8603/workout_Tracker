// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletedExerciseAdapter extends TypeAdapter<CompletedExercise> {
  @override
  final int typeId = 5;

  @override
  CompletedExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedExercise(
      exerciseId: fields[0] as String,
      name: fields[1] as String,
      sets: (fields[2] as List).cast<ExerciseSet>(),
      completedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedExercise obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutLogAdapter extends TypeAdapter<WorkoutLog> {
  @override
  final int typeId = 6;

  @override
  WorkoutLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLog(
      date: fields[0] as DateTime,
      dayName: fields[1] as String,
      exercises: (fields[2] as List).cast<CompletedExercise>(),
      startedAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.dayName)
      ..writeByte(2)
      ..write(obj.exercises)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
