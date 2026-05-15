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

class _ShowExercisesScreenState extends State<ShowExercisesScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<List<ExerciseModel>> _futureExercises;
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

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
            const Divider(color: Colors.black12, height: 30),
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
    super.build(context);

     const accentColor = Color(0xFF00A884); // Teal green accent

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: widget.bodyPart == 'cardio'
          ? null
          : AppBar(
        title: Text(widget.bodyPart[0].toUpperCase() + widget.bodyPart.substring(1),
          style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500),),
        backgroundColor: AppColors.scaffoldBg,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // --- Minimalist Search Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search exercises...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),

                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 22,
                ),

                filled: true,
                fillColor: const Color(0xFFF5F5F7),

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),


                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.black38,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
          child:  FutureBuilder<List<ExerciseModel>>(
              future: _futureExercises,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: accentColor));
                }

                // 2. Error State (API Exception handling)
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                          const SizedBox(height: 10),
                          Text(
                            "Error: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black38, fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _futureExercises = ApiService.getExercisesByPart(widget.bodyPart);
                            }),
                            child: const Text("Retry", style: TextStyle(color: accentColor)),
                          )
                        ],
                      ),
                    ),
                  );
                }

                // 3. Data Loaded Logic
                if (allExercises.isEmpty && snapshot.hasData) {
                  allExercises = snapshot.data!;
                  filteredExercises = allExercises;
                }

                // 4. Empty List State (Jab body part ki exercise na ho)
                if (filteredExercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, color: Colors.black38, size: 60),
                        const SizedBox(height: 10),
                        Text(
                          "No exercises found for ${widget.bodyPart}",
                          style: const TextStyle(color: Colors.black38, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // 5. Success State (List dikhao)
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
                              errorBuilder: (_,__,___) => const Icon(Icons.fitness_center, color: Colors.black38)),
                        ),
                        title: Text(ex.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17)),
                        subtitle: const Text("Tap for see steps",
                            style: TextStyle(color: Colors.black87, fontSize: 14,fontWeight: FontWeight.bold)),
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