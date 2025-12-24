import 'package:hive/hive.dart';

part 'individual_set.g.dart';

@HiveType(typeId: 1)
class ExerciseSet {
  @HiveField(0)
  int setNumber;

  @HiveField(1)
  String weight;

  @HiveField(2)
  String reps;

  @HiveField(3)
  DateTime? completedAt;

  ExerciseSet({
    required this.setNumber,
    this.weight = '',
    this.reps = '',
    this.completedAt,
  });
}
