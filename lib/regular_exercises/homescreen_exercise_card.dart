import 'package:flutter/material.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_screen.dart';
import '../Extra_exercise/extra_exercise_screen.dart';
import '../Providers/Excercise_provider.dart';
import '../models/individual_exercise_model.dart';



class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final String keyId;
  final int exerciseIndex;
  final bool isRegular;
  final bool forceExpanded; // controlled by "View All" toggle

  const ExerciseCard({
    required this.exercise,
    required this.keyId,
    required this.exerciseIndex,
    required this.isRegular,
    required this.forceExpanded,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool isExpanded = true;

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update expand/collapse when "View All" changes
    if (widget.forceExpanded != oldWidget.forceExpanded) {
      setState(() {
        isExpanded = widget.forceExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final isRegular = widget.isRegular;

    int completedSets = exercise.sets
        .where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty)
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRegular
              ? Colors.deepPurple.withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isRegular ? Colors.deepPurple : Colors.orange)
                  .withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center,
                    color: isRegular ? Colors.deepPurple : Colors.orange,
                    size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        "$completedSets/${exercise.sets.length} sets completed",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                // Expand/Collapse Button
                IconButton(
                  icon: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
                Icon(
                  completedSets == exercise.sets.length
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: completedSets == exercise.sets.length
                      ? Colors.green
                      : Colors.grey,
                ),
              ],
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: exercise.sets.map((set) {
                  bool done = set.weight.isNotEmpty && set.reps.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: done
                              ? Colors.green
                              : (isRegular
                              ? Colors.deepPurple[100]
                              : Colors.orange[100]),
                          child: Text(
                            "${set.setNumber}",
                            style: TextStyle(
                              color:
                              done ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            set.weight.isEmpty ? "-" : "${set.weight} kg",
                            style: TextStyle(
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
                          done ? Icons.check_circle : Icons.circle_outlined,
                          color: done ? Colors.green : Colors.grey,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // Edit Button
          InkWell(
            onTap: () {
              if (isRegular) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RegularExerciseScreen(dayName: widget.keyId,exerciseIndex: widget.exerciseIndex, ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExtraExerciseScreen(date: DateTime.parse(widget.keyId),exerciseIndex: widget.exerciseIndex,),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: (isRegular ? Colors.deepPurple : Colors.orange)
                    .withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit,
                      size: 18,
                      color: isRegular
                          ? Colors.deepPurple
                          : Colors.orange[800]),
                  const SizedBox(width: 8),
                  Text(
                    "Tap to edit sets",
                    style: TextStyle(
                      fontSize: 13,
                      color: isRegular
                          ? Colors.deepPurple
                          : Colors.orange[800],
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
