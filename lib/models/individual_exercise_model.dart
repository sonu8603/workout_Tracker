import 'package:hive/hive.dart';
import 'individual_set.dart';

part 'individual_exercise_model.g.dart';

@HiveType(typeId: 3)
class Exercise extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ExerciseSet> sets;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isExtra; // regular vs extra exercise

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.date,
    this.isExtra = false,
  });
}
