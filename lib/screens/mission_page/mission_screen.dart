import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:go_parent/Screen/prototypeMissionGraph.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/missions_helper.dart';
import 'package:go_parent/services/database/local/models/baby_model.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'widgets/tab_controller.dart';
import 'package:go_parent/screens/mission_page/mission_brain.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});
  static String id = "mission_screen";

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  double progress = 0;
  int totalPoints = 0;

  List<DropdownMenuEntry<int>> dropdownItems = [];
  int? _selectedBabyAge;
  List<MissionModel> _missions = [];
  late MissionBrain _missionBrain;
  bool _isLoading = true;
  String? photoPath;


  @override
  void initState() {
    super.initState();
    _initializeMissionBrain();
  }

  Future<void> _initializeMissionBrain() async {
    // Initialize database
    final db = await openDatabase('goparent_v2.db');
    final missionHelper = MissionHelper(db);
    final babyHelper = BabyHelper(db);

    _missionBrain = MissionBrain(missionHelper, babyHelper);

    await _loadMissions();
    await  _fetchBabiesAndSetupDropdown();
  }


  Future<void> _fetchBabiesAndSetupDropdown() async {
    setState(() => _isLoading = true);
    try {
      List<BabyModel> babies = await _missionBrain.getBabiesForUser();
      if (babies.isEmpty) {
        print("No babies found for user");
        setState(() {
          dropdownItems = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        dropdownItems = babies
            .map((baby) => DropdownMenuEntry<int>(
                  value: baby.babyAge,
                  label: baby.babyName,
                ))
            .toList();
        // Set initial selected age
        _selectedBabyAge = babies.first.babyAge;
      });

      // Fetch initial missions
      await _fetchMissions();
    } catch (e) {
      print('Error setting up dropdown: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMissions() async {
    if (_selectedBabyAge == null) return;

    setState(() => _isLoading = true);
    try {
      await _missionBrain.getMissionsByAge(_selectedBabyAge!);
      setState(() {
        _missions = _missionBrain.missions;  // Assuming you have a getter for missions
      });
    } catch (e) {
      print('Error fetching missions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _missionBrain.loadAllMissions();
      print("Missions loaded successfully");
    } catch (e) {
      print("Error loading missions: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }



//experiments below until build







  // void _completeMission(int missionIndex) {
  //   setState(() {
  //     _missionCompleted[missionIndex] = true;
  //     _missions[missionIndex]['isCompleted'] = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu<int>(
                  dropdownMenuEntries: dropdownItems,
                  initialSelection: _selectedBabyAge,
                  onSelected: (int? age) async {
                    setState(() => _selectedBabyAge = age);
                    await _fetchMissions();
                  },
                ),
              ),


        Text("data"),
        Expanded(
          child: DefaultTabController(
            length: 1,
            child: Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                elevation: 8,
                backgroundColor: Colors.teal,
                title: const Text('Go Missions'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Missions'),
                  ],
                ),
              ),
              body: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      Column(
                        children: [
                          _missions.isEmpty
                              ? const Center(child: Text('No missions available'))
                              : MissionList(onPhotoSubmit: _missionBrain.takePhotoOrPickFile ,missions: _missions),
                        ],
                      ),
                    ],
                  ),
            ),
          ),

        ),
      ],
    );
  }
}


class MissionList extends StatelessWidget {
  final List<MissionModel> missions;
  final void Function() onPhotoSubmit;

  const MissionList({
    Key? key,
    required this.missions,
    required this.onPhotoSubmit,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add this debug print
    print("Building MissionList with ${missions.length} missions");

    if (missions.isEmpty) {
      return const Center(
        child: Text('No missions available'),
      );
    }

    return Expanded(

      child: ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          if (mission == null) {
            print("Null mission at index $index");
            return const SizedBox.shrink();
          }

          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), ),
            margin: const EdgeInsets.all(10.0),

            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ListTile(
                    title: Text(mission.title ,
                          style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    subtitle: Text(mission.content,
                    style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,), ),
                    trailing: Icon(
                      mission.isCompleted ? Icons.circle_outlined : Icons.check_circle ,
                      color: mission.isCompleted ? Colors.green : Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => onPhotoSubmit(),
                      icon: const Icon(Icons.camera_alt, color: Colors.white,),
                      label: const Text('Submit Photo',  style: TextStyle(color: Colors.white),),
                    ),

                ],
              ),
            ),
          );
        },
      ),
    );


  }
}
