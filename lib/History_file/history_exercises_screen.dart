import 'package:flutter/material.dart';
import '../models/workout_log_model.dart';

class HistoryDayDetailScreen extends StatelessWidget {
  final DateTime date;
  final List<WorkoutLog> logs;

  const HistoryDayDetailScreen({
    super.key,
    required this.date,
    required this.logs,
  });

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    //  Flatten all exercises of the day
    final allExercises = logs.expand((log) => log.exercises).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(date)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 23),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allExercises.length,
        itemBuilder: (context, index) {
          return ExerciseCard(exercise: allExercises[index]);
        },
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  final CompletedExercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ex.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSets(ex),
          ),
        ],
      ),
    );
  }

  Widget _buildSets(CompletedExercise ex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: ex.completedSets.asMap().entries.map((entry) {
          final i = entry.key;
          final set = entry.value;
          return Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Set ${i + 1}')),
                Expanded(child: Text(set.weight)),
                Expanded(child: Text(set.reps)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
