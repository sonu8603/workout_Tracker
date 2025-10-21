import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/Excercise_provider.dart';

class ExerciseListView extends StatelessWidget {
  final Function(String) onExerciseSelected;

  const ExerciseListView({super.key, required this.onExerciseSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);

    // Collect all unique exercise names across all dates
    Set<String> allExercises = {};

    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30)); // last 30 days
    for (int i = 0; i <= 30; i++) {
      final date = startDate.add(Duration(days: i));
      final exercises = provider.getAllExercisesForDate(date);
      for (var ex in exercises) {
        allExercises.add(ex.name);
      }
    }

    final exerciseList = allExercises.toList();

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
