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
    // 🔥 Separate Regular and Extra exercises
    final regularExercises = <CompletedExercise>[];
    final extraExercises = <CompletedExercise>[];

    for (var log in logs) {
      // Check if this log is from regular workout (has dayName like "Monday", "Tuesday")
      if (_isRegularWorkout(log.dayName)) {
        regularExercises.addAll(log.exercises);
      } else {
        // Extra exercises (dayName will be date string or "Extra")
        extraExercises.addAll(log.exercises);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(date)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 23),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Regular Exercises Section
            if (regularExercises.isNotEmpty) ...[
              _buildSectionHeader(
                icon: Icons.fitness_center,
                title: " Regular Exercises",
                color: Colors.deepPurple,
                count: regularExercises.length,
              ),
              const SizedBox(height: 12),
              ...regularExercises.map((exercise) => ExerciseCard(
                exercise: exercise,
                color: Colors.deepPurple,
              )),
            ],

            // 🔥 Extra Exercises Section
            if (extraExercises.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(
                icon: Icons.add_circle,
                title: " Extra Exercises",
                color: Colors.orange,
                count: extraExercises.length,
              ),
              const SizedBox(height: 12),
              ...extraExercises.map((exercise) => ExerciseCard(
                exercise: exercise,
                color: Colors.orange,
              )),
            ],

            // 🔥 Empty state
            if (regularExercises.isEmpty && extraExercises.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.fitness_center,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'No exercises recorded',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔥 Section Header Widget
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Check if workout is regular (Monday-Sunday) or extra
  bool _isRegularWorkout(String dayName) {
    const regularDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return regularDays.contains(dayName);
  }
}

// 🔥 Expandable Exercise Card
class ExerciseCard extends StatefulWidget {
  final CompletedExercise exercise;
  final Color color;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.color,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final completedSetsCount = ex.completedSets.length;
    final totalSetsCount = ex.sets.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          // 🔥 Header (tap to expand)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: _expanded ? Radius.zero : const Radius.circular(12),
                  bottomRight: _expanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: widget.color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              completedSetsCount == totalSetsCount
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 14,
                              color: completedSetsCount == totalSetsCount
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$completedSetsCount/$totalSetsCount sets completed',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.color,
                      size: 28,
                    ),
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
            secondChild: _buildSetsTable(ex),
          ),
        ],
      ),
    );
  }

  // 🔥 Sets Table
  Widget _buildSetsTable(CompletedExercise ex) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Set',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Weight (kg)',
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
                    'Reps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 30), // For check icon
              ],
            ),
          ),

          // Table Rows
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: ex.sets.asMap().entries.map((entry) {
                final i = entry.key;
                final set = entry.value;
                final isCompleted =
                    set.weight.isNotEmpty && set.reps.isNotEmpty;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : Colors.grey[50],
                    border: i < ex.sets.length - 1
                        ? Border(
                        bottom: BorderSide(color: Colors.grey[200]!))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Set number
                      SizedBox(
                        width: 40,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: widget.color.withOpacity(0.15),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      // Weight
                      Expanded(
                        child: Text(
                          set.weight.isEmpty ? '-' : '${set.weight} kg',
                          textAlign: TextAlign.center,
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

                      // Reps
                      Expanded(
                        child: Text(
                          set.reps.isEmpty ? '-' : '${set.reps} reps',
                          textAlign: TextAlign.center,
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

                      // Check icon
                      SizedBox(
                        width: 30,
                        child: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isCompleted ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔥 Total Volume
          if (ex.totalVolume > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: widget.color, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Total Volume:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${ex.totalVolume.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}