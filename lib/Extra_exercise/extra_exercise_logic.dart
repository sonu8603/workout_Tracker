
// Individual Set Row Widget

 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Excercise_provider.dart';

class SetRow extends StatefulWidget {
  final ExerciseSet set;
  final int exerciseIndex;
  final int setIndex;
  final DateTime date;

  const SetRow({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
    required this.date,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
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
    double currentWeight = double.tryParse(weightController.text) ?? 0;
    currentWeight += 0.5; // Increment by 0.5 kg
    weightController.text = currentWeight.toString();
    _updateSet();
  }

  void _decrementWeight() {
    double currentWeight = double.tryParse(weightController.text) ?? 0;
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
    bool isCompleted = widget.set.weight.isNotEmpty &&
        widget.set.reps.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent, // ensures all taps are caught
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
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
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "1",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 8),
                              isDense: true,
                            ),
                            onChanged: (value) => _updateSet(),
                          ),
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
                  const Text(
                      "kg", style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
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
                            border: OutlineInputBorder(borderRadius: BorderRadius
                                .circular(7)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 8),
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
                  const Text(
                      "reps", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),

            // Check Icon
            SizedBox(
              width: 40,
              child: isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                  : const Icon(
                  Icons.circle_outlined, color: Colors.grey, size: 28),
            ),
          ],
        ),
      ),
    );
  }
  }
