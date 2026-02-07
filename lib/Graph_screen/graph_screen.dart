import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Providers/Excercise_provider.dart';
import '../models/individual_set.dart';

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

  // ===================== SEARCH LOGIC =====================

  void _searchExercise(String query, ExerciseProvider provider) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final Set<String> allExercises = {};

// Weekly exercises
    for (var day in provider.days) {
      for (var ex in day.exercises) {
        if (ex.date.year == 2000) continue;
        if (ex.sets.any((s) => s.weight.isNotEmpty || s.reps.isNotEmpty)) {
          allExercises.add(ex.name);
        }
      }
    }

// Extra exercises
    final extraDates = provider.getAllExtraExerciseDates();
    for (var date in extraDates) {
      for (var ex in provider.getAllExercisesForDate(date)) {
        if (ex.sets.any((s) => s.weight.isNotEmpty || s.reps.isNotEmpty)) {
          allExercises.add(ex.name);
        }
      }
    }


    // Workout logs (if you have them)
    final logDates = provider.getAllWorkoutLogDates();
    for (var date in logDates) {
      final logs = provider.getWorkoutLogsForDate(date);
      for (var log in logs) {
        for (var ex in log.exercises) {
          allExercises.add(ex.name);
        }
      }
    }



    final results = allExercises
        .where((e) => e.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort();

    setState(() => _searchResults = results);
  }

  // UI  part

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Tracker"),
        automaticallyImplyLeading: false,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        backgroundColor: Colors.deepPurple,


      ),
      body: Column(
        children: [
          _buildSearchBar(provider),

          if (_isSearching && _searchResults.isNotEmpty)
            _buildSearchResults()
          else if (_isSearching && _searchResults.isEmpty)
            _buildNoResults()
          else if (selectedExercise == null)
              Expanded(child: _buildWelcome())
            else
              Expanded(
                child: Column(
                  children: [
                    _buildSelectedHeader(),
                    _buildSetSelector(provider),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search exercise (e.g., bench press)",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
        ),
        onChanged: (v) => _searchExercise(v, provider),
        onSubmitted: (v) {
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
        padding: const EdgeInsets.all(12),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final name = _searchResults[index];
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(name),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _selectExercise(name),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return const Expanded(
      child: Center(child: Text("No exercises found")),
    );
  }

  Widget _buildWelcome() {
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
                  const Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Complete workouts and use 'Finish' to track progress",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
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



  Widget _buildSelectedHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedExercise ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                selectedExercise = null;
                selectedSetIndex = 0;
                _searchController.clear();
                _searchResults = [];
                _isSearching = false;
              });
            },
          )
        ],
      ),
    );
  }

  void _selectExercise(String name) {
    setState(() {
      selectedExercise = name;
      selectedSetIndex = 0;
      _isSearching = false;
      _searchResults = [];
    });
  }


  Widget _buildSetSelector(ExerciseProvider provider) {
    int maxSets = 0;

    // Weekly
    for (var day in provider.days) {
      for (var ex in day.exercises.where((e) => e.name == selectedExercise)) {
        maxSets = ex.sets.length > maxSets ? ex.sets.length : maxSets;
      }
    }

    // Extra
    final extraDates = provider.getAllExtraExerciseDates();
    for (var date in extraDates) {
      for (var ex in provider
          .getAllExercisesForDate(date)
          .where((e) => e.name == selectedExercise)) {
        maxSets = ex.sets.length > maxSets ? ex.sets.length : maxSets;
      }
    }

    if (maxSets <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text("Set: "),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: selectedSetIndex,
            items: List.generate(
              maxSets,
                  (i) => DropdownMenuItem(value: i, child: Text("Set ${i + 1}")),
            ),
            onChanged: (v) => setState(() => selectedSetIndex = v!),
          ),
        ],
      ),
    );
  }


  Widget _buildChart(
      ExerciseProvider provider, String exerciseName, int setIndex) {

    final Map<DateTime, ExerciseSet> byDate = {};

    // Weekly
    for (var day in provider.days) {
      for (var ex in day.exercises.where((e) => e.name == exerciseName)) {
        if (ex.sets.length > setIndex) {
          final s = ex.sets[setIndex];
          if (s.weight.isNotEmpty || s.reps.isNotEmpty) {
            byDate[ex.date] = s;
          }
        }
      }
    }

    // Extra
    final extraDates = provider.getAllExtraExerciseDates();
    for (var date in extraDates) {
      for (var ex in provider
          .getAllExercisesForDate(date)
          .where((e) => e.name == exerciseName)) {
        if (ex.sets.length > setIndex) {
          final s = ex.sets[setIndex];
          if (s.weight.isNotEmpty || s.reps.isNotEmpty) {
            byDate[date] = s;
          }
        }
      }
    }

    // Workout logs (if exists)
    final logDates = provider.getAllWorkoutLogDates();
    for (var date in logDates) {
      final logs = provider.getWorkoutLogsForDate(date);
      for (var log in logs) {
        for (var ex in log.exercises.where((e) => e.name == exerciseName)) {
          if (ex.sets.length > setIndex) {
            final s = ex.sets[setIndex];
            byDate[date] = s; // workout logs already contain completed sets
          }
        }
      }
    }

    if (byDate.isEmpty) {
      return const Center(child: Text("No data yet"));
    }

    final dates = byDate.keys.toList()..sort();
    final List<FlSpot> weightSpots = [];
    final List<FlSpot> repsSpots = [];

    for (int i = 0; i < dates.length; i++) {
      final s = byDate[dates[i]]!;
      final weight = double.tryParse(s.weight) ?? 0;
      final reps = double.tryParse(s.reps) ?? 0;

      weightSpots.add(FlSpot(i.toDouble(), weight));
      repsSpots.add(FlSpot(i.toDouble(), reps));
    }

    final maxY = [
      ...weightSpots.map((e) => e.y),
      ...repsSpots.map((e) => e.y),
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
                          if (spots.isEmpty) return [];

                          final idx = spots.first.x.toInt();
                          final d = dates[idx];

                          return spots.asMap().entries.map((entry) {
                            final i = entry.key;
                            final barSpot = entry.value;

                            final isWeight = barSpot.barIndex == 0;
                            final label = isWeight ? 'Weight' : 'Reps';


                            final text = i == 0
                                ? "${d.day}/${d.month}/${d.year}\n$label: ${barSpot.y.toStringAsFixed(1)}"
                                : "$label: ${barSpot.y.toStringAsFixed(1)}";

                            return LineTooltipItem(
                              text,
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