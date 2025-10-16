import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/Navigation_Controll/navigation_controll.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_logic.dart';
import 'package:workout_tracker/regular_exercises/regular_exercise_screen.dart';
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
             ElevatedButton(onPressed: (){
               Navigator.push(context, MaterialPageRoute(builder: (context)=>AddExerciseScreen(day: todayName)));
             }, child: Text("add exercise"))
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Regular Exercises Section
          if (regularExercises.isNotEmpty) ...[
            _buildSectionHeader("Regular Exercises", Icons.fitness_center),
            const SizedBox(height: 8),
            ...regularExercises.map((exercise) {
              return _buildExerciseCard(context, exercise, todayName, isRegular: true);
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
                  onPressed: () => _navigateToExtraExercises(context, todayDate),
                  child: const Text("Edit"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...extraExercisesDetailed.map((exercise) {
              return _buildExerciseCard(context, exercise, todayDate.toString());
            }).toList(),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context, todayDate),
        backgroundColor: Colors.orange,
        tooltip: "Add Extra Exercise",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // Section Header
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

  // Exercise Card (used for both regular and extra)
  Widget _buildExerciseCard(BuildContext context, Exercise exercise, String keyId,
      {bool isRegular = false}) {
    int completedSets =
        exercise.sets.where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty).length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRegular ? Colors.deepPurple.withOpacity(0.4) : Colors.orange.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isRegular ? Colors.deepPurple : Colors.orange).withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: isRegular ? Colors.deepPurple : Colors.orange,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$completedSets/${exercise.sets.length} sets completed",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  completedSets == exercise.sets.length
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: completedSets == exercise.sets.length ? Colors.green : Colors.grey,
                  size: 28,
                ),
              ],
            ),
          ),

          // Sets List
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: exercise.sets.map((set) {
                bool isCompleted = set.weight.isNotEmpty && set.reps.isNotEmpty;
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
                              : (isRegular ? Colors.deepPurple[100] : Colors.orange[100]),
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
                            fontWeight:
                            set.weight.isEmpty ? FontWeight.normal : FontWeight.w600,
                            color: set.weight.isEmpty ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          set.reps.isEmpty ? "-" : "${set.reps} reps",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            set.reps.isEmpty ? FontWeight.normal : FontWeight.w600,
                            color: set.reps.isEmpty ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 35,
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Tap to Edit  for regular and extra exercise
          InkWell(
            onTap: () {
              if (isRegular) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularExerciseScreen(dayName: keyId),

                  ),
                );
              } else {// yaha se extrascreen pe push ho raha hai
                _navigateToExtraExercises(context, DateTime.parse(keyId));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: (isRegular ? Colors.deepPurple : Colors.orange).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit,
                      size: 18, color: isRegular ? Colors.deepPurple : Colors.orange[800]),
                  const SizedBox(width: 8),
                  Text(
                    "Tap to edit sets",
                    style: TextStyle(
                      fontSize: 13,
                      color: isRegular ? Colors.deepPurple : Colors.orange[800],
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

  // Add Extra Exercise Dialog
  void _showAddExerciseDialog(BuildContext context, DateTime date) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController setsController = TextEditingController(text: "3");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Extra Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Exercise Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: "Number of Sets",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final provider = Provider.of<ExerciseProvider>(context, listen: false);
                  final numSets = int.tryParse(setsController.text) ?? 3;
                  provider.addExerciseForDate(date, nameController.text.trim(), numSets);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Add"),
            ),
          ],
        );
      },
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


}
