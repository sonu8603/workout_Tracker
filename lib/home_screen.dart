import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_screen.dart';
import 'Cards/exercise_card.dart';
import 'Cards/exercise_dialog_pop_up.dart';
import 'Extra_exercise/extra_exercise_screen.dart';
import 'Navigation_Controll/side_pannel_navigation.dart';
import 'excersize_day_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? day;
  const HomeScreen({super.key, this.day});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    String todayName = day ?? exerciseProvider.today['name'];
    final todayDate = DateTime.now();

    final regularExercises = exerciseProvider.getExercisesForDay(todayName);
    final extraExercisesDetailed = exerciseProvider.getExercisesForDate(todayDate);

    final hasExercises = regularExercises.isNotEmpty || extraExercisesDetailed.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout at $todayName"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => showLeftPanel(context),
        ),
      ),
      body: !hasExercises
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              exerciseProvider.isDayEnabled(todayName)
                  ? "No exercises added for $todayName"
                  : "$todayName is a rest day",
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExerciseScreen(day: todayName),
                  ),
                );
              },
              child: const Text("add exercise"),
            )
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Regular Exercises Section
          if (regularExercises.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("Regular Exercises", Icons.fitness_center),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegularExerciseScreen(  // all exercise displayed here
                          dayName: todayName,
                          exerciseIndex: null,
                        ),
                      ),
                    );
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...regularExercises.asMap().entries.map((entry) {
              return ExpandableExerciseCard(
                exercise: entry.value,
                keyId: todayName,
                exerciseIndex: entry.key,
                isRegular: true,
              );
            }).toList(),
            const SizedBox(height: 16),
          ],

          // Extra Exercises Section
          if (extraExercisesDetailed.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("Today's Extra Exercises", Icons.add_circle_outline),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExtraExerciseScreen(
                          date: todayDate,
                          exerciseIndex: null,
                        ),
                      ),
                    );
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...extraExercisesDetailed.asMap().entries.map((entry) {
              return ExpandableExerciseCard(
                exercise: entry.value,
                keyId: todayDate.toString(),
                exerciseIndex: entry.key,
                isRegular: false,
              );
            }).toList(),
          ],
        ],
      ),
      floatingActionButton: regularExercises.isNotEmpty
          ? FloatingActionButton(
        onPressed: () => showAddExerciseDialog(context, todayDate),
        backgroundColor: Colors.orange,
        tooltip: "Add Extra Exercise",
        child: const Icon(Icons.add),
      )
          : null,

    );
  }

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


}
