import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Providers/Excercise_provider.dart';
import '../models/individual_exercise_model.dart';
import 'graph_exercise_list.dart';


class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String? selectedExercise;
  int selectedSetIndex = 0; // Track which set user wants to display

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExerciseProvider>(context);

    // Collect unique exercises
    final Set<String> allExercises = {};
    for (var day in provider.days) {
      final exercises = (day['exercises'] as List<Exercise>);
      for (var e in exercises) {
        allExercises.add(e.name);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Tracker"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: allExercises.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          GraphExerciseListView(
            onExerciseSelected: (exercise) {
              setState(() {
                selectedExercise = exercise;
                selectedSetIndex = 0; // reset to first set
              });
            },
          ),
          if (selectedExercise != null) _buildSetSelector(provider),
          Expanded(
            child: selectedExercise == null
                ? _buildSelectPrompt()
                : _buildChart(provider, selectedExercise!, selectedSetIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildSetSelector(ExerciseProvider provider) {
    // Find the maximum number of sets for this exercise
    int maxSets = 0;
    for (var day in provider.days) {
      final exercises = (day['exercises'] as List<Exercise>);
      final ex = exercises.where((e) => e.name == selectedExercise).toList();
      if (ex.isNotEmpty) {
        maxSets = ex.first.sets.length > maxSets ? ex.first.sets.length : maxSets;
      }
    }

    if (maxSets <= 1) return const SizedBox.shrink(); // No need for selector

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text("Select Set: ", style: TextStyle(fontSize: 16)),
          DropdownButton<int>(
            value: selectedSetIndex,
            items: List.generate(maxSets, (i) {
              return DropdownMenuItem(
                value: i,
                child: Text("Set ${i + 1}"),
              );
            }),
            onChanged: (value) {
              setState(() {
                selectedSetIndex = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No exercise data yet",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Add exercises to see your progress",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSelectPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 100, color: Colors.deepPurple[100]),
          const SizedBox(height: 24),
          const Text(
            "Select an exercise to view your progress",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ExerciseProvider provider, String exerciseName, int setIndex) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 60));
    final Map<DateTime, Exercise?> byDate = {};

    // Collect only the selected set for each date
    for (int i = 0; i <= 60; i++) {
      final date = start.add(Duration(days: i));
      final exercises = provider
          .getAllExercisesForDate(date)
          .where((e) => e.name == exerciseName)
          .toList();
      if (exercises.isNotEmpty) {
        final ex = exercises.first;
        if (ex.sets.length > setIndex) {
          byDate[date] = ex; // store exercise if set exists
        }
      }
    }

    if (byDate.isEmpty) {
      return const Center(
        child: Text("No data recorded yet for this exercise",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    final dates = byDate.keys.toList()..sort();
    final List<FlSpot> weightSpots = [];
    final List<FlSpot> repsSpots = [];

    for (int i = 0; i < dates.length; i++) {
      final ex = byDate[dates[i]]!;
      final s = ex.sets[setIndex]; // get selected set
      final weight = double.tryParse(s.weight) ?? 0;
      final reps = double.tryParse(s.reps) ?? 0;

      weightSpots.add(FlSpot(i.toDouble(), weight));
      repsSpots.add(FlSpot(i.toDouble(), reps));
    }

    final maxY = [
      ...weightSpots.map((e) => e.y),
      ...repsSpots.map((e) => e.y)
    ].reduce((a, b) => a > b ? a : b) *
        1.2;

    final chartWidth = dates.length * 60.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(exerciseName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Text("Weight (purple) & Reps (orange)",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // Fixed Y-axis
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      final v = maxY / 5 * i;
                      return Text(v.toInt().toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.grey));
                    }).reversed.toList(),
                  ),
                ),
                const SizedBox(width: 8),
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
                                      child: Text("${d.day}/${d.month}",
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey)),
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
                            getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((i) {
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
                                    "$label: ${barSpot.y.toStringAsFixed(1)}",
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
                              gradient: LinearGradient(colors: [
                                Colors.deepPurple.shade300,
                                Colors.deepPurple.shade600
                              ]),
                              barWidth: 4,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: repsSpots,
                              isCurved: true,
                              gradient: LinearGradient(colors: [
                                Colors.orange.shade300,
                                Colors.orange.shade600
                              ]),
                              barWidth: 4,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
