import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';

class AddExerciseScreen extends StatefulWidget {
  final String day;
  const AddExerciseScreen({super.key, required this.day});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime get _normalizedDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.day} Exercises"),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text input
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Exercise Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: (value) => _handleAddExercise(value),
              ),
              const SizedBox(height: 20),

              // Add button
              ElevatedButton(
                onPressed: () => _handleAddExercise(_controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text("Add", style:TextStyle(fontSize:15, color: Colors.white)),
              ),
              const SizedBox(height: 20),

              // Exercise list
              Expanded(
                child: Consumer<ExerciseProvider>(
                  builder: (context, provider, _) {
                    final exercises = provider.getExercisesForDay(widget.day);

                    if (exercises.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No exercises added yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add your first exercise above",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ListTile(

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              exercise.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "${exercise.sets.length} sets",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Colors.blue,
                                  onPressed: () {
                                    _showEditDialog(context, exercise.name, index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  onPressed: () => _handleDeleteExercise(
                                    context,
                                    provider,
                                    exercise.name,
                                    index,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddExercise(String value) async {
    final text = value.trim();

    if (text.isEmpty) {
      _showSnackBar(
        "Please enter an exercise name!",
        Colors.orange,
      );
      return;
    }

    final provider = Provider.of<ExerciseProvider>(context, listen: false);

    // Debug logs (only in debug mode)
    if (kDebugMode) {
      debugPrint('Adding exercise: $text');
      debugPrint('Day: ${widget.day}');
      debugPrint('Date: $_normalizedDate');
    }

    final success = await provider.addExerciseToDay(
      widget.day,
      text,
      3,
      _normalizedDate,
    );

    if (kDebugMode) {
      debugPrint('Success: $success');
      if (!success) debugPrint('Error: ${provider.lastError}');
    }

    if (!mounted) return;

    if (success) {
      _controller.clear();
      _showSnackBar("✓ Added: $text", Colors.green);
    } else {
      _showSnackBar(
        provider.lastError ?? "Failed to add exercise",
        Colors.red,
      );
    }
  }

  Future<void> _handleDeleteExercise(
      BuildContext context,
      ExerciseProvider provider,
      String exerciseName,
      int index,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Delete Exercise?"),
        content: Text(
          "Remove \"$exerciseName\"?\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.removeDayExercise(widget.day, index);

      if (kDebugMode) {
        debugPrint('Delete result: $success');
      }

      if (success && mounted) {
        _showSnackBar("Exercise deleted", Colors.orange);
      }
    }
  }

  void _showEditDialog(BuildContext context, String currentName, int index) {
    final controller = TextEditingController(text: currentName);
    final provider = Provider.of<ExerciseProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Edit Exercise Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Exercise Name",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fitness_center),
          ),
          autofocus: true,
          onSubmitted: (value) {
            // Also save on Enter key
            if (value.trim().isNotEmpty) {
              _saveEditedExercise(context, controller, provider, index);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _saveEditedExercise(context, controller, provider, index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEditedExercise(
      BuildContext dialogContext,
      TextEditingController controller,
      ExerciseProvider provider,
      int index,
      ) async {
    final newName = controller.text.trim();

    if (newName.isEmpty) {
      _showSnackBar("Please enter an exercise name!", Colors.orange);
      return;
    }

    if (kDebugMode) {
      debugPrint('Editing exercise at index $index');
      debugPrint('New name: $newName');
    }

    //  Direct update - much faster!
    final success = await provider.updateExerciseName(
      widget.day,
      index,
      newName,
    );

    if (kDebugMode) {
      debugPrint('Edit result: $success');
    }

    Navigator.pop(dialogContext);

    if (mounted) {
      if (success) {
        _showSnackBar("✓ Exercise updated!", Colors.green);
      } else {
        _showSnackBar(
          provider.lastError ?? "Failed to update exercise",
          Colors.red,
        );
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}