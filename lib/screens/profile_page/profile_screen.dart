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
        title: Text(
          'Go Profile',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),



    );
  }
}
