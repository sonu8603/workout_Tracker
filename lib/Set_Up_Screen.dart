import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/excersize_day.dart';


class SetUpScreen extends StatelessWidget {
  const SetUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(

          children: [
            Icon(Icons.menu),
            SizedBox(width: 70,),
            
            const Text("Create Your Routine"),
          ],
        ),
        backgroundColor: Colors.deepPurple[300],
        
      ),
      body: ListView.builder(
        itemCount: exerciseProvider.days.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final day = exerciseProvider.days[index];
          final isToday = index == DateTime.now().weekday - 1;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isToday ? Colors.deepPurple : Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(10),
              color: day['enabled'] ? Colors.white : Colors.grey[200],
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
              title: Text(
                day['name'],
                style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
              ),
              subtitle:
              Text(day['enabled'] ? "Add Exercise" : "Rest Day"),
              leading: Text(day['short'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Switch(
                value: day['enabled'],
                onChanged: (value) {
                  exerciseProvider.toggleDay(index, value);
                },
              ),
              onTap: () {
                if (day['enabled']) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddExerciseScreen(day: day['name']),
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
        currentIndex: exerciseProvider.selectedIndex,
        onTap: (index) {
          exerciseProvider.setSelectedIndex(index);

          if (index == 0) {
            final today = exerciseProvider.today;
            if (today['enabled']) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddExerciseScreen(day: today['name']),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${today['name']} is a rest day")),
              );
            }
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Graph clicked")),
            );
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("History clicked")),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Graph"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
