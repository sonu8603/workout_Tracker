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
}