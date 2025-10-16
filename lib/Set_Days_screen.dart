import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'excersize_day_screen.dart';


class SetDaysScreen extends StatelessWidget {
  const SetDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dayProvider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your  Routine"),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: ListView.builder(
        itemCount: dayProvider.days.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final day = dayProvider.days[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple, width: 1.5),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text(day['name']),
              subtitle: Text(day['enabled'] ? "Add Exercise" : "Rest Day"),
              leading: Text(day['short'], style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Switch(
                value: day['enabled'],
                onChanged: (value) {
                  dayProvider.toggleDay(index, value);
                },
              ),
              onTap: () {
                if (day['enabled']) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExerciseScreen(day: day['name']),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${day['name']} is a rest day")),
                  );
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dayProvider.selectedIndex,
        onTap: (index) {
          dayProvider.setSelectedIndex(index);

          if (index == 0) {
            // Today
            final today = dayProvider.today;
            if (today['enabled']) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExerciseScreen(day: today['name']),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${today['name']} is a rest day")),
              );
            }
          } else if (index == 1) {
            // Graph
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Graph/Stats clicked")),
            );
          } else if (index == 2) {
            // History
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("History clicked")),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: "Today",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Graph",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}
