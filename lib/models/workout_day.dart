import 'package:hive/hive.dart';
import 'individual_exercise_model.dart';

part 'workout_day.g.dart';

@HiveType(typeId: 4)
class WorkoutDay {

  @HiveField(0)
  String name;

  @HiveField(1)
  String short;

  @HiveField(2)
  bool enabled;

  @HiveField(3)
  List<Exercise> exercises;

  WorkoutDay({
    required this.name,
    required this.short,
    this.enabled = true,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];
}
