import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/excersize_day.dart';
import 'package:workout_tracker/Navigation_Controll/navigation_controll.dart';

import 'Navigation_Controll/side_pannel_navigation.dart';
import 'models/extra_exercise_ondate.dart';

class HomeScreen extends StatelessWidget {
  final String? day;
  const HomeScreen({super.key, this.day});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    String todayName = day ?? exerciseProvider.today['name'];
    final todayDate = DateTime.now();

    final regularExercises = exerciseProvider.getExercisesOfDay(todayName);
    final extraExercises = exerciseProvider.getExercisesOfDate(todayDate);

    final hasExercises = regularExercises.isNotEmpty || extraExercises.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout at $todayName"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => showLeftPanel(context),
        ),
      ),
      body: !hasExercises
          ? Center(
        child: Text(
          exerciseProvider.isDayEnabled(todayName)
              ? "No exercises added for $todayName"
              : "$todayName is a rest day",
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Regular Day Exercises Section
          if (regularExercises.isNotEmpty) ...[
            _buildSectionHeader("Regular Exercises", Icons.fitness_center),
            const SizedBox(height: 8),
            ...regularExercises.asMap().entries.map((entry) {
              return _buildExerciseCard(
                entry.value,
                entry.key + 1,
                Colors.deepPurple,
              );
            }).toList(),
            const SizedBox(height: 16),
          ],

          // Extra Exercises Section (with quick preview)
          if (extraExercises.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(
                  "Today's Extra Exercises",
                  Icons.add_circle_outline,
                ),
                TextButton(
                  onPressed: () => _navigateToExtraExercises(context, todayDate),
                  child: const Text("Manage"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...extraExercises.asMap().entries.map((entry) {
              return _buildExerciseCard(
                entry.value,
                entry.key + 1,
                Colors.lightBlue,
                isExtra: true,
              );
            }).toList(),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToExtraExercises(context, todayDate),
        backgroundColor: Colors.blue,
        tooltip: "Add Extra Exercise",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // Navigate to Extra Exercise Screen
  void _navigateToExtraExercises(BuildContext context, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraExerciseScreen(date: date),
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  // Build exercise card
  Widget _buildExerciseCard(
      String exercise,
      int number,
      Color color, {
        bool isExtra = false,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExtra ? Colors.orange.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            "$number",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(exercise),
        trailing: isExtra
            ? const Icon(Icons.calendar_today, color: Colors.orange, size: 20)
            : null,
      ),
    );
  }
}

