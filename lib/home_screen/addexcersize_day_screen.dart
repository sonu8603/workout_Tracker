import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/Excercise_provider.dart';

class AddExerciseScreen extends StatefulWidget {
  final String day;
  final bool isRoutineSetup;

  const AddExerciseScreen({
    super.key,
    required this.day,
    this.isRoutineSetup = false,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _exerciseController = TextEditingController();

  @override
  void dispose() {
    _exerciseController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final exerciseName = _exerciseController.text.trim();
    const sets = 3;

    if (exerciseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter exercise name")),
      );
      return;
    }

    final provider = Provider.of<ExerciseProvider>(context, listen: false);


    final DateTime dateToUse;
    if (widget.isRoutineSetup) {
      dateToUse = DateTime(2000, 1, 1); // Template date - won't show in history
    } else {
      dateToUse = DateTime.now(); // Actual workout date
    }

    provider.addExerciseToDay(
      widget.day,
      exerciseName,
      sets,
      dateToUse,
    );

    // Clear input
    _exerciseController.clear();

    // Success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isRoutineSetup
              ? "Added to ${widget.day} routine"
              : "Exercise logged for ${widget.day}",
        ),
        backgroundColor: widget.isRoutineSetup ? Colors.blue : Colors.deepPurple,
      ),
    );
  }

  //  Edit Exercise Name Dialog
  void _showEditDialog(BuildContext context, ExerciseProvider provider, String currentName, int index) {
    final TextEditingController editController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Exercise Name"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: "Exercise Name",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fitness_center),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () {
              editController.dispose();
              Navigator.pop(ctx);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = editController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                provider.updateExerciseName(widget.day, index, newName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Updated to: $newName"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              editController.dispose();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);
    final dayExercises = provider.getExercisesForDay(widget.day);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 23),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Info banner only during routine setup
            if (widget.isRoutineSetup)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Setting up your routine template",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Exercise Name Input
            TextField(
              controller: _exerciseController,
              decoration: const InputDecoration(
                labelText: "Exercise Name",
                hintText: "e.g., Bench Press",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                prefixIcon: Icon(Icons.fitness_center),
                helperText: "Default: 3 sets (add more from home screen)",
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              onSubmitted: (_) => _addExercise(),
            ),
            const SizedBox(height: 20),

            // Add Button
            ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add, color: Colors.white), // ✅ White icon
              label: const Text(
                "Add Exercise",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Exercise List Header
            if (dayExercises.isNotEmpty)
              Text(
                "Exercises (${dayExercises.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),

            // Exercise List
            Expanded(
              child: dayExercises.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "No exercises added yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: dayExercises.length,
                itemBuilder: (context, index) {
                  final exercise = dayExercises[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("${exercise.sets.length} sets"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _showEditDialog(context, provider, exercise.name, index);
                            },
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Exercise?"),
                                  content: Text(
                                      "Remove ${exercise.name} from ${widget.day}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.removeDayExercise(
                                            widget.day, index);
                                        Navigator.pop(ctx);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}