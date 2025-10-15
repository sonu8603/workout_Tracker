import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/excersize_day.dart';
import 'package:workout_tracker/Navigation_Controll/navigation_controll.dart';
import 'Extra_exercise/extra_exercise_ondate.dart';

class HomeScreen extends StatelessWidget {
  final String? day;
  const HomeScreen({super.key, this.day});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    String todayName = day ?? exerciseProvider.today['name'];
    final todayDate = DateTime.now();

    final regularExercises = exerciseProvider.getExercisesOfDay(todayName);
    final extraExercisesDetailed = exerciseProvider.getExercisesForDate(todayDate);

    final hasExercises = regularExercises.isNotEmpty || extraExercisesDetailed.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout at $todayName"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _showLeftPanel(context),
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

          // Extra Exercises Section (with full details)
          if (extraExercisesDetailed.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(
                  "Today's Extra Exercises",
                  Icons.add_circle_outline,
                ),
                TextButton(
                  onPressed: () => _navigateToExtraExercises(context, todayDate),
                  child: const Text("Edit"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...extraExercisesDetailed.map((exercise) {
              return _buildDetailedExerciseCard(context, exercise, todayDate);
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

  // Build simple exercise card (for regular exercises)
  Widget _buildExerciseCard(
      String exercise,
      int number,
      Color color,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  // Build detailed exercise card with all sets (for extra exercises)
  Widget _buildDetailedExerciseCard(BuildContext context, Exercise exercise, DateTime date) {
    int completedSets = exercise.sets.where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty).length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          // Exercise Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange, size: 26),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  completedSets == exercise.sets.length
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: completedSets == exercise.sets.length ? Colors.green : Colors.grey,
                  size: 30,
                ),
              ],
            ),
          ),

          // Sets Table
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Table Header
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text(
                        "Set",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Weight",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Reps",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 35),
                  ],
                ),
                const Divider(height: 20, thickness: 1.5),

                // Set Rows
                ...exercise.sets.map((set) {
                  bool isCompleted = set.weight.isNotEmpty && set.reps.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: isCompleted ? Colors.green : Colors.grey[300],
                            child: Text(
                              "${set.setNumber}",
                              style: TextStyle(
                                color: isCompleted ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            set.weight.isEmpty ? "-" : "${set.weight} kg",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: set.weight.isEmpty ? FontWeight.normal : FontWeight.w600,
                              color: set.weight.isEmpty ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            set.reps.isEmpty ? "-" : "${set.reps} reps",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: set.reps.isEmpty ? FontWeight.normal : FontWeight.w600,
                              color: set.reps.isEmpty ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 35,
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: isCompleted ? Colors.green : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Tap to edit hint
          InkWell(
            onTap: () => _navigateToExtraExercises(context, date),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Text(
                    "Tap to edit sets",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[800],
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

// Show dialog to add exercise with sets
void _showAddExerciseDialog(BuildContext context, DateTime date) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController(text: "3");

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Extra Exercise"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date subtitle
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Exercise Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Exercise Name",
                  hintText: "e.g., Bench Press",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Number of Sets
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: "Number of Sets",
                  hintText: "3",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && setsController.text.isNotEmpty) {
                final exerciseProvider =
                Provider.of<ExerciseProvider>(context, listen: false);

                int numberOfSets = int.tryParse(setsController.text) ?? 3;
                exerciseProvider.addExerciseForDate(date, nameController.text.trim(), numberOfSets);

                Navigator.pop(context);

                // Navigate to extra exercise screen to fill in sets
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtraExerciseScreen(date: date),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text("Add & Continue"),
          ),
        ],
      );
    },
  );
}

// Format date helper
String _formatDate(DateTime date) {
  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
}

// Menu bar
void _showLeftPanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Menu",
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.deepPurple),
                  title: const Text("Edit Exercise"),
                  onTap: () {
                    Navigator.pop(context);
                    final exerciseProvider =
                    Provider.of<ExerciseProvider>(context, listen: false);
                    final todayName = exerciseProvider.today['name'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExerciseScreen(day: todayName),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Settings clicked")),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
                  title: const Text("Help"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Help clicked")),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}