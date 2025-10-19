import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_tracker/Navigation_Controll/navigation_controll.dart'; // CHANGED THIS
import 'package:workout_tracker/login_sign_up/signup_screen.dart';


class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool passToggle = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Image.asset(
                        "assets/images/welcomescreen.png",
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        label: const Text("Enter Username"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),

                  // Password field
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        label: const Text("Enter password"),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                          child: passToggle
                              ? const Icon(CupertinoIcons.eye_slash_fill)
                              : const Icon(CupertinoIcons.eye_fill),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  Material(
                    color: const Color(0xFF7165D6),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        // CHANGED: Navigate to NavigationRoutePage instead of HomeScreen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationRoutePage()), // CHANGED THIS LINE
                              (route) => false,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have any account ?",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()),
                                (route) => false,
                          );
                        },
                        child: const Text(
                          "(Signup)",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )));
  }
}