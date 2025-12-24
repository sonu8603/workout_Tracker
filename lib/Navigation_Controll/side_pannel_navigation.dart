
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/set_up_routein_days.dart';

import '../Providers/Excercise_provider.dart';
import '../excersize_day_screen.dart';
import '../login_sign_up/settingpage.dart';

void showLeftPanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Menu",
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) {
      final provider = Provider.of<ExerciseProvider>(context, listen: false);
      final todayName = provider.today.name;

      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.deepPurple),
                  title: const Text("Edit Exercise"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExerciseScreen(day: todayName),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.deepPurple),
                  title: const Text("edit Routein"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(

                        builder: (context) => SetUpRouteinDays(),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("routein clicked")),
                    );
                  },
                ),




                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(

                        builder: (context) => SettingsPage(),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Settings clicked")),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
                  title: const Text("Help"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Help clicked")),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}