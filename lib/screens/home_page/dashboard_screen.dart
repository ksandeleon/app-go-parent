import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_parent/screens/home_page/dashboard_brain.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_mission_helper.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';
import 'package:go_parent/services/database/local/models/user_mission_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/constants.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'package:go_parent/screens/home_page/widgets/date_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  static final String id = "dashboard_screen";

  @override
  State<Dashboard> createState() => _DashboardState();
}
class _DashboardState extends State<Dashboard> {

  late DashboardBrain dashboardBrain;

  bool isLoading = true;
  final _userid = UserSession().userId;
  String username = "";
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _initializeDashboardBrain();
  }


  Future<void> _initializeDashboardBrain() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbService = DatabaseService.instance;
    final db = await dbService.database;

    final pictureHelper = PictureHelper(db);
    final babyHelper = BabyHelper(db);
    final userHelper = UserHelper(db);
    final userMissionHelper = UserMissionHelper(db);

    dashboardBrain = DashboardBrain(userHelper, babyHelper, pictureHelper, userMissionHelper);

    _loadUserData();
  }


  Future<void> _loadUserData() async {
    final user = await dashboardBrain.userHelper.getUserById(_userid!);

    if (user != null) {
      setState(() {
        username = user.username.toUpperCase();
        isLoading = false;
      });
    } else {
      setState(() {
        username = "erruser";
        isLoading = false;
      });
    }
  }


  Future<List<CompletedMissionDetail>> getCompletedMissions(int userId) async {
    // Retrieve completed user missions with completion details
    final List<UserMission> completedUserMissions = await dashboardBrain.userMissionHelper
      .getUserMissionsByUserId(userId)
      .then((missions) => missions.where((m) => m.isCompleted).toList());

    if (completedUserMissions.isEmpty) return [];

    // Get database instance
    final db = await DatabaseService.instance.database;

    // Fetch mission details for completed missions
    final List<Map<String, dynamic>> missionMaps = await db.query(
      'missionsdb',
      where: 'missionId IN (${completedUserMissions.map((m) => m.missionId).join(',')})',
    );

    // Combine user mission and mission details
    return completedUserMissions.map((userMission) {
      // Find corresponding mission details
      final missionMap = missionMaps.firstWhere(
        (map) => map['missionId'] == userMission.missionId
      );

      return CompletedMissionDetail(
        userMission: userMission,
        mission: MissionModel.fromMap(missionMap),
      );
    }).toList();
  }


  DateTime? parseDateTime(String dateString) {
    try {
      // Attempt to parse using ISO 8601 format (common for APIs)
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").parse(dateString);
    } catch (e) {
      // Handle potential formatting issues
      try {
        // Try alternative formats if ISO 8601 fails
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
      } catch (e) {
        print("Error parsing date: $dateString");
        return null;
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    if (_userid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Alert(
          context: context,
          type: AlertType.error,
          title: "Login Failed",
          desc: "Please log in again to continue.",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "login_screen");
              },
              width: 120,
            )
          ],
        ).show();
      });
      return Container();
    }

  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: const Text(
        'Go Dashboard',
        style: TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () async {
            //testing here

          }

        ),
        const SizedBox(width: 8),
      ],
    ),

    body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Welcome Header Section // feature1
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[400]!, Colors.teal[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          username.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back,',
                            style: TextStyle(
                              color: Colors.blue[100],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // //feature 2 date
                DateWidget(),


                SizedBox(height: 20,),
                //feature 3, activity history

                SizedBox(
                  width: 800,
                  height: 400,
                  child: Card(
                    elevation: 8,
                    color:  Color(0xFFF2EFE7),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        child: DefaultTabController(length: 2, child: Column(
                          children: [
                            TabBar(tabs:
                            [
                              Tab(text: "My Recent Activities"),
                              Tab(text: "My Mission Analytics"),

                            ], labelColor: Colors.white, // Color of the text when the tab is selected
  unselectedLabelColor: Colors.black54, // Color of the text when the tab is unselected
  indicator: BoxDecoration(
    color: Colors.teal, // Background color of the selected tab
    borderRadius: BorderRadius.circular(12), // Circular border for the selected tab
  ),
  indicatorSize: TabBarIndicatorSize.tab, // Make the indicator cover the entire tab area
  labelStyle: TextStyle(fontWeight: FontWeight.bold),),

                            Expanded(child: TabBarView(children: [

                              FutureBuilder(
                                future: getCompletedMissions(_userid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    // Safely access the data
                                    final List<CompletedMissionDetail> theMissions = snapshot.data ?? [];

                                    if (theMissions.isEmpty) {
                                      return Center(child: Text('No missions completed.'));
                                    }

                                    return ListView.builder(
                                      itemCount: theMissions.length,
                                      itemBuilder: (context, index) {
                                        theMissions.sort((a, b) {
                                        var aDate = DateTime.parse("${a.userMission.completedAt}");
                                        var bDate = DateTime.parse("${b.userMission.completedAt}");
                                        return bDate.compareTo(aDate); // For descending order
                                      });

                                      var mission = theMissions[index];
                                      String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(
                                        DateTime.parse("${mission.userMission.completedAt}")
                                      );
                                        return ListTile(
                                          title: Text("${mission.mission.title}"),
                                          subtitle: Text("Mission Category: ${mission.mission.category}"),
                                          trailing: Text("${formattedDate}", style: TextStyle(fontSize: 14),),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),

                               // Second Tab: Pie Chart
                              FutureBuilder(
                              future: getCompletedMissions(_userid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                } else {
                                  final missions = snapshot.data ?? [];
                                  if (missions.isEmpty) {
                                    return Center(child: Text('You Haven\'t Completed Any Mission Yet.'));
                                  }

                                 // Predefined colors for categories
                                final categoryColors = {
                                  'Social': Colors.lightBlue,
                                  'Creative': Colors.pink[400],
                                  'Math': Colors.brown[400],
                                  'Physical': Colors.orange[400],
                                };

                                // Calculate category counts
                                final categoryCounts = <String, int>{};
                                for (var mission in missions) {
                                  categoryCounts[mission.mission.category] =
                                      (categoryCounts[mission.mission.category] ?? 0) + 1;
                                }

                                // Total number of missions
                                final totalMissions = categoryCounts.values.fold(0, (a, b) => a + b);

                                // Generate Pie Chart sections
                                final pieSections = categoryCounts.entries.map((entry) {
                                  final percentage = ((entry.value / totalMissions) * 100).toInt();
                                // final isTouched = touchedIndex == categoryCounts.keys.toList().indexOf(entry.key);
                                  final radius =  50.0;

                                  return PieChartSectionData(
                                    color: categoryColors[entry.key],
                                    value: entry.value.toDouble(),
                                    title: "$percentage%",
                                    radius: radius,
                                    titleStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList();

                                // Generate Legend
                                final legendItems = categoryCounts.entries.map((entry) {
                                  return Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: categoryColors[entry.key],
                                        margin: EdgeInsets.only(right: 8),
                                      ),
                                      Text(
                                        entry.key,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  );
                                }).toList();

                                                      return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: PieChart(
                                          PieChartData(
                                            sections: pieSections,
                                            centerSpaceRadius: 40,
                                            sectionsSpace: 4,
                                            borderData: FlBorderData(show: false),
                                            startDegreeOffset: -90,
                                            // pieTouchData: PieTouchData(
                                            //   touchCallback: (FlTouchEvent event, PieTouchResponse? touchResponse) {
                                            //     setState(() {
                                            //       if (event is FlPointerExitEvent ) {
                                            //         touchedIndex = -1; // Reset touch
                                            //       } else if (touchResponse != null &&
                                            //           touchResponse.touchedSection != null) {
                                            //         touchedIndex = touchResponse.touchedSection!.touchedSectionIndex;
                                            //       }
                                            //     });
                                            //   },
                                            // ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: legendItems,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                          ],
                        )),
                      ),
                    )
                  ),
                ),


                  //placeholders
                  SizedBox(height: 10,),
                  Expanded(
                    child: Container(
                      color: Colors.red,
                    ),
                  )

            ],
          ),
        ),
      ),
    );




  }



  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// New class to combine UserMission and MissionModel
class CompletedMissionDetail {
  final UserMission userMission;
  final MissionModel mission;

  CompletedMissionDetail({
    required this.userMission,
    required this.mission,
  });
}
