import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Providers/Excercise_provider.dart';
import '../models/individual_exercise_model.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String? selectedExercise;
  int selectedSetIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchExercise(String query, ExerciseProvider provider) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Get all unique exercises with actual data
    final Set<String> allExercises = {};

    for (var day in provider.days) {
      for (var exercise in day.exercises) {
        // ✅ ADD THIS: Skip template exercises
        if (exercise.date.year == 2000) continue;

        // Only include if exercise has at least one set with data
        if (exercise.sets.any((s) => s.weight.isNotEmpty || s.reps.isNotEmpty)) {
          allExercises.add(exercise.name);
        }
      }
    }

    // From extra exercises
    final allDates = provider.getAllExtraExerciseDates();
    for (var date in allDates) {
      final exercises = provider.getAllExercisesForDate(date);
      for (var exercise in exercises) {
        if (exercise.sets.any((s) => s.weight.isNotEmpty || s.reps.isNotEmpty)) {
          allExercises.add(exercise.name);
        }
      }
    }

    // Filter by search query
    final results = allExercises
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort();

    setState(() {
      _searchResults = results;
    });

    if (kDebugMode) {
      debugPrint('Search query: $query');
      debugPrint('Results found: ${results.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Tracker"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(provider),

          // Search Results or Selected Exercise
          if (_isSearching && _searchResults.isNotEmpty)
            _buildSearchResults()
          else if (_isSearching && _searchResults.isEmpty)
            _buildNoResults()
          else if (selectedExercise == null)
              Expanded(child: _buildWelcomeScreen())
            else
              Expanded(
                child: Column(
                  children: [
                    _buildSelectedExerciseHeader(),
                    if (selectedExercise != null) _buildSetSelector(provider),
                    Expanded(
                      child: _buildChart(provider, selectedExercise!, selectedSetIndex),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ExerciseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search exercise (e.g., bench press, bicep curl)",
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
                _isSearching = false;
                selectedExercise = null;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.deepPurple.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) => _searchExercise(value, provider),
        onSubmitted: (value) {
          if (_searchResults.length == 1) {
            _selectExercise(_searchResults.first);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final exerciseName = _searchResults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.deepPurple,
                ),
              ),
              title: Text(
                exerciseName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                "Tap to view progress",
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => _selectExercise(exerciseName),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "No exercises found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Try a different search term",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up,
                size: 80,
                color: Colors.deepPurple.shade300,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Track Your Progress",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Search for an exercise above to view\nyour weight and reps progress over time",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.deepPurple, size: 24),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      "Tip: Add weight & reps to track progress",
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedExerciseHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedExercise ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Weight (purple) & Reps (orange)",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedExercise = null;
                selectedSetIndex = 0;
                _searchController.clear();
                _searchResults = [];
                _isSearching = false;
              });
            },
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: "Clear selection",
          ),
        ],
      ),
    );
  }

  void _selectExercise(String exerciseName) {
    setState(() {
      selectedExercise = exerciseName;
      selectedSetIndex = 0;
      _isSearching = false;
      _searchResults = [];
    });

    if (kDebugMode) {
      debugPrint('Selected exercise: $exerciseName');
    }
  }

  Widget _buildSetSelector(ExerciseProvider provider) {
    int maxSets = 0;

    // Check regular weekly exercises
    for (var day in provider.days) {
      final exercises = day.exercises;
      final ex = exercises.where((e) => e.name == selectedExercise).toList();
      if (ex.isNotEmpty) {
        for (var exercise in ex) {
          maxSets = exercise.sets.length > maxSets ? exercise.sets.length : maxSets;
        }
      }
    }

    // Check extra exercises
    final allDates = provider.getAllExtraExerciseDates();
    for (var date in allDates) {
      final exercises = provider.getAllExercisesForDate(date);
      final ex = exercises.where((e) => e.name == selectedExercise).toList();
      if (ex.isNotEmpty) {
        for (var exercise in ex) {
          maxSets = exercise.sets.length > maxSets ? exercise.sets.length : maxSets;
        }
      }
    }

    if (maxSets <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 12),
          const Text(
            "Select Set:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedSetIndex,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                items: List.generate(maxSets, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(
                      "Set ${i + 1}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    selectedSetIndex = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ExerciseProvider provider, String exerciseName, int setIndex) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 60));
    final Map<DateTime, Exercise?> byDate = {};

    // Collect data for last 60 days
    for (int i = 0; i <= 60; i++) {
      final date = start.add(Duration(days: i));
      final exercises = provider
          .getAllExercisesForDate(date)
          .where((e) => e.name == exerciseName)
          .toList();

      if (exercises.isNotEmpty) {
        final ex = exercises.first;
        if (ex.sets.length > setIndex) {
          // Only include if set has data
          final set = ex.sets[setIndex];
          if (set.weight.isNotEmpty || set.reps.isNotEmpty) {
            byDate[date] = ex;
          }
        }
      }
    }

    if (byDate.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                "No data recorded yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Add weight and reps to track progress",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final dates = byDate.keys.toList()..sort();
    final List<FlSpot> weightSpots = [];
    final List<FlSpot> repsSpots = [];

    for (int i = 0; i < dates.length; i++) {
      final ex = byDate[dates[i]]!;
      final s = ex.sets[setIndex];
      final weight = double.tryParse(s.weight) ?? 0;
      final reps = double.tryParse(s.reps) ?? 0;

      weightSpots.add(FlSpot(i.toDouble(), weight));
      repsSpots.add(FlSpot(i.toDouble(), reps));
    }

    final maxY = [
      ...weightSpots.map((e) => e.y),
      ...repsSpots.map((e) => e.y)
    ].reduce((a, b) => a > b ? a : b) * 1.2;

    final chartWidth = dates.length * 60.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Y-axis
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final v = maxY / 5 * i;
                return Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              }).reversed.toList(),
            ),
          ),
          const SizedBox(width: 8),
          // Chart
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: chartWidth,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: dates.length - 1,
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                      getDrawingVerticalLine: (value) =>
                          FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i >= 0 && i < dates.length) {
                              final d = dates[i];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "${d.day}/${d.month}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                        bottom: BorderSide(color: Colors.grey.shade300),
                        top: BorderSide.none,
                        right: BorderSide.none,
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchSpotThreshold: 20,
                      getTouchedSpotIndicator: (barData, spotIndexes) =>
                          spotIndexes.map((i) {
                            return TouchedSpotIndicatorData(
                              FlLine(color: Colors.deepPurple, strokeWidth: 1),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) =>
                                    FlDotCirclePainter(
                                      radius: 5,
                                      color: bar.gradient?.colors.first ?? Colors.deepPurple,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                              ),
                            );
                          }).toList(),
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBorderRadius: BorderRadius.circular(8),
                        tooltipPadding: const EdgeInsets.all(8),
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItems: (spots) {
                          return spots.map((barSpot) {
                            final idx = barSpot.x.toInt();
                            final d = dates[idx];
                            final isWeight = barSpot.barIndex == 0;
                            final label = isWeight ? 'Weight' : 'Reps';
                            return LineTooltipItem(
                              "$label: ${barSpot.y.toStringAsFixed(1)}\n${d.day}/${d.month}/${d.year}",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: weightSpots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade300,
                            Colors.deepPurple.shade600
                          ],
                        ),
                        barWidth: 4,
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: repsSpots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.orange.shade600],
                        ),
                        barWidth: 4,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}