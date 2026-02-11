import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:workout_tracker/models/individual_set.dart';
import 'package:workout_tracker/models/individual_exercise_model.dart';
import '../models/workout_day.dart';

import 'package:workout_tracker/models/workout_log_model.dart';

class HiveConfig {
  static const String workoutDaysBox = 'workout_days';
  static const String extraExercisesBox = 'extra_exercises';
  static const String settingsBox = 'settings';
  static const String workoutLogsBox = 'workout_logs';

}

class ExerciseProvider with ChangeNotifier {
  // Version control for data migration
  static const int currentVersion = 1;

  late Box<WorkoutDay> _daysBox;
  late Box _extraBox;
  late Box _settingsBox;
  late Box<WorkoutLog> _workoutLogsBox;

  List<WorkoutDay> _days = [];
  Map<DateTime, List<Exercise>> _extraExercises = {};
  int _selectedIndex = 0;
  bool _isInitialized = false;
  String? _lastError;

  // Getters
  List<WorkoutDay> get days => _days;
  int get selectedIndex => _selectedIndex;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  ExerciseProvider() {
    _initializeAsync();
  }

  // ================= INITIALIZATION =================

  Future<void> _initializeAsync() async {
    try {
      //  DEBUG: Add artificial delay to see loading screen
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 2));
        debugPrint('⏰ Debug delay complete');
      }

      await _loadData();
      await _checkAndMigrate();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to initialize: $e';
      if (kDebugMode) debugPrint('ExerciseProvider initialization error: $e');
      _initializeDefaultState();
      _isInitialized = true; // Mark as initialized even on error
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    try {
      // ✅ Use constants for box names - boxes already open from main.dart
      _daysBox = Hive.box<WorkoutDay>(HiveConfig.workoutDaysBox);
      _extraBox = Hive.box(HiveConfig.extraExercisesBox);
      _settingsBox = Hive.box(HiveConfig.settingsBox);
      _workoutLogsBox = Hive.box<WorkoutLog>(HiveConfig.workoutLogsBox);
      if (kDebugMode) debugPrint(' Workout logs: ${_workoutLogsBox.length}');

      if (kDebugMode) {
        debugPrint('📦 Loading data from Hive...');
        debugPrint('Days box length: ${_daysBox.length}');
        debugPrint('Extra box length: ${_extraBox.length}');
      }

      // Load workout days or create default
      if (_daysBox.isEmpty) {
        if (kDebugMode) debugPrint('⚠️ Days box is empty, initializing defaults...');
        _initializeDefaultState();
        await _saveDays();
        if (kDebugMode) debugPrint('✅ Default days saved');
      } else {
        _days = _daysBox.values.toList();
        if (kDebugMode) debugPrint('✅ Loaded ${_days.length} days from Hive');

        // Debug: Print exercises in each day
        if (kDebugMode) {
          for (var day in _days) {
            debugPrint('   ${day.name}: ${day.exercises.length} exercises');
          }
        }

        // Validate loaded data
        if (_days.length != 7) {
          if (kDebugMode) debugPrint('⚠️ Invalid number of days (${_days.length}). Reinitializing...');
          _initializeDefaultState();
          await _saveDays();
        }
      }

      // Load extra exercises with error handling
      _extraExercises.clear();
      for (var key in _extraBox.keys) {
        try {
          final dateStr = key as String;
          final date = DateTime.parse(dateStr);
          final rawList = _extraBox.get(key);

          if (rawList is List) {
            final exercisesList = rawList.cast<Exercise>();
            _extraExercises[date] = exercisesList;
            if (kDebugMode) debugPrint('  Loaded ${exercisesList.length} exercises for $dateStr');
          }
        } catch (e) {
          if (kDebugMode) debugPrint(' Error loading exercises for key $key: $e');
          continue;
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Total extra exercise dates: ${_extraExercises.length}');
        debugPrint('✅ Data loading complete!');
      }
      _lastError = null;
    } catch (e) {
      _lastError = 'Error loading data: $e';
      if (kDebugMode) debugPrint('❌ Critical error in _loadData: $e');
      _initializeDefaultState();
      rethrow;
    }
  }

  void _initializeDefaultState() {
    _days = [
      WorkoutDay(name: "Monday", short: "M"),
      WorkoutDay(name: "Tuesday", short: "T"),
      WorkoutDay(name: "Wednesday", short: "W"),
      WorkoutDay(name: "Thursday", short: "Th"),
      WorkoutDay(name: "Friday", short: "F"),
      WorkoutDay(name: "Saturday", short: "Sa"),
      WorkoutDay(name: "Sunday", short: "S"),
    ];
    _extraExercises = {};
    _selectedIndex = 0;
  }

  // ================= DATA MIGRATION =================

  Future<void> _checkAndMigrate() async {
    try {
      final savedVersion = _settingsBox.get('version', defaultValue: 0);

      if (savedVersion < currentVersion) {
        await _migrateData(savedVersion, currentVersion);
        await _settingsBox.put('version', currentVersion);
      }
    } catch (e) {
      print('Migration error: $e');
    }
  }

  Future<void> _migrateData(int from, int to) async {
    print('Migrating data from version $from to $to');

    // Add migration logic here for future versions
    if (from == 0 && to == 1) {
      // Example: Add new fields, transform data, etc.
      print('Migration v0 -> v1 completed');
    }
  }

  // ================= SAVE OPERATIONS =================

  Future<bool> _saveDays() async {
    try {
      await _daysBox.clear();
      for (int i = 0; i < _days.length; i++) {
        await _daysBox.put(i, _days[i]);
      }
      return true;
    } catch (e) {
      _lastError = 'Error saving days: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> _saveExtraExercises(DateTime date) async {
    try {
      final key = _dateToString(date);
      if (_extraExercises[date]?.isEmpty ?? true) {
        await _extraBox.delete(key);
      } else {
        await _extraBox.put(key, _extraExercises[date]);
      }
      return true;
    } catch (e) {
      _lastError = 'Error saving exercises: $e';
      print(_lastError);
      return false;
    }
  }

  String _dateToString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // ================= VALIDATION =================

  bool _validateExerciseName(String name) {
    return name.trim().isNotEmpty && name.trim().length <= 100;
  }

  bool _validateNumberOfSets(int sets) {
    return sets > 0 && sets <= 10;
  }

  bool _validateWeight(String weight) {
    if (weight.isEmpty) return true; // Empty is allowed
    final value = double.tryParse(weight);
    return value != null && value >= 0 && value <= 10000;
  }

  bool _validateReps(String reps) {
    if (reps.isEmpty) return true; // Empty is allowed
    final value = int.tryParse(reps);
    return value != null && value >= 0 && value <= 1000;
  }

  // ================= PUBLIC METHODS =================

  void toggleDay(int index, bool value) {
    if (index < 0 || index >= _days.length) {
      _lastError = 'Invalid day index';
      return;
    }

    _days[index].enabled = value;
    _saveDays();
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    if (index < 0 || index >= _days.length) {
      _lastError = 'Invalid day index';
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  WorkoutDay get today {
    final todayIndex = DateTime.now().weekday - 1;
    return _days[todayIndex];
  }

  // ================= EXTRA EXERCISES =================

  Future<bool> addExerciseForDate(DateTime date, String exerciseName, int numberOfSets) async {
    try {
      // Validation
      if (!_validateExerciseName(exerciseName)) {
        _lastError = 'Invalid exercise name (1-100 characters)';
        return false;
      }

      if (!_validateNumberOfSets(numberOfSets)) {
        _lastError = 'Number of sets must be between 1 and 20';
        return false;
      }

      final key = DateTime(date.year, date.month, date.day);
      if (!_extraExercises.containsKey(key)) {
        _extraExercises[key] = [];
      }

      final sets = List<ExerciseSet>.generate(
          numberOfSets, (i) => ExerciseSet(setNumber: i + 1));

      _extraExercises[key]!.add(Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: exerciseName.trim(),
          sets: sets,
          date: key,
          isExtra: true)); // Extra exercise

      final success = await _saveExtraExercises(key);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error adding exercise: $e';
      print(_lastError);
      return false;
    }
  }

  List<Exercise> getExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _extraExercises[key] ?? [];
  }

  Future<bool> updateExerciseSet(DateTime date, int exerciseIndex, int setIndex,
      String weight, String reps) async {
    try {
      // Validation
      if (!_validateWeight(weight)) {
        _lastError = 'Invalid weight value';
        return false;
      }

      if (!_validateReps(reps)) {
        _lastError = 'Invalid reps value';
        return false;
      }

      final key = DateTime(date.year, date.month, date.day);
      if (!_extraExercises.containsKey(key) ||
          exerciseIndex < 0 ||
          exerciseIndex >= _extraExercises[key]!.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      final exercise = _extraExercises[key]![exerciseIndex];
      if (setIndex < 0 || setIndex >= exercise.sets.length) {
        _lastError = 'Invalid set index';
        return false;
      }

      exercise.sets[setIndex].weight = weight;
      exercise.sets[setIndex].reps = reps;

      final success = await _saveExtraExercises(key);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error updating set: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> addSetToExercise(DateTime date, int exerciseIndex) async {
    try {
      final key = DateTime(date.year, date.month, date.day);
      if (!_extraExercises.containsKey(key) ||
          exerciseIndex < 0 ||
          exerciseIndex >= _extraExercises[key]!.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      final exercise = _extraExercises[key]![exerciseIndex];

      if (exercise.sets.length >= 20) {
        _lastError = 'Maximum 20 sets allowed';
        return false;
      }

      exercise.sets.add(ExerciseSet(setNumber: exercise.sets.length + 1));

      final success = await _saveExtraExercises(key);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error adding set: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> removeSetFromExercise(DateTime date, int exerciseIndex) async {
    try {
      final key = DateTime(date.year, date.month, date.day);
      if (!_extraExercises.containsKey(key) ||
          exerciseIndex < 0 ||
          exerciseIndex >= _extraExercises[key]!.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      final exercise = _extraExercises[key]![exerciseIndex];
      if (exercise.sets.isEmpty) {
        _lastError = 'No sets to remove';
        return false;
      }

      exercise.sets.removeLast();

      final success = await _saveExtraExercises(key);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error removing set: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> removeExerciseForDate(DateTime date, int index) async {
    try {
      final key = DateTime(date.year, date.month, date.day);
      if (!_extraExercises.containsKey(key) ||
          index < 0 ||
          index >= _extraExercises[key]!.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      _extraExercises[key]!.removeAt(index);
      if (_extraExercises[key]!.isEmpty) {
        _extraExercises.remove(key);
      }

      final success = await _saveExtraExercises(key);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error removing exercise: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> clearExercisesForDate(DateTime date) async {
    try {
      final key = DateTime(date.year, date.month, date.day);
      _extraExercises.remove(key);

      final success = await _saveExtraExercises(key);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error clearing exercises: $e';
      print(_lastError);
      return false;
    }
  }

  // ================= WEEKLY EXERCISES =================

  Future<bool> addExerciseToDay(String dayName, String exerciseName,
      int numberOfSets, DateTime date) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 addExerciseToDay called:');
        debugPrint('   dayName: "$dayName"');
        debugPrint('   exerciseName: "$exerciseName"');
        debugPrint('   numberOfSets: $numberOfSets');
        debugPrint('   date: $date');
      }

      // Validation
      if (!_validateExerciseName(exerciseName)) {
        _lastError = 'Invalid exercise name (1-100 characters)';
        if (kDebugMode) debugPrint('❌ $_lastError');
        return false;
      }

      if (!_validateNumberOfSets(numberOfSets)) {
        _lastError = 'Number of sets must be between 1 and 20';
        if (kDebugMode) debugPrint('❌ $_lastError');
        return false;
      }

      // Debug: Print all available days
      if (kDebugMode) {
        debugPrint('📋 Available days:');
        for (var d in _days) {
          debugPrint('   - "${d.name}" (${d.exercises.length} exercises)');
        }
      }

      // Find the day (case-insensitive)
      WorkoutDay? day;
      try {
        day = _days.firstWhere(
              (d) => d.name.toLowerCase() == dayName.toLowerCase(),
        );
        if (kDebugMode) debugPrint('✅ Day found: ${day.name}');
      } catch (e) {
        _lastError = 'Day not found: $dayName';
        if (kDebugMode) {
          debugPrint('❌ $_lastError');
          debugPrint('❌ Exception: $e');
        }
        return false;
      }

      final exercises = day.exercises;

      // Normalize date (remove time component)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (kDebugMode) debugPrint('📅 Normalized date: $normalizedDate');

      final sets = List<ExerciseSet>.generate(
          numberOfSets, (i) => ExerciseSet(setNumber: i + 1));

      final newExercise = Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: exerciseName.trim(),
          sets: sets,
          date: normalizedDate,
          isExtra: false); // Regular exercise

      exercises.add(newExercise);
      if (kDebugMode) debugPrint('✅ Exercise added to list. Total: ${exercises.length}');

      final success = await _saveDays();
      if (kDebugMode) debugPrint('💾 Save result: $success');

      if (success) {
        notifyListeners();
        if (kDebugMode) debugPrint('✅ notifyListeners called');
      }
      return success;
    } catch (e) {
      _lastError = 'Error adding exercise to day: $e';
      // if (kDebugMode) {
      //   debugPrint('❌ Exception in addExerciseToDay: $e');
      //   debugPrint('❌ Stack trace: ${StackTrace.current}');
      // }
      return false;
    }
  }

  List<Exercise> getExercisesForDay(String dayName) {
    try {
      final day = _days.firstWhere((d) => d.name == dayName);
      return day.exercises.where((ex) {
        return ex.date.year != 2000;
      }).toList();


    } catch (e) {
      _lastError = 'Day not found: $dayName';
      return [];
    }
  }

  Future<bool> removeDayExercise(String dayName, int index) async {
    try {
      final day = _days.firstWhere((d) => d.name == dayName);
      final exercises = day.exercises;

      if (index < 0 || index >= exercises.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      exercises.removeAt(index);

      final success = await _saveDays();
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error removing day exercise: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> addSetToDayExercise(String dayName, int exerciseIndex) async {
    try {
      final day = _days.firstWhere((d) => d.name == dayName);
      final exercises = day.exercises;

      if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      if (exercises[exerciseIndex].sets.length >= 20) {
        _lastError = 'Maximum 20 sets allowed';
        return false;
      }

      exercises[exerciseIndex].sets.add(
          ExerciseSet(setNumber: exercises[exerciseIndex].sets.length + 1));

      final success = await _saveDays();
      if (success) notifyListeners();
      return success;
    } catch (e) {
      _lastError = 'Error adding set to day exercise: $e';
      print(_lastError);
      return false;
    }
  }

  Future<bool> removeSetFromDayExercise(String dayName, int exerciseIndex) async {
    try {
      final day = _days.firstWhere((d) => d.name == dayName);
      final exercises = day.exercises;

      if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      if (exercises[exerciseIndex].sets.isEmpty) {
        _lastError = 'No sets to remove';
        return false;
      }

      exercises[exerciseIndex].sets.removeLast();

      final success = await _saveDays();
      if (success) notifyListeners();
      return success;
    } catch (e) {
      _lastError = 'Error removing set from day exercise: $e';
      print(_lastError);
      return false;
    }
  }


  Future<bool> updateExerciseName(String dayName, int exerciseIndex, String newName) async {
    try {
      // Validation
      if (!_validateExerciseName(newName)) {
        _lastError = 'Invalid exercise name (1-100 characters)';
        if (kDebugMode) debugPrint(' $_lastError');
        return false;
      }

      final day = _days.firstWhere(
            (d) => d.name.toLowerCase() == dayName.toLowerCase(),
      );

      final exercises = day.exercises;

      if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
        _lastError = 'Invalid exercise index';
        if (kDebugMode) debugPrint(' $_lastError');
        return false;
      }

      // Direct update - fast!
      exercises[exerciseIndex].name = newName.trim();

      if (kDebugMode) {
        debugPrint('✅ Updated exercise name to: $newName');
      }

      final success = await _saveDays();
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error updating exercise name: $e';
      if (kDebugMode) debugPrint(' $_lastError');
      return false;
    }
  }

  Future<bool> updateDayExerciseSet(String dayName, int exerciseIndex,
      int setIndex, String weight, String reps) async {
    try {
      // Validation
      if (!_validateWeight(weight)) {
        _lastError = 'Invalid weight value';
        return false;
      }

      if (!_validateReps(reps)) {
        _lastError = 'Invalid reps value';
        return false;
      }

      final day = _days.firstWhere((d) => d.name == dayName);
      final exercises = day.exercises;

      if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
        _lastError = 'Invalid exercise index';
        return false;
      }

      if (setIndex < 0 || setIndex >= exercises[exerciseIndex].sets.length) {
        _lastError = 'Invalid set index';
        return false;
      }

      exercises[exerciseIndex].sets[setIndex].weight = weight;
      exercises[exerciseIndex].sets[setIndex].reps = reps;

      final success = await _saveDays();
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error updating day exercise set: $e';
      print(_lastError);
      return false;
    }
  }

  // ================= GET ALL EXERCISES BY DATE =================

  List<Exercise> getAllExercisesForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final extra = _extraExercises[key] ?? [];

    final weeklyExercises = <Exercise>[];
    for (var day in _days) {
      final exercises = day.exercises;
      for (var ex in exercises) {

        if (ex.date.year == 2000) continue;

        if (ex.date.year == date.year &&
            ex.date.month == date.month &&
            ex.date.day == date.day) {
          weeklyExercises.add(ex);
        }
      }
    }

    return [...weeklyExercises, ...extra];
  }

  List<DateTime> getAllExtraExerciseDates() {
    return _extraExercises.keys.toList();
  }

  bool isDayEnabled(String dayName) {
    try {
      final day = _days.firstWhere((d) => d.name == dayName);
      return day.enabled;
    } catch (e) {
      return false;
    }
  }


  // ================= BACKUP & RESTORE =================

  Future<Map<String, dynamic>> exportData() async {
    try {
      final data = {
        'version': currentVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'days': _days.map((d) => {
          'name': d.name,
          'short': d.short,
          'enabled': d.enabled,
          'exercises': d.exercises.map((e) => {
            'name': e.name,
            'date': e.date.toIso8601String(),
            'id': e.id,
            'sets': e.sets.map((s) => {
              'setNumber': s.setNumber,
              'weight': s.weight,
              'reps': s.reps,
            }).toList(),
          }).toList(),
        }).toList(),
        'extraExercises': _extraExercises.map((key, value) => MapEntry(
          key.toIso8601String(),
          value.map((e) => {
            'name': e.name,
            'date': e.date.toIso8601String(),
            'id': e.id,
            'sets': e.sets.map((s) => {
              'setNumber': s.setNumber,
              'weight': s.weight,
              'reps': s.reps,
            }).toList(),
          }).toList(),
        )),
      };

      return data;
    } catch (e) {
      _lastError = 'Error exporting data: $e';
      print(_lastError);
      return {};
    }
  }

  Future<bool> clearAllData() async {
    try {
      await _daysBox.clear();
      await _extraBox.clear();
      _initializeDefaultState();
      await _saveDays();
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Error clearing data: $e';
      print(_lastError);
      return false;
    }
  }

  // ================= UTILITY =================

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    int totalExercises = 0;
    int totalSets = 0;
    int totalDaysWithData = 0;

    // Count from weekly exercises
    for (var day in _days) {
      if (day.exercises.isNotEmpty) {
        totalDaysWithData++;
      }
      totalExercises += day.exercises.length;
      for (var ex in day.exercises) {
        totalSets += ex.sets.length;
      }
    }

    // Count from extra exercises
    totalDaysWithData += _extraExercises.length;
    for (var exercises in _extraExercises.values) {
      totalExercises += exercises.length;
      for (var ex in exercises) {
        totalSets += ex.sets.length;
      }
    }

    return {
      'totalExercises': totalExercises,
      'totalSets': totalSets,
      'totalDaysWithData': totalDaysWithData,
      'uniqueExerciseNames': _getAllUniqueExerciseNames().length,
    };
  }

  Set<String> _getAllUniqueExerciseNames() {
    final names = <String>{};

    for (var day in _days) {
      for (var ex in day.exercises) {
        names.add(ex.name);
      }
    }

    for (var exercises in _extraExercises.values) {
      for (var ex in exercises) {
        names.add(ex.name);
      }
    }

    return names;
  }

  // ================= WORKOUT LOGGING METHODS =================

  Future<bool> saveWorkoutLog({
    required DateTime date,
    required String dayName,
    required List<Exercise> exercises,
    String? notes,
  }) async {
    try {
      final todayKey = _dateToString(date);

      //  Get existing logs of today
      final existingLogs = _workoutLogsBox.values
          .where((log) => _dateToString(log.date) == todayKey)
          .toList();

      //  Collect already saved exercise IDs
      final alreadySavedIds = <String>{};
      for (var log in existingLogs) {
        for (var ex in log.exercises) {
          alreadySavedIds.add(ex.exerciseId);
        }
      }

      final completedExercises = <CompletedExercise>[];

      for (var ex in exercises) {
        //  DEEP COPY of completed sets
        final completedSets = ex.sets
            .where((s) => _isSetCompleted(s))
            .map((s) => ExerciseSet(
          setNumber: s.setNumber,
          weight: s.weight,
          reps: s.reps,
        ))
            .toList();

        //  Skip if no completed sets or already saved
        if (completedSets.isEmpty || alreadySavedIds.contains(ex.id)) continue;

        completedExercises.add(
          CompletedExercise(
            exerciseId: ex.id,
            name: ex.name,
            sets: completedSets,
            completedAt: DateTime.now(),
          ),
        );
      }

      if (completedExercises.isEmpty) {
        _lastError = 'No new completed exercises to save';
        return false;
      }

      final now = DateTime.now();
      final key =
          '${todayKey}_${now.hour}${now.minute}${now.second}${now.millisecond}';

      final log = WorkoutLog(
        date: DateTime(date.year, date.month, date.day),
        dayName: dayName,
        exercises: completedExercises,
        startedAt: now,
        completedAt: now,
        notes: notes,
      );

      await _workoutLogsBox.put(key, log);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Error saving workout log: $e';
      return false;
    }
  }



  bool _isSetCompleted(ExerciseSet set) {
    if (set.weight.isEmpty || set.reps.isEmpty) return false;
    final weight = double.tryParse(set.weight);
    final reps = int.tryParse(set.reps);
    return weight != null && reps != null && weight > 0 && reps > 0;
  }

  List<WorkoutLog> getWorkoutLogsForDate(DateTime date) {
    final dateStr = _dateToString(date);
    return _workoutLogsBox.values
        .where((log) => _dateToString(log.date) == dateStr)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  List<DateTime> getAllWorkoutLogDates() {
    final dates = <DateTime>{};

    for (var log in _workoutLogsBox.values) {
      dates.add(DateTime(log.date.year, log.date.month, log.date.day));
    }

    return dates.toList()..sort((a, b) => b.compareTo(a));
  }

  List<CompletedExercise> getExerciseHistory(String exerciseId) {
    final history = <CompletedExercise>[];

    for (var log in _workoutLogsBox.values) {
      for (var exercise in log.exercises) {
        if (exercise.exerciseId == exerciseId) {
          history.add(exercise);
        }
      }
    }

    history.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return history;
  }

  int get totalWorkoutLogs => _workoutLogsBox.length;

  int getWorkoutStreak() {
    final dates = getAllWorkoutLogDates();
    if (dates.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();
    final today = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (var date in dates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final difference = today.difference(normalizedDate).inDays;

      if (difference == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
       //  reset exercises section

  Future<bool> resetDayExercises(String dayName) async {
    try {
      final day = _days.firstWhere((d) => d.name == dayName);

      for (var exercise in day.exercises) {
        for (var set in exercise.sets) {
          set.weight = '';
          set.reps = '';
        }
      }

      final success = await _saveDays();
      if (success) {
        if (kDebugMode) debugPrint('✅ Reset exercises for $dayName');
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error resetting exercises: $e';
      if (kDebugMode) debugPrint(' $_lastError');
      return false;
    }
  }

  Future<bool> resetExtraExercises(DateTime date) async {
    try {
      final key = DateTime(date.year, date.month, date.day);
      final exercises = _extraExercises[key];

      if (exercises == null) return true;

      for (var exercise in exercises) {
        for (var set in exercise.sets) {
          set.weight = '';
          set.reps = '';
        }
      }

      final success = await _saveExtraExercises(key);
      if (success) {
        if (kDebugMode) debugPrint('✅ Reset extra exercises for $key');
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = 'Error resetting extra exercises: $e';
      if (kDebugMode) debugPrint(' $_lastError');
      return false;
    }
  }



  void dispose() {
    // Don't close boxes here - they might be used elsewhere
    super.dispose();
  }
}