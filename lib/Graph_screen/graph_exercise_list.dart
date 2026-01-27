import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/Excercise_provider.dart';

class GraphExerciseListView extends StatelessWidget {
  final Function(String) onExerciseSelected;

  const GraphExerciseListView({super.key, required this.onExerciseSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);

    // ✅ Collect all unique exercise names from all dates (no 30-day limit)
    Set<String> allExercises = {};

    // 1️⃣ Add exercises from weekly planned days (_days)
    for (var day in provider.days) {
      final exercises = day.exercises;
      for (var ex in exercises) {
        // ✅ NEW: Skip template exercises (year 2000)
        if (ex.date.year == 2000) continue;

        allExercises.add(ex.name);
      }
    }

    // 2️⃣ Add exercises from all extra recorded dates (_extraExercises)
    final allDates = provider.getAllExtraExerciseDates();
    for (var date in allDates) {
      final exercises = provider.getAllExercisesForDate(date);
      for (var ex in exercises) {
        allExercises.add(ex.name);
      }
    }

    final exerciseList = allExercises.toList()..sort();

    // ✅ If no exercises exist
    if (exerciseList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'No exercises found!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ List of all unique exercises
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple, width: 2),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: exerciseList.length,
        itemBuilder: (context, index) {
          final name = exerciseList[index];
          return ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
            title: Text(name),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => onExerciseSelected(name),
          );
        },
      ),
    );
  }
}