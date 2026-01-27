import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_logic.dart';

import '../models/individual_exercise_model.dart';

class RegularExerciseScreen extends StatelessWidget {
  final String dayName;
  final int? exerciseIndex; // If provided, show only that exercise

  const RegularExerciseScreen({
    super.key,
    required this.dayName,
    this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final allExercises = exerciseProvider.getExercisesForDay(dayName);

    // Filter exercises: show only one if exerciseIndex is provided
    final List<Exercise> exercisesToShow;
    if (exerciseIndex != null && exerciseIndex! < allExercises.length) {
      // Show ONLY the selected exercise
      exercisesToShow = [allExercises[exerciseIndex!]];
    } else {
      // Show all exercises
      exercisesToShow = allExercises;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exerciseIndex != null && exercisesToShow.isNotEmpty
              ? exercisesToShow[0].name // Show exercise name when viewing single
              : "$dayName Exercises",
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: exercisesToShow.isEmpty
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
        itemCount: exercisesToShow.length,
        itemBuilder: (context, index) {
          // Use the actual index from the full list
          final actualIndex = exerciseIndex ?? index;
          return ExpandableRegularExerciseCard(
            exercise: exercisesToShow[index],
            exerciseIndex: actualIndex,
            dayName: dayName,
            onDelete: () => _deleteExercise(context, actualIndex),
          );
        },
      ),
      floatingActionButton: exerciseIndex == null
          ? FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      )
          : null, // Hide FAB when viewing single exercise
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
                  int numberOfSets = int.tryParse(setsController.text) ?? 3;
                  exerciseProvider.addExerciseToDay(dayName,
                      nameController.text.trim(), numberOfSets, DateTime.now());
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
                backgroundColor: Colors.deepPurple[300],
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



class ExpandableRegularExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final String dayName;
  final VoidCallback onDelete;

  const ExpandableRegularExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.dayName,
    required this.onDelete,
  });

  @override
  State<ExpandableRegularExerciseCard> createState() => _CollapsibleRegularExerciseCardState();
}

class _CollapsibleRegularExerciseCardState extends State<ExpandableRegularExerciseCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _addSet(BuildContext context) {
    final exerciseProvider =
    Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.addSetToDayExercise(widget.dayName, widget.exerciseIndex);
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
    exerciseProvider.removeSetFromDayExercise(
        widget.dayName, widget.exerciseIndex);
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
        side: BorderSide(
          color: _isExpanded
              ? Colors.deepPurple
              : Colors.deepPurple.withOpacity(0.3),
          width: _isExpanded ? 2 : 1,
        ),
      ),
      elevation: _isExpanded ? 8 : 3,
      child: Column(
        children: [
          // ========== COLLAPSED HEADER (Always Visible) ==========
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? Colors.deepPurple.withOpacity(0.15)
                    : Colors.deepPurple.withOpacity(0.08),
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                )
                    : BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Exercise Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Exercise Info
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
                                color: completedSets == widget.exercise.sets.length
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

                  // Expand/Collapse Icon
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      Icons.expand_more,
                      color: Colors.deepPurple,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========== EXPANDED CONTENT ==========
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1),

                // Action Buttons Row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Add Set Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addSet(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add Set"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple[300],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Remove Set Button
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

                      // Delete Exercise Button
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
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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

                      // Set Rows
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
                            return RegularSetRow(
                              set: entry.value,
                              exerciseIndex: widget.exerciseIndex,
                              setIndex: entry.key,
                              dayName: widget.dayName,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}