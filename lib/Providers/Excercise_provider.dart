import 'package:flutter/material.dart';

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

  final Map<DateTime, List<String>> _extraExercises = {};

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
  void addExerciseForDate(DateTime date, String exerciseName) {
    if (exerciseName.trim().isEmpty) return;

    final key = DateTime(date.year, date.month, date.day); // normalize
    if (!_extraExercises.containsKey(key)) {
      _extraExercises[key] = [];
    }
    _extraExercises[key]!.add(exerciseName.trim());
    notifyListeners();
  }

  // Get exercises for a specific date
  List<String> getExercisesOfDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _extraExercises[key] ?? [];
  }

  // Remove exercise from a specific date by index
  void removeExerciseForDate(DateTime date, int index) {
    final key = DateTime(date.year, date.month, date.day);
    if (_extraExercises.containsKey(key) &&
        index >= 0 &&
        index < _extraExercises[key]!.length) {
      _extraExercises[key]!.removeAt(index);

      // Clean up empty date entries
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

  // ============ REGULAR DAY EXERCISES ============

  // Add exercise to a day
  void addExerciseToDay(String dayName, String exerciseName) {
    if (exerciseName.trim().isEmpty) return;

    final day = _days.firstWhere((d) => d['name'] == dayName);
    final exercises = day['exercises'] as List<String>;
    exercises.add(exerciseName.trim());
    notifyListeners();
  }

  // Get exercises of a specific day
  List<String> getExercisesOfDay(String dayName) {
    final day = _days.firstWhere((d) => d['name'] == dayName);
    return List<String>.from(day['exercises'] as List<String>);
  }

  // Check if day is enabled
  bool isDayEnabled(String dayName) {
    try {
      final day = _days.firstWhere((d) => d['name'] == dayName);
      return day['enabled'] as bool;
    } catch (e) {
      return false; // return false if day not found
    }
  }
}