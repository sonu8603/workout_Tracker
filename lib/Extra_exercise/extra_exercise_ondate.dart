import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';

class ExtraExerciseScreen extends StatelessWidget {
  final DateTime date;

  const ExtraExerciseScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final exercises = exerciseProvider.getExercisesForDate(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Extra Exercises"),
        backgroundColor: Colors.orange,
      ),
      body: exercises.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No exercises added yet",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return _ExerciseCard(
            exercise: exercises[index],
            exerciseIndex: index,
            date: date,
            onDelete: () => _deleteExercise(context, index),
          );
        },
      ),
    );
  }

  void _deleteExercise(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Exercise"),
          content: const Text("Are you sure you want to delete this exercise?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final exerciseProvider =
                Provider.of<ExerciseProvider>(context, listen: false);
                exerciseProvider.removeExerciseForDate(date, index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

// Individual Exercise Card Widget
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final DateTime date;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.date,
    required this.onDelete,
  });

  void _addSet(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.addSetToExercise(date, exerciseIndex);
  }

  void _removeSet(BuildContext context) {
    if (exercise.sets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exercise must have at least 1 set")),
      );
      return;
    }
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.removeSetFromExercise(date, exerciseIndex);
  }

  @override
  Widget build(BuildContext context) {
    int completedSets = exercise.sets.where((s) => s.weight.isNotEmpty && s.reps.isNotEmpty).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 2),
      ),
      elevation: 3,
      child: Column(
        children: [
          // Exercise Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$completedSets/${exercise.sets.length} sets completed",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Add/Remove Set Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _removeSet(context),
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text("Remove Set"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _addSet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add Set"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sets List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    const SizedBox(width: 60, child: Text("Set", style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(child: Text("Weight (kg)", style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("Reps", style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 40),
                  ],
                ),
                const Divider(height: 24),

                // Set Rows
                ...exercise.sets.asMap().entries.map((entry) {
                  return _SetRow(
                    set: entry.value,
                    exerciseIndex: exerciseIndex,
                    setIndex: entry.key,
                    date: date,
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Individual Set Row Widget
class _SetRow extends StatefulWidget {
  final ExerciseSet set;
  final int exerciseIndex;
  final int setIndex;
  final DateTime date;

  const _SetRow({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
    required this.date,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController weightController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(text: widget.set.weight);
    repsController = TextEditingController(text: widget.set.reps);
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  void _updateSet() {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.updateExerciseSet(
      widget.date,
      widget.exerciseIndex,
      widget.setIndex,
      weightController.text,
      repsController.text,
    );
  }

  void _incrementWeight() {
    double currentWeight = double.tryParse(weightController.text) ?? 1;
    currentWeight += 0.5; // Increment by 0.5 kg
    weightController.text = currentWeight.toString();
    _updateSet();
  }

  void _decrementWeight() {
    double currentWeight = double.tryParse(weightController.text) ?? 0.5;
    if (currentWeight >= 0.5) {
      currentWeight -= 0.5;
      weightController.text = currentWeight.toString();
      _updateSet();
    }
  }

  void _incrementReps() {
    int currentReps = int.tryParse(repsController.text) ?? 0;
    currentReps++;
    repsController.text = currentReps.toString();
    _updateSet();
  }

  void _decrementReps() {
    int currentReps = int.tryParse(repsController.text) ?? 0;
    if (currentReps > 0) {
      currentReps--;
      repsController.text = currentReps.toString();
      _updateSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.set.weight.isNotEmpty && widget.set.reps.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 60,
            child: CircleAvatar(
              backgroundColor: isCompleted ? Colors.green : Colors.grey[300],
              child: Text(
                "${widget.set.setNumber}",
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Weight Section with +/- buttons
          Expanded(
            child: GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      // Minus button
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.orange,
                          iconSize: 24,
                          onPressed: _decrementWeight,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 5),

                      // Weight Input
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "1",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                            isDense: true,
                          ),
                          onChanged: (value) => _updateSet(),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Plus button
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline,),
                          color: Colors.orange,
                          iconSize: 24,
                          onPressed: _incrementWeight,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text("kg", style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps Section with +/- buttons
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Minus button
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.orange,
                      iconSize: 24,
                      onPressed: _decrementReps,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),

                    // Reps Input
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "0",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) => _updateSet(),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Plus button
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: Colors.orange,
                        iconSize: 24,
                        onPressed: _incrementReps,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text("reps", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),

          // Check Icon
          SizedBox(
            width: 40,
            child: isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                : const Icon(Icons.circle_outlined, color: Colors.grey, size: 28),
          ),
        ],
      ),
    );
  }
}