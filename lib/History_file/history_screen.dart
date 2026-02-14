import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_log_model.dart';
import '../main.dart';
import 'history_exercises_screen.dart';

class HistoryWorkoutLogsScreen extends StatelessWidget {
  const HistoryWorkoutLogsScreen({super.key});

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
    final box = Hive.box<WorkoutLog>(HiveConfig.workoutLogsBox);

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        automaticallyImplyLeading: false,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        backgroundColor: Colors.deepPurple,


      ),
      body: ValueListenableBuilder<Box<WorkoutLog>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No workouts yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final logs = box.values.toList().cast<WorkoutLog>();

          final Map<DateTime, List<WorkoutLog>> grouped = {};
          for (var log in logs) {
            final key = DateTime(log.date.year, log.date.month, log.date.day);
            grouped.putIfAbsent(key, () => []).add(log);
          }

          final dates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final dayLogs = grouped[date]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today,
                      color: Colors.deepPurple),
                  title: Text(
                    _formatDate(date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${dayLogs.length} workout sessions • '
                        '${dayLogs.fold<int>(0, (sum, l) => sum + l.totalCompletedSets)} sets',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoryDayDetailScreen(date: date,logs: dayLogs,),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
