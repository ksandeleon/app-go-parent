import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_parent/screens/gallery_page/collage_screen.dart';
import 'package:go_parent/screens/gallery_page/gallery_screen.dart';
import 'package:go_parent/screens/home_page/dashboard_brain.dart';
import 'package:go_parent/screens/mission_page/mission_screen.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/constants.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  static final String id = "dashboard_screen";

  @override
  State<Dashboard> createState() => _DashboardState();
}


class _DashboardState extends State<Dashboard> {

  final List<Map<String, dynamic>> carouselItems = [
  {
    'image': 'assets/collage.jpg',
    'title': 'Collage',
  },
  {
    'image': 'assets/mission.jpg',
    'title': 'Mission',
  },
  {
    'image': 'assets/gallery.jpg',
    'title': 'Gallery',
  },
];


  late DashboardBrain dashboardBrain;
  late Timer _timer;
  bool isLoading = true;
  final _userid = UserSession().userId;
  String username = "";

  @override
  void initState() {
    super.initState();
    _initializeDashboardBrain();

    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: 1);
    _updateVisibleDates();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      // This will trigger a rebuild and update the time display
    });
  });

  }


  Future<void> _initializeDashboardBrain() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbService = DatabaseService.instance;
    final db = await dbService.database;

    final pictureHelper = PictureHelper(db);
    final babyHelper = BabyHelper(db);
    final userHelper = UserHelper(db);

    dashboardBrain = DashboardBrain(userHelper, babyHelper, pictureHelper);

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

    late PageController _pageController;
  late DateTime _selectedDate;
  late List<DateTime> _visibleDates;

void _updateVisibleDates() {
  DateTime now = DateTime.now();

  // Ensure dates are within the current month
  if (_selectedDate.month == now.month && _selectedDate.year == now.year) {
    _visibleDates = [
      _selectedDate.subtract(const Duration(days: 1)),
      _selectedDate,
      _selectedDate.add(const Duration(days: 1)),
    ];
  } else {
    // Reset to current date if selected date is outside current month
    _selectedDate = now;
    _visibleDates = [
      now.subtract(const Duration(days: 1)),
      now,
      now.add(const Duration(days: 1)),
    ];
  }
}

// In your date navigation methods
void _navigateDate(bool forward) {
  setState(() {
    DateTime now = DateTime.now();

    // Only allow navigation within current month
    if (_selectedDate.month == now.month && _selectedDate.year == now.year) {
      _selectedDate = forward
        ? _selectedDate.add(const Duration(days: 1))
        : _selectedDate.subtract(const Duration(days: 1));

      // Prevent going beyond current date or future dates
      if (_selectedDate.isAfter(now)) {
        _selectedDate = now;
      }

      _updateVisibleDates();
    }
  });
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
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    ),

    body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : SafeArea(
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
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

                    Column(
                      children: [
                        Card(
                          color: Colors.red,
                          child: Padding (
                            padding: const EdgeInsets.all(16),
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hey Parent, Let's Make Today Count!",
                                  style: kh2LabelTextStyle,
                                ),

                                Text(
                                  '(GMT+8:00) ${DateFormat('M/d/yyyy h:mm:ss a').format(DateTime.now())}',
                                  style: kh2LabelTextStyle,
                                ),

                                Row(
                                 // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: () {
                                          if (_selectedDate.month == DateTime.now().month) {
                                            setState(() {
                                              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                                              _updateVisibleDates();
                                            });
                                          }
                                        },
                                      ),
                                    ),

                                    Expanded(
                                      child: GestureDetector(

                                        onHorizontalDragEnd: (details) {
                                          if (details.primaryVelocity! > 0) {
                                            // Swipe right (go back one day)
                                            if (_selectedDate.month == DateTime.now().month) {
                                              setState(() {
                                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                                                _updateVisibleDates();
                                              });
                                            }
                                          } else if (details.primaryVelocity! < 0) {
                                            // Swipe left (go forward one day)
                                            if (_selectedDate.month == DateTime.now().month) {
                                              setState(() {
                                                _selectedDate = _selectedDate.add(const Duration(days: 1));
                                                _updateVisibleDates();
                                              });
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: _visibleDates.map((date) {
                                            final isToday = date.day == DateTime.now().day &&
                                                date.month == DateTime.now().month &&
                                                date.year == DateTime.now().year;
                                            return Card(
                                              color: isToday ? Colors.teal : null,
                                              child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      DateFormat('EEE').format(date),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: isToday ? Colors.white : null,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${DateFormat('MMM').format(date)} ${date.day}',
                                                      style: TextStyle(
                                                        color: isToday ? Colors.white : Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),

                                    Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: IconButton(onPressed: () {
                                          if (_selectedDate.month == DateTime.now().month) {
                                            setState(() {
                                              _selectedDate = _selectedDate.add(const Duration(days: 1));
                                              _updateVisibleDates();
                                            });
                                        }
                                      } , icon: const Icon(Icons.chevron_right)),
                                    )
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                ),


                  Expanded(child: Container(
                    color: Colors.red
                  )),
                  Expanded(child: Container(
                    color: Colors.blue
                  )),
                  Expanded(child: Container(
                    color: Colors.green
                  )),
                ],
              ),
            ),


          ],
        ),
      ),
);


  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
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
