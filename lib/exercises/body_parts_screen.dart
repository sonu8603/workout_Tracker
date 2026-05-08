import 'package:flutter/material.dart';
import 'package:workout_tracker/core/theme/app_theme.dart';
import 'package:workout_tracker/exercises/exercise_model/body_part.dart';
import 'package:workout_tracker/exercises/show_exercises_screen.dart';
class BodyPartScreen extends StatelessWidget {
  const BodyPartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text("Select Body Part"),
        backgroundColor: AppColors.scaffoldBg,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bodyParts.length,
        itemBuilder: (context, index) {
          final part = bodyParts[index];

          return SingleChildScrollView(
            child: Card(
              color: AppColors.cardBg,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      part.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                title: Expanded(
                  child: Text(
                    part.name,
                    style: const TextStyle(
                      color: Color(0xFFE9EDEF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16,color: Color(0xFFE9EDEF)),

                onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowExercisesScreen(

                     bodyPart: part.name),));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}