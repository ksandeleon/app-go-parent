// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_parent/Screen/view%20profile/addBabyScreen.dart';
import 'package:go_parent/Screen/view%20profile/profile_viewer_editor.dart';
import 'package:go_parent/Screen/view%20profile/updateBabyInfo.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/database/local/models/baby_model.dart';

class profileviewer extends StatefulWidget {
  const profileviewer({super.key});

  @override
  State<profileviewer> createState() => _profileviewerState();
}

class _profileviewerState extends State<profileviewer> {
  BabyHelper? _babyHelper;
  BabyModel? baby;
  late UserSession userSession;
  List<BabyModel> babies = [];

  @override
  void initState() {
    // Initialize the BabyHelper instance
    super.initState();
    userSession = UserSession(); // Ensure it's initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInfoDialog();
      initializeDatabase();
    });
  }

  void initializeDatabase() async {
    final database =
        await openDatabase('goparent_v6.db'); // Replace with your database path
    setState(() {
      _babyHelper = BabyHelper(database);
    });

    // Fetch baby data
    await _refreshBabies();

    // Fetch baby data
    final List<BabyModel> fetchedBabies =
        await _babyHelper!.getBabiesByUserId(userSession.userId!);
    setState(() {
      babies = fetchedBabies
          .where((baby) => baby.babyName?.isNotEmpty == true)
          .toList();
    });
  }

  Future<void> _refreshBabies() async {
    if (userSession.isLoggedIn()) {
      final List<BabyModel> fetchedBabies =
          await _babyHelper!.getBabiesByUserId(userSession.userId!);
      setState(() {
        babies = fetchedBabies
            .where((baby) => baby.babyName?.isNotEmpty == true)
            .toList();
      });
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Information"),
          content: Text(
              "All information here are optional to put. We do not require you to put any personal information."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Color(0xFFF5F8FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Family Profile',
          style: TextStyle(
            color: Color(0xFF2E3E5C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFF2E3E5C)),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      NewBabyScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Parent Profile Section
            Container(
              width: double.infinity,
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
                  // Parent Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF9CC4FF),
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            'assets/images/tristanaa.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF4B8EFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.family_restroom,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  SizedBox(height: 8),
                  // Parent Type
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF4B8EFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Primary Parent',
                      style: TextStyle(
                        color: Color(0xFF4B8EFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Children Section
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hero',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...babies.map((baby) => _buildChildCard(
                              onTap: () async {
                                // Ensure baby is assigned properly before use
                                final babyId = baby.babyId;
                                if (babyId != null) {
                                  // You can either fetch the full baby data here
                                  final babyDetails =
                                      await _babyHelper?.getBabyById(babyId);
                                  if (babyDetails != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Updatebabyinfo(
                                          babyId: babyId,
                                          babyDetails: babyDetails,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Could not find baby details'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              name: baby.babyName ?? 'Unnamed',
                              age: baby.babyAge?.toString() ?? 'N/A',
                              imagePath: 'assets/images/tristanaa.jpg',
                            )),
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                // Add proper navigation
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewBabyScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4B8EFF).withOpacity(0.1),
                              foregroundColor: const Color(0xFF4B8EFF),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side:
                                    const BorderSide(color: Color(0xFF4B8EFF)),
                              ),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline, size: 32),
                                SizedBox(height: 8),
                                Text('Add Child'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Family Information Cards
                  _buildFamilyInfoCard(
                    icon: Icons.home,
                    title: 'Family Address',
                    value: '123 Family Street, Happy Valley',
                  ),
                  SizedBox(height: 16),
                  _buildFamilyInfoCard(
                    icon: Icons.phone,
                    title: 'Emergency Contact',
                    value: '+1 234 567 890',
                  ),
                  SizedBox(height: 16),
                  _buildFamilyInfoCard(
                    icon: Icons.local_hospital,
                    title: 'Family Doctor',
                    value: 'Dr. Smith | Pediatric Care',
                  ),
                  SizedBox(height: 16),
                  _buildFamilyInfoCard(
                    icon: Icons.school,
                    title: 'School',
                    value: 'Sunshine Elementary',
                  ),

                  SizedBox(height: 24),
                  // Quick Actions
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3E5C),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.calendar_today,
                              label: 'Schedule',
                            ),
                            _buildQuickActionButton(
                              icon: Icons.medical_information,
                              label: 'Health Records',
                            ),
                            _buildQuickActionButton(
                              icon: Icons.photo_library,
                              label: 'Memories',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

// ORIGGGGGGGGG
  Widget _buildChildCard({
    required void Function() onTap,
    required String name,
    required String age,
    required String imagePath,
  }) {
    return GestureDetector(
      // Add this to make it tappable
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9CC4FF),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.child_care, size: 40);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E5C),
              ),
            ),
            Text(
              age,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF4B8EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF4B8EFF),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3E5C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF4B8EFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Color(0xFF4B8EFF),
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF2E3E5C),
          ),
        ),
      ],
    );
  }
}
