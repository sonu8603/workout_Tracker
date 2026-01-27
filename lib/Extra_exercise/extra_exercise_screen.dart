import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';

import '../models/individual_exercise_model.dart';
import 'extra_exercise_logic.dart';

class ExtraExerciseScreen extends StatelessWidget {
  final DateTime date;
  final int? exerciseIndex; // If provided, show only that exercise

  const ExtraExerciseScreen({
    super.key,
    required this.date,
    this.exerciseIndex, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final allExercises = exerciseProvider.getExercisesForDate(date);

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
              : "Extra Exercises",
        ),
        backgroundColor: Colors.orange,
      ),
      body: exercisesToShow.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No exercises added yet",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
          return ExpandableExtraExerciseCard(
            exercise: exercisesToShow[index],
            exerciseIndex: actualIndex,
            date: date,
            onDelete: () => _deleteExercise(context, actualIndex),
          );
        },
      ),
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

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

// ============================================================
// EXPANDABLE EXTRA EXERCISE CARD - NEW IMPLEMENTATION
// ============================================================

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
      _ExpandableExtraExerciseCardState();
}

class _ExpandableExtraExerciseCardState
    extends State<ExpandableExtraExerciseCard>
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
        side: BorderSide(
          color: _isExpanded
              ? Colors.orange
              : Colors.orange.withOpacity(0.3),
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
                    ? Colors.orange.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.08),
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
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //  EXPANDED CONTENT
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