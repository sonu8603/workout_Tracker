import 'package:flutter/material.dart';

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

// Model for Exercise
class Exercise {
  String name;
  List<ExerciseSet> sets;

  Exercise({
    required this.name,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      sets: (map['sets'] as List).map((s) => ExerciseSet.fromMap(s)).toList(),
    );
  }
}

class ExerciseProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _days = [
    {"name": "Monday", "short": "M", "enabled": true, "exercises": <String>[]},
    {"name": "Tuesday", "short": "T", "enabled": true, "exercises": <String>[]},
    {"name": "Wednesday", "short": "W", "enabled": true, "exercises": <String>[]},
    {"name": "Thursday", "short": "Th", "enabled": true, "exercises": <String>[]},
    {"name": "Friday", "short": "F", "enabled": true, "exercises": <String>[]},
    {"name": "Saturday", "short": "Sa", "enabled": true, "exercises": <String>[]},
    {"name": "Sunday", "short": "S", "enabled": true, "exercises": <String>[]},
  ];

  final Map<DateTime, List<Exercise>> _extraExercises = {};

  int _selectedIndex = 0;

  List<Map<String, dynamic>> get days => _days;
  int get selectedIndex => _selectedIndex;

  void toggleDay(int index, bool value) {
    _days[index]['enabled'] = value;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Map<String, dynamic> get today {
    final todayIndex = DateTime.now().weekday - 1;
    return _days[todayIndex];
  }

  // ============ EXTRA EXERCISES (DATE-SPECIFIC) ============

  // Add exercise for a specific date
  void addExerciseForDate(DateTime date, String exerciseName, int numberOfSets) {
    if (exerciseName.trim().isEmpty) return;

    final key = DateTime(date.year, date.month, date.day);
    if (!_extraExercises.containsKey(key)) {
      _extraExercises[key] = [];
    }

    // Create exercise with empty sets
    List<ExerciseSet> sets = [];
    for (int i = 1; i <= numberOfSets; i++) {
      sets.add(ExerciseSet(setNumber: i));
    }

    _extraExercises[key]!.add(Exercise(name: exerciseName.trim(), sets: sets));
    notifyListeners();
  }

  // Get exercises for a specific date
  List<Exercise> getExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _extraExercises[key] ?? [];
  }

  // Update a specific set for an exercise
  void updateExerciseSet(DateTime date, int exerciseIndex, int setIndex, String weight, String reps) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        exerciseIndex >= 0 &&
        exerciseIndex < _extraExercises[key]!.length) {

      Exercise exercise = _extraExercises[key]![exerciseIndex];
      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        exercise.sets[setIndex].weight = weight;
        exercise.sets[setIndex].reps = reps;
        notifyListeners();
      }
    }
  }

  // Add a new set to an exercise
  void addSetToExercise(DateTime date, int exerciseIndex) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        exerciseIndex >= 0 &&
        exerciseIndex < _extraExercises[key]!.length) {

      Exercise exercise = _extraExercises[key]![exerciseIndex];
      int newSetNumber = exercise.sets.length + 1;
      exercise.sets.add(ExerciseSet(setNumber: newSetNumber));
      notifyListeners();
    }
  }

  // Remove the last set from an exercise
  void removeSetFromExercise(DateTime date, int exerciseIndex) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        exerciseIndex >= 0 &&
        exerciseIndex < _extraExercises[key]!.length) {

      Exercise exercise = _extraExercises[key]![exerciseIndex];
      if (exercise.sets.isNotEmpty) {
        exercise.sets.removeLast();
        notifyListeners();
      }
    }
  }

  // Remove exercise from a specific date by index
  void removeExerciseForDate(DateTime date, int index) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        index >= 0 &&
        index < _extraExercises[key]!.length) {
      _extraExercises[key]!.removeAt(index);

      if (_extraExercises[key]!.isEmpty) {
        _extraExercises.remove(key);
      }

      notifyListeners();
    }
  }

  // Clear all exercises for a specific date
  void clearExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    _extraExercises.remove(key);
    notifyListeners();
  }

  // ============ BACKWARD COMPATIBILITY FOR OLD FORMAT ============

  // For home screen display (simple list)
  List<String> getExercisesOfDate(DateTime date) {
    final exercises = getExercisesForDate(date);
    return exercises.map((e) {
      int completedSets = e.sets.where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty).length;
      return "${e.name} (${completedSets}/${e.sets.length} sets)";
    }).toList();
  }

  // ============ REGULAR DAY EXERCISES ============

  void addExerciseToDay(String dayName, String exerciseName) {
    if (exerciseName.trim().isEmpty) return;

    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<String>;
    exercises.add(exerciseName.trim());
    notifyListeners();
  }

  List<String> getExercisesOfDay(String dayName) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    return List<String>.from(day['exercises'] as List<String>);
  }

  bool isDayEnabled(String dayName) {
    try {
      final day = _days.firstWhere((d) => d['name'] == dayName);
      return day['enabled'] as bool;
    } catch (e) {
      return false;
    }
  }
}