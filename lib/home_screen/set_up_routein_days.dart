import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/home_screen/addexcersize_day_screen.dart';
import 'package:workout_tracker/home_screen/home_screen.dart';

import '../Navigation_Controll/navigation_controll.dart';
import '../Navigation_Controll/side_pannel_navigation.dart';


class SetUpRouteinDays extends StatelessWidget {
  final bool fromSignup;

  const SetUpRouteinDays({super.key, this.fromSignup=false});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 40,),
            const Text("Create Your Routine"),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                    color: day.enabled ? Colors.white : Colors.grey[200],
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
                      day.name,
                      style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle:
                    Text(day.enabled ? "Add Exercise" : "Rest Day"),
                    leading: Text(day.short,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Switch(
                      value: day.enabled,
                      onChanged: (value) {
                        exerciseProvider.toggleDay(index, value);
                      },
                    ),
                    onTap: () {
                      if (day.enabled) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddExerciseScreen(day: day.name),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${day.name} is a rest day")),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),

          if (fromSignup) ...[

            Padding(
              padding: const EdgeInsets.only(bottom: 60, top: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NavigationRoutePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ],
      ),
    );
  }
}