import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/Providers/Excercise_provider.dart';
import 'package:workout_tracker/home_screen/addexcersize_day_screen.dart';

import '../Navigation_Controll/navigation_controll.dart';

class SetUpRouteinDays extends StatelessWidget {
  final bool fromSignup;

  const SetUpRouteinDays({super.key, this.fromSignup = false});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            SizedBox(width: 40),
            Text("Create Your Routine"),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: Column(
        children: [

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Set up your weekly routine template. These won't appear in history until you actually perform them.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                        color: isToday ? Colors.deepPurple : Colors.grey,
                        width: 1.5),
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
                          fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle: Text(day.enabled
                        ? "${day.exercises.length} exercises"
                        : "Rest Day"),
                    leading: Text(day.short,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Switch(
                      value: day.enabled,
                      onChanged: (value) {
                        exerciseProvider.toggleDay(index, value);
                      },
                    ),
                    // onTap: () {
                    //   if (day.enabled) {
                    //
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => AddExerciseScreen(
                    //           day: day.name,
                    //           isRoutineSetup: true,
                    //         ),
                    //       ),
                    //     );
                    //   } else {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //           content: Text("${day.name} is a rest day")),
                    //     );
                    //   }
                    // },
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
                    MaterialPageRoute(
                        builder: (context) => const NavigationRoutePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text(
                  "Start Training",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}