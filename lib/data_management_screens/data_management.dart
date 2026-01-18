import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/Excercise_provider.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);
    final stats = provider.getStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Management"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics Card
          _buildStatsCard(stats),

          const SizedBox(height: 24),

          // Delete Options Header
          const Text(
            "Delete Options",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose what data you want to delete",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 16),

          // Delete Exercise History (Combined - all instances)
          _buildDeleteCard(
            context: context,
            icon: Icons.history,
            iconColor: Colors.purple,
            title: "Delete Exercise History",
            subtitle: "Remove specific exercise from everywhere (weekly + extra)",
            count: stats['uniqueExerciseNames'],
            onDelete: () => _showDeleteHistoryDialog(context, provider),
          ),

          const SizedBox(height: 12),

          // Delete Weekly Exercises
          _buildDeleteCard(
            context: context,
            icon: Icons.calendar_today,
            iconColor: Colors.blue,
            title: "Delete Weekly Exercises",
            subtitle: "Remove all exercises from weekly routine only",
            count: _countWeeklyExercises(provider),
            onDelete: () => _showDeleteWeeklyExercisesDialog(context, provider),
          ),

          const SizedBox(height: 12),

          // Delete Extra Exercises
          _buildDeleteCard(
            context: context,
            icon: Icons.add_circle_outline,
            iconColor: Colors.orange,
            title: "Delete Extra Exercises",
            subtitle: "Remove all additional recorded exercises only",
            count: _countExtraExercises(provider),
            onDelete: () => _showDeleteExtraExercisesDialog(context, provider),
          ),

          const SizedBox(height: 12),

          // Delete Old Data
          _buildDeleteCard(
            context: context,
            icon: Icons.delete_sweep,
            iconColor: Colors.teal,
            title: "Delete Old Data",
            subtitle: "Remove data older than selected period",
            count: null,
            onDelete: () => _showDeleteOldDataDialog(context, provider),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Danger Zone
          const Text(
            "⚠️ Danger Zone",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),

          // Delete All Data
          _buildDangerCard(
            context: context,
            icon: Icons.delete_forever,
            title: "Delete All Data",
            subtitle: "Permanently delete everything",
            onDelete: () => _showDeleteAllDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Your Data Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  "Exercises",
                  stats['totalExercises'].toString(),
                  Icons.fitness_center,
                ),
                _buildStatItem(
                  "Sets",
                  stats['totalSets'].toString(),
                  Icons.format_list_numbered,
                ),
                _buildStatItem(
                  "Days",
                  stats['totalDaysWithData'].toString(),
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDeleteCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int? count,
    required VoidCallback onDelete,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            if (count != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$count items",
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: count == 0 ? null : onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: iconColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Delete"),
        ),
      ),
    );
  }

  Widget _buildDangerCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Delete All"),
        ),
      ),
    );
  }

  int _countWeeklyExercises(ExerciseProvider provider) {
    int count = 0;
    for (var day in provider.days) {
      count += day.exercises.length;
    }
    return count;
  }

  int _countExtraExercises(ExerciseProvider provider) {
    int count = 0;
    final dates = provider.getAllExtraExerciseDates();
    for (var date in dates) {
      count += provider.getExercisesForDate(date).length;
    }
    return count;
  }

  // Delete Exercise History (Complete removal from everywhere)
  void _showDeleteHistoryDialog(BuildContext context, ExerciseProvider provider) {
    final allExerciseNames = _getAllUniqueExerciseNames(provider);
    String? selectedExercise;

    if (allExerciseNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No exercises found"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.history, color: Colors.purple),
              SizedBox(width: 8),
              Text("Delete Exercise History"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This will remove the selected exercise from:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("• Weekly routine"),
              const Text("• Extra exercises"),
              const Text("• All historical data"),
              const SizedBox(height: 16),
              const Text(
                "Select exercise to delete:",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedExercise,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Exercise",
                  prefixIcon: const Icon(Icons.fitness_center),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                isExpanded: true,
                items: allExerciseNames.map((name) {
                  final count = _countExerciseOccurrences(provider, name);
                  return DropdownMenuItem(
                    value: name,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name),
                        Text(
                          "$count instance${count > 1 ? 's' : ''}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedExercise = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: selectedExercise == null
                  ? null
                  : () async {
                Navigator.pop(context);
                await _deleteExerciseHistory(context, provider, selectedExercise!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete History"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteExerciseHistory(BuildContext context, ExerciseProvider provider, String exerciseName) async {
    try {
      int deletedCount = 0;

      // Delete from weekly exercises
      for (var day in provider.days) {
        final removed = day.exercises.where((e) => e.name == exerciseName).length;
        day.exercises.removeWhere((e) => e.name == exerciseName);
        deletedCount += removed;
      }

      // Delete from extra exercises
      final dates = provider.getAllExtraExerciseDates();
      for (var date in dates) {
        final exercises = provider.getExercisesForDate(date);
        for (int i = exercises.length - 1; i >= 0; i--) {
          if (exercises[i].name == exerciseName) {
            await provider.removeExerciseForDate(date, i);
            deletedCount++;
          }
        }
      }

      provider.notifyListeners(); // Trigger UI update and save

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Deleted $deletedCount instance${deletedCount > 1 ? 's' : ''} of \"$exerciseName\""),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting exercise: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _countExerciseOccurrences(ExerciseProvider provider, String exerciseName) {
    int count = 0;

    // Count in weekly exercises
    for (var day in provider.days) {
      count += day.exercises.where((e) => e.name == exerciseName).length;
    }

    // Count in extra exercises
    final dates = provider.getAllExtraExerciseDates();
    for (var date in dates) {
      count += provider.getExercisesForDate(date).where((e) => e.name == exerciseName).length;
    }

    return count;
  }

  // Delete Weekly Exercises
  void _showDeleteWeeklyExercisesDialog(BuildContext context, ExerciseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue),
            SizedBox(width: 8),
            Text("Delete Weekly Exercises?"),
          ],
        ),
        content: const Text(
          "This will remove all exercises from your weekly routine (Monday-Sunday).\n\nExtra recorded exercises will NOT be affected.\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteWeeklyExercises(context, provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete Weekly"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWeeklyExercises(BuildContext context, ExerciseProvider provider) async {
    try {
      int count = 0;
      for (var day in provider.days) {
        count += day.exercises.length;
        day.exercises.clear();
      }
      provider.notifyListeners(); // Trigger UI update and save

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Deleted $count weekly exercises"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete Extra Exercises
  void _showDeleteExtraExercisesDialog(BuildContext context, ExerciseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text("Delete Extra Exercises?"),
          ],
        ),
        content: const Text(
          "This will remove all additionally recorded exercises (not part of weekly routine).\n\nWeekly exercises will NOT be affected.\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteExtraExercises(context, provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete Extra"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExtraExercises(BuildContext context, ExerciseProvider provider) async {
    try {
      final dates = provider.getAllExtraExerciseDates();
      int count = 0;
      for (var date in dates) {
        count += provider.getExercisesForDate(date).length;
        await provider.clearExercisesForDate(date);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Deleted $count extra exercises"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete Old Data
  void _showDeleteOldDataDialog(BuildContext context, ExerciseProvider provider) {
    int selectedDays = 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_sweep, color: Colors.teal),
              SizedBox(width: 8),
              Text("Delete Old Data"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Delete extra exercise data older than:"),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDays,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Period",
                  prefixIcon: Icon(Icons.access_time),
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text("7 days")),
                  DropdownMenuItem(value: 30, child: Text("30 days")),
                  DropdownMenuItem(value: 60, child: Text("60 days")),
                  DropdownMenuItem(value: 90, child: Text("90 days")),
                  DropdownMenuItem(value: 180, child: Text("6 months")),
                ],
                onChanged: (value) {
                  setState(() => selectedDays = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteOldData(context, provider, selectedDays);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteOldData(BuildContext context, ExerciseProvider provider, int days) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      int deletedDays = 0;
      int deletedExercises = 0;

      final dates = provider.getAllExtraExerciseDates();
      for (var date in dates) {
        if (date.isBefore(cutoffDate)) {
          deletedExercises += provider.getExercisesForDate(date).length;
          await provider.clearExercisesForDate(date);
          deletedDays++;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Deleted $deletedExercises exercises from $deletedDays days"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete All Data
  void _showDeleteAllDialog(BuildContext context, ExerciseProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete All Data?"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ This will PERMANENTLY delete ALL your data:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("• All weekly exercises"),
            const Text("• All extra exercises"),
            const Text("• All workout history"),
            const Text("• All progress data"),
            const SizedBox(height: 16),
            const Text(
              "This action CANNOT be undone!",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Type DELETE to confirm",
                hintText: "DELETE",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().toUpperCase() == "DELETE") {
                Navigator.pop(context);
                await provider.clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✓ All data deleted"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please type DELETE to confirm"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
  }

  List<String> _getAllUniqueExerciseNames(ExerciseProvider provider) {
    final Set<String> names = {};

    for (var day in provider.days) {
      for (var ex in day.exercises) {
        names.add(ex.name);
      }
    }

    final dates = provider.getAllExtraExerciseDates();
    for (var date in dates) {
      final exercises = provider.getExercisesForDate(date);
      for (var ex in exercises) {
        names.add(ex.name);
      }
    }

    return names.toList()..sort();
  }
}