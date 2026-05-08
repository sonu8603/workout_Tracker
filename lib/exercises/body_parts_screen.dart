import 'package:flutter/material.dart';
import 'package:workout_tracker/core/theme/app_theme.dart';
import 'package:workout_tracker/exercises/exercise_model/body_part.dart';
import 'package:workout_tracker/exercises/show_exercises_screen.dart';

class BodyPartScreen extends StatefulWidget {
  const BodyPartScreen({super.key});

  @override
  State<BodyPartScreen> createState() => _BodyPartScreenState();
}

class _BodyPartScreenState extends State<BodyPartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 0 = Strength, 1 = Cardio
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text("Training Type"),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.surfaceDark,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: "Strength", icon: Icon(Icons.fitness_center)),
            Tab(text: "Cardio", icon: Icon(Icons.directions_run)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBodyPartList(bodyParts, context, AppColors.textPrimary),
          ShowExercisesScreen(bodyPart: 'cardio'),
        ],
      ),
    );
  }

  Widget _buildBodyPartList(List<BodyPart> parts, BuildContext context, Color textColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parts.length,
      itemBuilder: (context, index) {
        final part = parts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05), // Subtle border for dark mode
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                part.image,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              part.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textPrimary,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowExercisesScreen(bodyPart: part.name),
                ),
              );
            },
          ),
        );
      },
    );
  }
}