


// Model for individual sets
class ExerciseSet {
  int setNumber;
  String weight;
  String reps;

  ExerciseSet({
    required this.setNumber,
    this.weight = '',
    this.reps = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      setNumber: map['setNumber'],
      weight: map['weight'] ?? '',
      reps: map['reps'] ?? '',
    );
  }
}