import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/excersize_day.dart';


class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return BottomNavigationBar(
      currentIndex: exerciseProvider.selectedIndex,
      onTap: (index) {
        exerciseProvider.setSelectedIndex(index);

        // if (index == 0) {
        //   final today = exerciseProvider.today;
        //   if (today['enabled']) {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => AddExerciseScreen(day: today['name']),
        //       ),
        //     );
        //   } else {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text("${today['name']} is a rest day")),
        //     );
        //   }
          if (index == 1) {
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
    );
  }
}
