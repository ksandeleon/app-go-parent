// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_parent/Screen/view%20profile/addBabyScreen.dart';
import 'package:go_parent/Screen/view%20profile/emergency_hotline_screen.dart';
import 'package:go_parent/Screen/view%20profile/profile_viewer_editor.dart';
import 'package:go_parent/Screen/view%20profile/updateBabyInfo.dart';
import 'package:go_parent/Screen/view%20profile/update_profile_info.dart';
import 'package:go_parent/screens/profile_page/profile_brain.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../services/database/local/models/baby_model.dart';

class profileviewer extends StatefulWidget {
  const profileviewer({super.key});

  @override
  State<profileviewer> createState() => _profileviewerState();
}

class _profileviewerState extends State<profileviewer> {
  BabyHelper? _babyHelper;
  BabyModel? baby;
  late ProfileBrain profileBrain;
  late UserSession userSession;
  List<BabyModel> babies = [];
  Color colorbeige = Color(0xFFF2EFE7);
  String familyAddress = 'click to update';
  String emergencyContact = 'click to update';
  String familyDoctor = 'cick to update';
  String school = 'click to update';

  String username = "";
   bool isLoading = true;
  final _userid = UserSession().userId;

  @override
  void initState() {
    super.initState();
    userSession = UserSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInfoDialog();
      initializeDatabase();
      initProfileBrain();
    });
  }

  void initProfileBrain() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbService = DatabaseService.instance;
    final db = await dbService.database;

    final babyHelper = BabyHelper(db);
    final userHelper = UserHelper(db);

    profileBrain = ProfileBrain(userHelper, babyHelper);

    _loadUserData();
  }

  void initializeDatabase() async {
    final database = await openDatabase('goparent_v6.db');
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


  Future<void> _loadUserData() async {
    final user = await profileBrain.userHelper.getUserById(_userid!);

    if (user != null) {
      setState(() {
        username = user.username.toUpperCase();
        //isLoading = false;
      });
    } else {
      setState(() {
        username = "erruser";
      //  isLoading = false;
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
              "Hey Parent, Your Information is Safe with Us. We do not require you to put any sensitive information."),
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

  Widget _buildChildCard({
    required String name,
    required String age,
    required int index,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorbeige,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.child_care,
                    size: 50,
                    color: Colors.teal[200],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          Text(
            age,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigateToEditScreen({
    required BuildContext context,
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
  }) async {
    final updatedValue = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInfoScreen(
          title: title,
          initialValue: currentValue,
        ),
      ),
    );

    if (updatedValue != null && updatedValue is String) {
      setState(() {
        switch (title) {
          case 'Family Address':
            familyAddress = updatedValue;
            break;
          case 'Emergency Contact':
            emergencyContact = updatedValue;
            break;
          case 'Family Doctor':
            familyDoctor = updatedValue;
            break;
          case 'School':
            school = updatedValue;
            break;
        }
      });
      onSave(updatedValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Color(0xFFF5F8FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: Text(
          'Go Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.edit, color: Color(0xFF2E3E5C)),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         PageRouteBuilder(
        //           pageBuilder: (context, animation, secondaryAnimation) =>
        //               NewBabyScreen(),
        //           transitionsBuilder:
        //               (context, animation, secondaryAnimation, child) {
        //             return FadeTransition(opacity: animation, child: child);
        //           },
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Parent Profile Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
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
                  SizedBox(height: 10),
                  // Parent Profile Picture
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF9CC4FF),
                        width: 3,
                      ),
                      color: Colors.teal, // Optional: Add a background color
                    ),
                    child: Center(
                      child: Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: 60, // Adjust the size of the icon as needed
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '${username}',
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
                      color: colorbeige,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Loving Parent',
                      style: TextStyle(
                        color: Colors.teal,
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
                    'My Children',
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
                        ...babies.asMap().entries.map((entry) {
                          final index = entry.key +
                              1; // Adding 1 to start from 1 instead of 0
                          final baby = entry.value;
                          return Tooltip(
                            message: "Edit Baby Information",
                            child: GestureDetector(
                              onTap: () async {
                                final babyId = baby.babyId;
                                if (babyId != null) {
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
                              child: _buildChildCard(
                                name: baby.babyName ?? 'Unnamed',
                                age: baby.babyGender ?? 'N/A',
                                index: index,
                              ),
                            ),
                          );
                        }),
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
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
                    value: familyAddress,
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  _buildFamilyInfoCard(
                    icon: Icons.phone,
                    title: 'Emergency Contact',
                    value: emergencyContact,
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  _buildFamilyInfoCard(
                    icon: Icons.local_hospital,
                    title: 'Family Doctor',
                    value: familyDoctor,
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  _buildFamilyInfoCard(
                    icon: Icons.school,
                    title: 'School',
                    value: school,
                    onTap: () {},
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
                                icon: Icons.emergency,
                                label: 'Emergency Hotline',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EmergencyHotlineScreen()),
                                  );
                                }),
                            _buildQuickActionButton(
                                icon: Icons.medical_information,
                                label: 'Health Records',
                                onTap: () {}),
                            _buildQuickActionButton(
                                icon: Icons.photo_library,
                                label: 'Memories',
                                onTap: () {}),
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

// // ORIGGGGGGGGG
//   Widget _buildChildCard({
//     required void Function() onTap,
//     required String name,
//     required String age,
//     required String imagePath,
//   }) {
//     return GestureDetector(
//       // Add this to make it tappable
//       onTap: onTap,
//       child: Container(
//         width: 120,
//         margin: const EdgeInsets.only(right: 16),
//         child: Column(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: const Color(0xFF9CC4FF),
//                   width: 2,
//                 ),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(40),
//                 child: Image.asset(
//                   imagePath,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return const Icon(Icons.child_care, size: 40);
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               name,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2E3E5C),
//               ),
//             ),
//             Text(
//               age,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  Widget _buildFamilyInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _navigateToEditScreen(
          context: context,
          title: title,
          currentValue: value,
          onSave: (newValue) {
            // The setState is now handled in _navigateToEditScreen
          },
        );
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
