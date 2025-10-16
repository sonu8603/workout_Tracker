import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_logic.dart';




class RegularExerciseScreen extends StatelessWidget {
  final String dayName;

  const RegularExerciseScreen({super.key, required this.dayName});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final exercises = exerciseProvider.getExercisesForDay(dayName);

    return Scaffold(
      appBar: AppBar(
        title: Text("$dayName Exercises"),
        backgroundColor: Colors.deepPurple,
      ),
      body: exercises.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No exercises added for $dayName",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap + to add an exercise",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return _ExerciseCard(
            exercise: exercises[index],
            exerciseIndex: index,
            dayName: dayName,
            onDelete: () => _deleteExercise(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController setsController = TextEditingController(text: "3");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day subtitle
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Exercise Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                    hintText: "e.g., Bench Press",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Number of Sets
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: "Number of Sets",
                    hintText: "3",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty && setsController.text.isNotEmpty) {
                  final exerciseProvider =
                  Provider.of<ExerciseProvider>(context, listen: false);

                  int numberOfSets = int.tryParse(setsController.text) ?? 3;
                  exerciseProvider.addExerciseToDay(dayName, nameController.text.trim(), numberOfSets);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Exercise added successfully"),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Exercise"),
          content: const Text("Are you sure you want to delete this exercise?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final exerciseProvider =
                Provider.of<ExerciseProvider>(context, listen: false);
                exerciseProvider.removeDayExercise(dayName, index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

// Individual Exercise Card Widget
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final String dayName;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.dayName,
    required this.onDelete,
  });

  void _addSet(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.addSetToDayExercise(dayName, exerciseIndex);
  }

  void _removeSet(BuildContext context) {
    if (exercise.sets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exercise must have at least 1 set")),
      );
      return;
    }
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.removeSetFromDayExercise(dayName, exerciseIndex);
  }

  @override
  Widget build(BuildContext context) {
    int completedSets = exercise.sets.where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.deepPurple.withOpacity(0.3), width: 2),
      ),
      elevation: 3,
      child: Column(
        children: [
          // Exercise Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$completedSets/${exercise.sets.length} sets completed",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Add/Remove Set Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _removeSet(context),
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text("Remove Set"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _addSet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add Set"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sets List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    const SizedBox(width: 60, child: Text("Set", style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(child: Text("Weight (kg)", style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("Reps", style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 40),
                  ],
                ),
                const Divider(height: 24),

                // Set Rows
                ...exercise.sets.asMap().entries.map((entry) {
                  return RegularSetRow(
                    set: entry.value,
                    exerciseIndex: exerciseIndex,
                    setIndex: entry.key,
                    dayName: dayName,
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
