import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Excercise_provider.dart';
import '../models/individual_set.dart';

// Individual Set Row Widget
class RegularSetRow extends StatefulWidget {
  final ExerciseSet set;
  final int exerciseIndex;
  final int setIndex;
  final String dayName;

  const RegularSetRow({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
    required this.dayName,
  });

  @override
  State<RegularSetRow> createState() => _RegularSetRowState();
}

class _RegularSetRowState extends State<RegularSetRow> {
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
    final exerciseProvider = Provider.of<ExerciseProvider>(
        context, listen: false);
    exerciseProvider.updateDayExerciseSet(
      widget.dayName,
      widget.exerciseIndex,
      widget.setIndex,
      weightController.text,
      repsController.text,
    );
  }

  void _incrementWeight() {
    double currentWeight = double.tryParse(weightController.text) ?? 0;
    currentWeight += 0.5;
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

  // ✅ FIXED: Better completion check logic
  bool _isSetCompleted() {
    // Empty check
    if (widget.set.weight.isEmpty || widget.set.reps.isEmpty) {
      return false;
    }

    // Parse values
    final weight = double.tryParse(widget.set.weight);
    final reps = int.tryParse(widget.set.reps);

    // Both must be valid numbers AND greater than 0
    return weight != null &&
        reps != null &&
        weight > 0 &&
        reps > 0;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Use the improved completion check
    bool isCompleted = _isSetCompleted();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Minus button
                        SizedBox(
                          width: 32,
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
                          flex: 3,
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[600]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.black38),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.purple,
                                    width: 2
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                              isDense: true,
                            ),
                            onChanged: (value) => _updateSet(),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Plus button
                        SizedBox(
                          width: 32,
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
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
                        "kg",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700
                        )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

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
                      const SizedBox(width: 2),

                      // Reps Input
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: repsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "0",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7)
                            ),
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
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        "reps",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700
                        )
                    ),
                  ),
                ],
              ),
            ),

            // Check Icon
            SizedBox(
              width: 20,
              child: isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                  : const Icon(Icons.circle_outlined, color: Colors.grey, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}