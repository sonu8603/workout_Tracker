import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/Excercise_provider.dart';
class GraphExerciseListView extends StatelessWidget {
  final Function(String) onExerciseSelected;

  const GraphExerciseListView({super.key, required this.onExerciseSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);

    final Set<String> allExercises = {};

    // Weekly exercises
    for (var day in provider.days) {
      for (var ex in day.exercises) {
        if (ex.date.year == 2000) continue;
        if (ex.sets.any((s) => s.weight.isNotEmpty || s.reps.isNotEmpty)) {
          allExercises.add(ex.name);
        }
      }
    }

    // Extra exercises
    final extraDates = provider.getAllExtraExerciseDates();
    for (var date in extraDates) {
      for (var ex in provider.getAllExercisesForDate(date)) {
        if (ex.sets.any((s) => s.weight.isNotEmpty || s.reps.isNotEmpty)) {
          allExercises.add(ex.name);
        }
      }
    }

    // Workout logs
    final logDates = provider.getAllWorkoutLogDates();
    for (var date in logDates) {
      final logs = provider.getWorkoutLogsForDate(date);
      for (var log in logs) {
        for (var ex in log.exercises) {
          allExercises.add(ex.name);
        }
      }
    }

    final exerciseList = allExercises.toList()..sort();

    if (exerciseList.isEmpty) {
      return const Center(child: Text("No saved exercises yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: exerciseList.length,
      itemBuilder: (context, index) {
        final name = exerciseList[index];
        return ListTile(
          leading: const Icon(Icons.fitness_center),
          title: Text(name),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => onExerciseSelected(name),
        );
      },
    );
  }
}