import 'package:flutter/material.dart';
import 'package:go_parent/Screen/prototypeMissionGraph.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/missions_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_mission_helper.dart';
import 'package:go_parent/services/database/local/models/baby_model.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbService = DatabaseService.instance;
    final db = await dbService.database;

    final missionHelper = MissionHelper(db);
    final babyHelper = BabyHelper(db);
    final pictureHelper = PictureHelper(db);
    final userMissionHelper = UserMissionHelper();

    _missionBrain = MissionBrain(missionHelper, babyHelper, pictureHelper, userMissionHelper);

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
      // await _missionBrain.loadAllMissions();
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


  // void _completeMission(int missionIndex) {
  //   setState(() {
  //     _missionCompleted[missionIndex] = true;
  //     _missions[missionIndex]['isCompleted'] = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Missions'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownMenu<int>(
                  dropdownMenuEntries: dropdownItems,
                  initialSelection: _selectedBabyAge,
                  onSelected: (int? age) async {
                    setState(() => _selectedBabyAge = age);
                    await _fetchMissions();
                  },
                ),
              ),

              Expanded(
                child: _missions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No missions available', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                  :

                  ListView.builder(
                          itemCount: _missions.length,
                          itemBuilder: (context, index) {
                            final mission = _missions[index];
                            if (mission == null) {
                              print("Null mission at index $index");
                              return const SizedBox.shrink();
                            }
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.all(10.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        mission.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text(
                                        mission.content,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
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
                                      onPressed: () =>
                                          _missionBrain.completeMissionWithPhoto(1),
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Submit Photo',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                
              ),
            ],
          ),
    );
  }
}
