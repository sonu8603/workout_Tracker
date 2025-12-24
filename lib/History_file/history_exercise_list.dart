import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Excercise_provider.dart';
import '../models/individual_exercise_model.dart';
import 'history_exercises_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, child) {
          // Get all workout dates that have exercises
          final allDates = _getAllDatesWithExercises(provider);

          if (allDates.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No workout history yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allDates.length,
            itemBuilder: (context, index) {
              final date = allDates[index];
              final exercises = provider.getAllExercisesForDate(date);

              return DateExerciseCard(
                date: date,
                exercises: exercises,
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Modified: Get all unique dates with exercises (no 30-day limit)
  List<DateTime> _getAllDatesWithExercises(ExerciseProvider provider) {
    final dates = <DateTime>{};

    // 1️⃣ Weekly planned exercises (from _days)
    for (var day in provider.days) {
      final exercises = day.exercises;
      for (var exercise in exercises) {
        dates.add(DateTime(
          exercise.date.year,
          exercise.date.month,
          exercise.date.day,
        ));
      }
    }

    // 2️⃣ All recorded extra exercise dates (from _extraExercises)
    final extraExerciseDates = provider.getAllExtraExerciseDates();
    dates.addAll(extraExerciseDates);

    // 3️⃣ Sort dates (latest first)
    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));

    return sortedDates;
  }
}

// 🟣 Date-wise exercise card
class DateExerciseCard extends StatelessWidget {
  final DateTime date;
  final List<Exercise> exercises;

  const DateExerciseCard({
    super.key,
    required this.date,
    required this.exercises,
  });

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${weekdays[date.weekday - 1]}, '
          '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} '
          '${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryExercisesScreen(
                date: date,
                exercises: exercises,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Calendar icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Date info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFormattedDate(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercises.length} exercises',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}