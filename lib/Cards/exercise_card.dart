

import 'package:flutter/material.dart';

import '../Extra_exercise/extra_exercise_screen.dart';
import '../models/individual_exercise_model.dart';
import '../regular_exercises/regular_exercise_screen.dart';

// Expandable Exercise Card Widget for regular and extra
class ExpandableExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final String keyId;
  final int exerciseIndex;
  final bool isRegular;

  const ExpandableExerciseCard({
    required this.exercise,
    required this.keyId,
    required this.exerciseIndex,
    required this.isRegular,
  });

  @override
  State<ExpandableExerciseCard> createState() => _ExpandableExerciseCardState();
}
class _ExpandableExerciseCardState extends State<ExpandableExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    int completedSets = widget.exercise.sets
        .where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty)
        .length;

    final color = widget.isRegular ? Colors.deepPurple : Colors.orange;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Header row (tap to expand)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                  _isExpanded ? Radius.zero : const Radius.circular(16),
                  bottomRight:
                  _isExpanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: color, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.exercise.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          "$completedSets/${widget.exercise.sets.length} sets completed",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child:
                    Icon(Icons.keyboard_arrow_down, color: color, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    completedSets == widget.exercise.sets.length
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: completedSets == widget.exercise.sets.length
                        ? Colors.green
                        : Colors.grey,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),

          // Animated expand area
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(context, color),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          ...widget.exercise.sets.map((set) {
            bool isCompleted =
                set.weight.isNotEmpty && set.reps.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: isCompleted
                          ? Colors.green
                          : color.withOpacity(0.15),
                      child: Text(
                        "${set.setNumber}",
                        style: TextStyle(
                          color: isCompleted ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      set.weight.isEmpty ? "-" : "${set.weight} kg",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: set.weight.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: set.weight.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      set.reps.isEmpty ? "-" : "${set.reps} reps",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: set.reps.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: set.reps.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              if (widget.isRegular) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularExerciseScreen(
                      dayName: widget.keyId,
                      exerciseIndex: widget.exerciseIndex,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtraExerciseScreen(
                      date: DateTime.parse(widget.keyId),
                      exerciseIndex: widget.exerciseIndex,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    "Tap to edit sets",
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
