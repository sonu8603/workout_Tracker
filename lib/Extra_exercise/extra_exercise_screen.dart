import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';

import '../models/individual_exercise_model.dart';
import 'extra_exercise_logic.dart';

class ExtraExerciseScreen extends StatelessWidget {
  final DateTime date;
  final int? exerciseIndex;

  const ExtraExerciseScreen({
    super.key,
    required this.date,
    this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final allExercises = exerciseProvider.getExercisesForDate(date);

    final List<Exercise> exercisesToShow;
    if (exerciseIndex != null && exerciseIndex! < allExercises.length) {
      exercisesToShow = [allExercises[exerciseIndex!]];
    } else {
      exercisesToShow = allExercises;
    }

    final hasCompletedSets = exercisesToShow.any(
          (exercise) => exercise.sets.any((set) => _isSetCompleted(set)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 23),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          exerciseIndex != null && exercisesToShow.isNotEmpty
              ? exercisesToShow[0].name
              : "Extra Exercises",
        ),
        backgroundColor: Colors.orange,
        actions: [
          if (exerciseIndex == null && hasCompletedSets)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => _finishWorkout(context),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Finish',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: exercisesToShow.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No extra exercises added",
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
        itemCount: exercisesToShow.length,
        itemBuilder: (context, index) {
          final actualIndex = exerciseIndex ?? index;
          return ExpandableExtraExerciseCard(
            exercise: exercisesToShow[index],
            exerciseIndex: actualIndex,
            date: date,
            onDelete: () => _deleteExercise(context, actualIndex),
          );
        },
      ),
      floatingActionButton: exerciseIndex == null
          ? FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  // ================= HELPERS =================

  bool _isSetCompleted(set) {
    if (set.weight.isEmpty || set.reps.isEmpty) return false;
    final weight = double.tryParse(set.weight);
    final reps = int.tryParse(set.reps);
    return weight != null && reps != null && weight > 0 && reps > 0;
  }

  // ================= FINISH WORKOUT =================

  void _finishWorkout(BuildContext context) async {
    final provider = Provider.of<ExerciseProvider>(context, listen: false);
    final allExercises = provider.getExercisesForDate(date);

    final completedCount = allExercises
        .where((ex) => ex.sets.any((s) => _isSetCompleted(s)))
        .length;

    if (completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete at least one set to finish workout!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Finish Workout?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save $completedCount completed ${completedCount == 1 ? 'exercise' : 'exercises'} to history?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Exercises will be reset for next workout',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.save),
            label: const Text('Finish & Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.saveWorkoutLog(
      date: DateTime.now(),
      dayName: "Extra Workout",
      exercises: allExercises,
    );

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.lastError ?? 'Failed to save workout'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    await provider.markExtraWorkoutCompleted(date);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              SizedBox(width: 12),
              Text('Workout saved! Great job!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  // ================= ADD EXERCISE =================

  void _showAddExerciseDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController setsController =
    TextEditingController(text: "3");

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
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                    hintText: "e.g., Push Ups",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
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
                if (nameController.text.trim().isNotEmpty &&
                    setsController.text.isNotEmpty) {
                  final exerciseProvider =
                  Provider.of<ExerciseProvider>(context, listen: false);
                  int numberOfSets =
                      int.tryParse(setsController.text) ?? 3;
                  exerciseProvider.addExerciseForDate(
                    date,
                    nameController.text.trim(),
                    numberOfSets,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Exercise added successfully"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300],
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // ================= DELETE EXERCISE =================

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
                exerciseProvider.removeExerciseForDate(date, index);
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



class ExpandableExtraExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final DateTime date;
  final VoidCallback onDelete;

  const ExpandableExtraExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.date,
    required this.onDelete,
  });

  @override
  State<ExpandableExtraExerciseCard> createState() =>
      _AlwaysExpandedExtraExerciseCardState();
}

class _AlwaysExpandedExtraExerciseCardState
    extends State<ExpandableExtraExerciseCard> {
  void _addSet(BuildContext context) {
    final exerciseProvider =
    Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.addSetToExercise(widget.date, widget.exerciseIndex);
  }

  void _removeSet(BuildContext context) {
    if (widget.exercise.sets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exercise must have at least 1 set")),
      );
      return;
    }
    final exerciseProvider =
    Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.removeSetFromExercise(widget.date, widget.exerciseIndex);
  }

  @override
  Widget build(BuildContext context) {
    int completedSets = widget.exercise.sets
        .where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      elevation: 6,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 14,
                              color: completedSets ==
                                  widget.exercise.sets.length
                                  ? Colors.green
                                  : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "$completedSets/${widget.exercise.sets.length} sets",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addSet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Set"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _removeSet(context),
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text("Remove"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  iconSize: 24,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sets Table
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          "Set",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Weight (kg)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Reps",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: widget.exercise.sets
                        .asMap()
                        .entries
                        .map((entry) {
                      return SetRow(
                        set: entry.value,
                        exerciseIndex: widget.exerciseIndex,
                        setIndex: entry.key,
                        date: widget.date,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}