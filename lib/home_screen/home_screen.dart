import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_screen.dart';
import '../Cards/exercise_card.dart';
import '../Cards/exercise_dialog_pop_up.dart';
import '../Extra_exercise/extra_exercise_screen.dart';
import '../Navigation_Controll/side_pannel_navigation.dart';
import 'addexcersize_day_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? day;
  const HomeScreen({super.key, this.day});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    String todayName = day ?? exerciseProvider.today.name;
    final todayDate = DateTime.now();

    final regularExercises = exerciseProvider.getExercisesForDay(todayName);
    final extraExercisesDetailed =
    exerciseProvider.getExercisesForDate(todayDate);

    final hasExercises =
        regularExercises.isNotEmpty || extraExercisesDetailed.isNotEmpty;

    final isRestDay = !exerciseProvider.isDayEnabled(todayName);

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout at $todayName"),
        backgroundColor: Colors.deepPurple[500],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => showLeftPanel(context),
        ),
      ),

      // If today is rest day
      body: isRestDay
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 70, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              "$todayName is a Rest Day 💤",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Take rest and recover your muscles!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )

      // If not rest day → show exercises normally
          : !hasExercises
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No exercises added for $todayName",
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddExerciseScreen(day: todayName),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Add Exercise"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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
                _buildSectionHeader(
                    "Regular Exercises", Icons.fitness_center),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegularExerciseScreen(
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
              return ExerciseCard(
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
                _buildSectionHeader(
                    "Today's Extra Exercises",
                    Icons.add_circle_outline),
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
              return ExerciseCard(
                exercise: entry.value,
                keyId: todayDate.toString(),
                exerciseIndex: entry.key,
                isRegular: false,

              );

            }).toList(),
          ],
        ],
      ),

      floatingActionButton: isRestDay
          ? null
          : regularExercises.isNotEmpty
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