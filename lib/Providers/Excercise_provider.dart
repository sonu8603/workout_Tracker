import 'package:flutter/material.dart';

import 'package:workout_tracker/models/individual_set.dart';
import 'package:workout_tracker/models/individual_exercise_model.dart';







class ExerciseProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _days = [
    {
      "name": "Monday",
      "short": "M",
      "enabled": true,
      "exercises": <Exercise>[]
    },
    {
      "name": "Tuesday",
      "short": "T",
      "enabled": true,
      "exercises": <Exercise>[]
    },
    {
      "name": "Wednesday",
      "short": "W",
      "enabled": true,
      "exercises": <Exercise>[]
    },
    {
      "name": "Thursday",
      "short": "Th",
      "enabled": true,
      "exercises": <Exercise>[]
    },
    {
      "name": "Friday",
      "short": "F",
      "enabled": true,
      "exercises": <Exercise>[]
    },
    {
      "name": "Saturday",
      "short": "Sa",
      "enabled": true,
      "exercises": <Exercise>[]
    },
    {
      "name": "Sunday",
      "short": "S",
      "enabled": true,
      "exercises": <Exercise>[]
    },
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
    final todayIndex = DateTime
        .now()
        .weekday - 1;
    return _days[todayIndex];
  }

  // ================= EXTRA EXERCISES =================

  void addExerciseForDate(DateTime date, String exerciseName,
      int numberOfSets) {
    if (exerciseName
        .trim()
        .isEmpty) return;
    final key = DateTime(date.year, date.month, date.day);

    if (!_extraExercises.containsKey(key)) _extraExercises[key] = [];

    final sets = List<ExerciseSet>.generate(
        numberOfSets, (i) => ExerciseSet(setNumber: i + 1));
    _extraExercises[key]!.add(
        Exercise(name: exerciseName.trim(), sets: sets, date: key));

    notifyListeners();
  }

  List<Exercise> getExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _extraExercises[key] ?? [];
  }

  void updateExerciseSet(DateTime date, int exerciseIndex, int setIndex,
      String weight, String reps) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        exerciseIndex >= 0 &&
        exerciseIndex < _extraExercises[key]!.length) {
      final exercise = _extraExercises[key]![exerciseIndex];
      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        exercise.sets[setIndex].weight = weight;
        exercise.sets[setIndex].reps = reps;
        notifyListeners();
      }
    }
  }

  void addSetToExercise(DateTime date, int exerciseIndex) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        exerciseIndex >= 0 &&
        exerciseIndex < _extraExercises[key]!.length) {
      final exercise = _extraExercises[key]![exerciseIndex];
      exercise.sets.add(ExerciseSet(setNumber: exercise.sets.length + 1));
      notifyListeners();
    }
  }

  void removeSetFromExercise(DateTime date, int exerciseIndex) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        exerciseIndex >= 0 &&
        exerciseIndex < _extraExercises[key]!.length) {
      final exercise = _extraExercises[key]![exerciseIndex];
      if (exercise.sets.isNotEmpty) exercise.sets.removeLast();
      notifyListeners();
    }
  }

  void removeExerciseForDate(DateTime date, int index) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        index >= 0 &&
        index < _extraExercises[key]!.length) {
      _extraExercises[key]!.removeAt(index);
      if (_extraExercises[key]!.isEmpty) _extraExercises.remove(key);
      notifyListeners();
    }
  }

  void clearExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    _extraExercises.remove(key);
    notifyListeners();
  }

  // ================= WEEKLY EXERCISES =================

  void addExerciseToDay(String dayName, String exerciseName, int numberOfSets,
      DateTime date) {
    if (exerciseName
        .trim()
        .isEmpty) return;

    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<Exercise>;

    final sets = List<ExerciseSet>.generate(
        numberOfSets, (i) => ExerciseSet(setNumber: i + 1));
    exercises.add(Exercise(name: exerciseName.trim(), sets: sets, date: date));

    notifyListeners();
  }

  List<Exercise> getExercisesForDay(String dayName) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    return List<Exercise>.from(day['exercises'] as List<Exercise>);
  }

  void removeDayExercise(String dayName, int index) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<Exercise>;
    if (index >= 0 && index < exercises.length) {
      exercises.removeAt(index);
      notifyListeners();
    }
  }

  void addSetToDayExercise(String dayName, int exerciseIndex) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<Exercise>;
    if (exerciseIndex >= 0 && exerciseIndex < exercises.length) {
      exercises[exerciseIndex].sets.add(
          ExerciseSet(setNumber: exercises[exerciseIndex].sets.length + 1));
      notifyListeners();
    }
  }

  void removeSetFromDayExercise(String dayName, int exerciseIndex) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<Exercise>;
    if (exerciseIndex >= 0 && exerciseIndex < exercises.length) {
      if (exercises[exerciseIndex].sets.isNotEmpty) exercises[exerciseIndex]
          .sets.removeLast();
      notifyListeners();
    }
  }

  void updateDayExerciseSet(String dayName, int exerciseIndex, int setIndex,
      String weight, String reps) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<Exercise>;
    if (exerciseIndex >= 0 && exerciseIndex < exercises.length) {
      if (setIndex >= 0 && setIndex < exercises[exerciseIndex].sets.length) {
        exercises[exerciseIndex].sets[setIndex].weight = weight;
        exercises[exerciseIndex].sets[setIndex].reps = reps;
        notifyListeners();
      }
    }
  }

  // ================= GET ALL EXERCISES BY DATE (FOR GRAPH) =================

  List<Exercise> getAllExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);

    // Extra exercises for the date
    final extra = _extraExercises[key] ?? [];

    // Weekly exercises performed on this date
    final weeklyExercises = <Exercise>[];
    for (var day in _days) {
      final exercises = (day['exercises'] as List<Exercise>);
      for (var ex in exercises) {
        if (ex.date.year == date.year &&
            ex.date.month == date.month &&
            ex.date.day == date.day) {
          weeklyExercises.add(ex);
        }
      }
    }

    // Merge both
    return [...weeklyExercises, ...extra];
  }
  // Return all extra exercise dates saved by user
  List<DateTime> getAllExtraExerciseDates() {
    return _extraExercises.keys.toList();
  }


  bool isDayEnabled(String dayName) {
    try {
      final day = _days.firstWhere((d) => d['name'] == dayName);
      return day['enabled'] as bool;
    } catch (e) {
      return false;
    }
  }

//
// // ================= DUMMY DATA FOR GRAPH TESTING =================
//
//   /// Generates dummy exercise data for multiple days
//   void generateDummyData() {
//     final today = DateTime.now();
//
//     // Example exercises
//     final exerciseNames = ["Push Ups", "Squats", "Bench Press"];
//
//     for (int i = 0; i < 12; i++) { // 12 days of data
//       final date = today.subtract(Duration(days: 12 - i));
//
//       for (var name in exerciseNames) {
//         // Create 3 sets per exercise with dummy weight and reps
//         final sets = List<ExerciseSet>.generate(3, (index) {
//           return ExerciseSet(
//             setNumber: index + 1,
//             weight: (5 + i + index).toString(), // increasing dummy weight
//             reps: (10 + i + index).toString(), // increasing dummy reps
//           );
//         });
//
//         // Add as extra exercise
//         addExerciseForDate(date, name, sets.length);
//
//         // Update the sets for the last added exercise
//         final exercises = getExercisesForDate(date);
//         exercises.last.sets = sets;
//       }
//     }
//
//     notifyListeners();
//   }
}
