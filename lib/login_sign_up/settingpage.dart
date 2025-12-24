
import 'package:flutter/material.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7165D6),
        iconTheme: const IconThemeData(
          color: Colors.white, //    Back arrow color white
        ),
        title:  Text(
          "Setting",
          style: TextStyle(fontSize:25,fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height:20),
              ListTile(
                onTap: (){},
                leading: Container(
                  padding: EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person,size: 35,),

                ),
                title: Text("Profile",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                subtitle: Text("view and edit profile"),
                trailing: Icon(Icons.arrow_forward_ios_rounded,),

              ),
              SizedBox(height:30),

              // privacy
              ListTile(
                onTap: (){},
                leading: Container(
                  padding: EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.privacy_tip,size: 35,),

                ),
                title: Text("privacy and security",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                trailing: Icon(Icons.arrow_forward_ios_rounded,),

              ),
              SizedBox(height:30),

              // General
              ListTile(
                onTap: (){},
                leading: Container(
                  padding: EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline_rounded,size: 35,),

                ),
                title: Text("personal detail",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                trailing: Icon(Icons.arrow_forward_ios_rounded,),

              ),

              SizedBox(height:30),
              // security

              ListTile(
                onTap: (){},
                leading: Container(
                  padding: EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout,size: 35,),

                ),
                title: Text("log out",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                trailing: Icon(Icons.arrow_forward_ios_rounded,),

              ),


            ],
          ),
        ),
      ),
    );
  }
}
