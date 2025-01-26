import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_parent/Screen/usedtobeprofilescreen.dart';
import 'package:go_parent/Screen/view%20profile/viewprofile.dart';
import 'package:go_parent/screens/gallery_page/gallery_screen.dart';
import 'package:go_parent/screens/home_page/dashboard_screen.dart';
import 'package:go_parent/screens/login_page/login_screen.dart';
import 'package:go_parent/screens/mission_page/mission_screen.dart';
import 'package:go_parent/screens/profile_page/profile_screen.dart';

class Homescreen extends StatefulWidget {
  final String username;
  static String id = 'home_screen';
  final int userId;

  const Homescreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cont = Get.put(NavigationController(username: widget.username, userId: widget.userId));
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: cont.selectedIndex.value,
            onDestinationSelected: (index) => cont.onDestinationSelected(index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: "Home"),
              NavigationDestination(icon: Icon(Icons.task_rounded), label: "Missions"),
              NavigationDestination(icon: Icon(Icons.photo_album), label: "Gallery"),
              NavigationDestination(icon: Icon(Icons.person_2_rounded), label: "Profile"),
            ]),
      ),

      body: Obx(() {
        return IndexedStack(
          index: cont.selectedIndex.value,
          children: cont.screens,
        );
      }),
    );
  }
}


class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final String username;
  final int userId;
  NavigationController({required this.username, required this.userId});
  late final List<Widget> screens;

  void onDestinationSelected(int index) {
    selectedIndex.value = index;
    screens[index] = _getScreen(index);
  }


  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return Dashboard(key: UniqueKey());
      case 1:
        return MissionScreen(key: UniqueKey());
      case 2:
        return GalleryScreen(key: UniqueKey());
      case 3:
        return profileviewer(key: UniqueKey());
      default:
        return LoginPage1(key: UniqueKey());
    }
  }


  @override
  void onInit() {
    super.onInit();
    screens = [
      _getScreen(0),
      _getScreen(1),
      _getScreen(2),
      _getScreen(3),
    ];
  }
}
