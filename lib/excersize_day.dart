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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.day} Exercises"),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Exercise Name",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Provider.of<ExerciseProvider>(context, listen: false)
                      .addExerciseToDay(widget.day, value);
                  _controller.clear();
                }
              },
            ),
            const SizedBox(height: 10),

            // Add button
            ElevatedButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  Provider.of<ExerciseProvider>(context, listen: false)
                      .addExerciseToDay(widget.day, text);
                  _controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Icon(Icons.add,size: 30,),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Consumer<ExerciseProvider>(
                builder: (context, provider, _) {
                  final exercises = provider.getExercisesOfDay(widget.day);

                  if (exercises.isEmpty) {
                    return const Center(
                      child: Text("No exercises added yet"),
                    );
                  }

                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple[300],
                          child: Text("${index + 1}"),
                        ),
                       title: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(exercises[index]),
                            Text("Sets"),
                           Text("Reps"),
                         ],
                       ),
                       // title: Text(exercises[index]),
                      );
                    },
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
