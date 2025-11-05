

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Excercise_provider.dart';


void showAddExerciseDialog(BuildContext context, DateTime date) {
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