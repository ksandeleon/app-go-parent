import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_parent/Screen/childcare.dart';
import 'package:go_parent/screens/home_page/dashboard_brain.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_mission_helper.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';
import 'package:go_parent/services/database/local/models/user_mission_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
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

    final List<Map<String, dynamic>> categories = [
    {
      'title': 'Nutrition & Feeding',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'tips': [
        'Breastfeed exclusively for first 6 months if possible',
        'Introduce solid foods gradually after 6 months',
        'Always sterilize bottles and feeding equipment',
        'Watch for food allergies when introducing new foods',
      ]
    },
    {
      'title': 'Sleep & Rest',
      'icon': Icons.bedtime,
      'color': Colors.indigo,
      'tips': [
        'Newborns sleep 16-17 hours per day',
        'Establish consistent bedtime routines',
        'Put baby to sleep on their back',
        'Maintain optimal room temperature (68-72°F)',
      ]
    },
    {
      'title': 'Health & Safety',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
      'tips': [
        'Schedule regular pediatric check-ups',
        'Keep vaccinations up to date',
        'Learn infant CPR and first aid',
        'Childproof your home thoroughly',
      ]
    },
    {
      'title': 'Development',
      'icon': Icons.child_care,
      'color': Colors.green,
      'tips': [
        'Engage in daily tummy time',
        'Read books together daily',
        'Encourage play and exploration',
        'Monitor developmental milestones',
      ]
    },
  ];


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


  void _showCategoryDetails(BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category['icon'], color: category['color']),
                  const SizedBox(width: 12),
                  Text(
                    category['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...category['tips']
                  .map<Widget>((tip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle,
                                color: category['color'], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
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
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
      //     onPressed: ()  {

      //       Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => Childcare()),
      //       );

      //     }
      // //   ),
      //   const SizedBox(height: 15),
      // ],
    ),

    body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // feature 1, welcome header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal[400]!, Colors.teal[600]!
                          ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: TextStyle(
                                color: Colors.white,
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
                  SizedBox(height: 30,),


                  // //feature 2 date
                  Center(child: DateWidget()),
                  SizedBox(height: 50,),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(

                        children: [


                          //feature 3, activity history
                          Center(
                            child: SizedBox(
                              width: 650,
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
                                          Tooltip(
                                            message:"Your Most Recent Activities!", child: Tab(text: "My Recent Activities")),
                                          Tooltip(message: "Missions You've Been Most Engaged With!", child: Tab(text: "My Activity Analytics")),
                                        ], labelColor: Colors.white,
                                          unselectedLabelColor: Colors.black54,
                                          indicator: BoxDecoration(
                                            color: Colors.teal,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          indicatorSize: TabBarIndicatorSize.tab,
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
                                                      title: Text("${mission.mission.title}",),
                                                      subtitle: Text("Mission Category: ${mission.mission.category}"),
                                                      trailing: Text("${formattedDate}", style: TextStyle(fontSize: 14),),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),

                                           // feature 3 Second Tab: Pie Chart
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
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: PieChart(
                                                      PieChartData(
                                                        sections: pieSections,
                                                        centerSpaceRadius: 40,
                                                        sectionsSpace: 4,
                                                        borderData: FlBorderData(show: false),
                                                        startDegreeOffset: -90,
                                                      ),
                                                    ),
                                                  ),
                                                  // const SizedBox(height: 16),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      children: [
                                                        Text("Mission Categories", style: TextStyle(fontWeight: FontWeight.bold),),
                                                        SizedBox(height: 5,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children:
                                                          legendItems,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                      )
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
                      ),
                    ],
                  ),


                  //feature 4
                    SizedBox(
                      width: 650,
                      height: 400,
                      child:
                      Card(
                        elevation: 8,
                        color:  Color(0xFFF2EFE7),
                        child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12.0,
                              bottom: 12.0,
                              right: 36.0,
                              left: 36.0,
                            ),
                          child: Column(
                            children: [

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.tips_and_updates, color: Colors.black45),
                                  SizedBox(width: 8),
                                  Text(
                                    "Parenting Compass",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25,),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child:

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white, //change this when hovered
                                          padding: EdgeInsets.symmetric(vertical: 20.0), // Further increased height
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12), // Circular border
                                          ),
                                        ),
                                        onPressed: () => _showCategoryDetails(context, category),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 16), // Padding before the icon
                                            Icon(
                                              category['icon'],
                                              color: category['color'],
                                              size: 30, // Slightly larger icon size
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              category['title'],
                                              style: TextStyle(
                                                color: Colors.black, //change this when hovered
                                                fontSize: 16, // Slightly larger font size for title
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            ]
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ],
                        ),
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
