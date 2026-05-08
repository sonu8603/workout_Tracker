import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/core/theme/app_theme.dart';
import 'package:workout_tracker/exercises/exercise_model/exercises_list_model.dart';
import '../services/api_service.dart';

class ShowExercisesScreen extends StatefulWidget {
  final String bodyPart;
  final String? targetDay;

  const ShowExercisesScreen({required this.bodyPart, this.targetDay, super.key});

  @override
  State<ShowExercisesScreen> createState() => _ShowExercisesScreenState();
}

class _ShowExercisesScreenState extends State<ShowExercisesScreen> {
  late Future<List<ExerciseModel>> _futureExercises;
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureExercises = ApiService.getExercisesByPart(widget.bodyPart);
  }

  void _filterSearch(String query) {
    setState(() {
      filteredExercises = allExercises
          .where((ex) => ex.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- WhatsApp Style Dark Bottom Sheet ---
  void _showInstructions(ExerciseModel ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1F2C34), // WhatsApp dark surface color
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white10, height: 30),
            Expanded(
              child: ex.instructions == null || ex.instructions!.isEmpty
                  ? const Text("No instructions available.", style: TextStyle(color: Colors.white60))
                  : ListView.builder(
                itemCount: ex.instructions!.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${i + 1}. ", style: const TextStyle(color: Color(0xFF00A884), fontWeight: FontWeight.bold, fontSize: 16)), // WhatsApp Green Accent
                      Expanded(child: Text(ex.instructions![i], style: const TextStyle(color: Color(0xFFE9EDEF), fontSize: 15, height: 1.4))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

     const accentColor = Color(0xFF00A884); // Teal green accent

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.bodyPart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- Minimalist Search Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search exercises...",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ExerciseModel>>(
              future: _futureExercises,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: accentColor));

                if (allExercises.isEmpty && snapshot.hasData) {
                  allExercises = snapshot.data!;
                  filteredExercises = allExercises;
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final ex = filteredExercises[index];
                    return Card(
                      color: AppColors.cardBg,
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => _showInstructions(ex),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(ex.image, width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_,__,___) => const Icon(Icons.fitness_center, color: Colors.white54)),
                        ),
                        title: Text(ex.name, style: const TextStyle(color: Color(0xFFE9EDEF), fontWeight: FontWeight.w500, fontSize: 15)),
                        subtitle: const Text("Tap for see steps",
                            style: TextStyle(color: Colors.white38, fontSize: 14,fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          onPressed: () => _handleAddToProvider(ex),
                          icon: const Icon(Icons.add_task, color: accentColor, size: 26),
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
    );
  }

  void _handleAddToProvider(ExerciseModel exercise) {
    final provider = Provider.of<ExerciseProvider>(context, listen: false);
    final String dayName = widget.targetDay ?? provider.today.name;
    provider.addExerciseToDay(dayName, exercise.name, 3, DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${exercise.name}"),
        backgroundColor: const Color(0xFF1F2C34),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}