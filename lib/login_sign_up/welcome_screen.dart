
import 'package:flutter/material.dart';
import 'package:workout_tracker/login_sign_up/signup_screen.dart';

import 'logIn_screen.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Material(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height:15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top:15,right: 8),
                    child: Text("SKIP",
                      style: TextStyle(color: Color(0xFF7165D6),fontSize: 16,fontWeight: FontWeight.bold),

                    ),
                  ),

                ),
              ),
              SizedBox(height:50),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset("assets/images/welcomescreen.png"),
              ),
              SizedBox(height:50),
              Text("Welcome To GYM",
                style: TextStyle(color: Color(0xFF7165D6),fontSize: 35,fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    wordSpacing: 2),

              ),

              SizedBox(height:20),
              Text(" Get ready to Fight",
                style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    wordSpacing: 2),

              ),
              SizedBox(height:60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Material(
                    color: Color(0xFF7165D6),
                    borderRadius: BorderRadius.circular(10),
                    child:InkWell(
                      onTap: (){

                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LogInScreen()),);
                      },
                      child:Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 15),
                        child: Text("Log In",
                            style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold,)
                        ),
                      ),

                    ),
                  ),

                  // sign up
                  Material(
                    color: Color(0xFF7165D6),
                    borderRadius: BorderRadius.circular(10),
                    child:InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpScreen()),);
                      },
                      child:Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 15),
                        child: Text("Sign Up",
                            style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold,)
                        ),
                      ),

                    ),
                  ),
                ],
              )

            ],
          ),


        )
    );
  }
}
