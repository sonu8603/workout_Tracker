import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_tracker/home_screen.dart';
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

        child:SingleChildScrollView(
            child:SafeArea(
              child: Column(
                children: [
                  SizedBox(height:10),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset("assets/images/welcomeimage.png"),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        label: Text("Enter Username"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),

                  ),


                  // for password

                  Padding(
                    padding: const EdgeInsets.all(15),
                    // Password field
                    child:TextField(
                      controller: _passwordController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        label: Text("Enter password"),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                          child: passToggle
                              ? Icon(CupertinoIcons.eye_slash_fill)
                              : Icon(CupertinoIcons.eye_fill),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),

                  ),
                  SizedBox(
                    height:20,
                  ),
                  // login button
                  Material(
                    color: Color(0xFF7165D6),
                    borderRadius: BorderRadius.circular(10),
                    child:InkWell(
                      onTap: (){

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );

                      },
                      child:Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 15),
                        child: Text("Log In",
                            style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold,)
                        ),
                      ),

                    ),
                  ),
                  SizedBox(
                    height:20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have any account ?",
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,)),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()),);
                      },
                        child: Text("(Signup)",  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,)),
                      )
                    ],
                  )
                ],
              ),

            )
        )
    );
  }
}