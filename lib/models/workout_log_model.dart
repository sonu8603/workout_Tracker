// lib/models/workout_log_model.dart
// ⚠️ YE NEW FILE HAI - Copy karo: lib/models/ folder mein

import 'package:hive/hive.dart';
import 'individual_set.dart';

part 'workout_log_model.g.dart';

/// Completed exercise in workout log
@HiveType(typeId: 5)
class CompletedExercise extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ExerciseSet> sets;

  @HiveField(3)
  DateTime completedAt;

  CompletedExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.completedAt,
  });

  List<ExerciseSet> get completedSets =>
      sets.where((s) => _isSetCompleted(s)).toList();

  bool _isSetCompleted(ExerciseSet set) {
    if (set.weight.isEmpty || set.reps.isEmpty) return false;
    final weight = double.tryParse(set.weight);
    final reps = int.tryParse(set.reps);
    return weight != null && reps != null && weight > 0 && reps > 0;
  }

  double get totalVolume {
    return completedSets.fold(0.0, (sum, set) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.reps) ?? 0;
      return sum + (weight * reps);
    });
  }
}

/// Workout session log
@HiveType(typeId: 6)
class WorkoutLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String dayName;

  @HiveField(2)
  List<CompletedExercise> exercises;

  @HiveField(3)
  DateTime startedAt;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  String? notes;

  WorkoutLog({
    required this.date,
    required this.dayName,
    required this.exercises,
    required this.startedAt,
    this.completedAt,
    this.notes,
  });

  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  int get totalCompletedSets {
    return exercises.fold(0, (sum, ex) => sum + ex.completedSets.length);
  }

  double get totalVolume {
    return exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);
  }
}