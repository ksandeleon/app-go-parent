import 'package:flutter/material.dart';
import 'package:go_parent/screens/profile_page/profile_brain.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static String id = "profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late ProfileBrain profileBrain;
  Color colorbeige = Color(0xFFF2EFE7);


  @override
  void initState() {
    super.initState();

    initProfileBrain();
  }


  void initProfileBrain () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbService = DatabaseService.instance;
    final db = await dbService.database;

    final babyHelper = BabyHelper(db);
    final userHelper = UserHelper(db);

    profileBrain = ProfileBrain(userHelper, babyHelper);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Go Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),

      body: SingleChildScrollView(
        child:Column(
          children: [

            // Parent Profile Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              //color: Colors.teal[200],
              decoration: BoxDecoration(

                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // icon user

                  Icon(Icons.family_restroom,
                  size: 120,),

                  SizedBox(height: 16),


                  // Parent Name
                  Text(
                    'Hero',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),

            Card(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Container(
                        color: Colors.green
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Container(
                        color: Colors.blue
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Container(
                        color: Colors.red
                      ),
                    ),
                    SizedBox(
                      height: 800,
                      child: Container(
                        color: Colors.yellow
                      ),
                    )
                  ],
                ),
              ),
            )



          ],
        )


        ,
      )

    );
  }
}
