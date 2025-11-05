


// Model for Exercise
import 'individual_set.dart';

class Exercise {
  String name;
  List<ExerciseSet> sets;
  DateTime date; // New field

  Exercise({
    required this.name,
    required this.sets,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      sets: (map['sets'] as List).map((s) => ExerciseSet.fromMap(s)).toList(),
      date: DateTime.parse(map['date']),
    );
  }
}