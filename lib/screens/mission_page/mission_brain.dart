import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/missions_helper.dart';
import 'package:go_parent/services/database/local/models/baby_model.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MissionBrain {
  final MissionHelper missionHelper;
  final BabyHelper babyHelper;

  List<MissionModel> _missions = [];

  MissionBrain(this.missionHelper, this.babyHelper);

  List<MissionModel> get missions => _missions;

  //Missions funcions
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhotoOrPickFile() async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        // Mobile: Open the camera
        print('DEBUG: Opening camera on mobile');
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (photo != null) {
          print('DEBUG: Photo captured successfully - ${photo.path}');
          return photo.path; // Return the path as String
        } else {
          print('DEBUG: No photo was taken - user cancelled');
          return null;
        }
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        // Desktop: Open file picker
        print('DEBUG: Opening file picker on desktop');
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery, // This will open the file system on desktop
          imageQuality: 80,
        );
        if (photo != null) {
          print('DEBUG: File selected successfully - ${photo.path}');
          return photo.path; // Return the path as String
        } else {
          print('DEBUG: No file was selected - user cancelled');
          return null;
        }
      } else {
        print('DEBUG: Unsupported platform');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error handling photo/file - $e');
      return null;
    }
  }




  Future<void> loadAllMissions() async {
    try {
      _missions = await missionHelper.getAllMissions();
    } catch (e) {
      print('Error loading missions: $e');
      _missions = [];
    }
  }

  Future<void> getMissionsByAge(int babyAge) async {
    try {
      _missions =  await missionHelper.getMissionsByBabyMonthAge(babyAge);
    }
    catch (e) {
      print('Error loading missions by age: $e');
      _missions = [];
    }
  }

  Future<List<MissionModel>> getMissionsByCategory(String category) async {
    try {
      return await missionHelper.getMissionsByCategory(category);
    } catch (e) {
      print('Error loading missions by category: $e');
      return [];
    }
  }


  // Retrieve all babies linked to the logged-in user
  Future<List<BabyModel>> getBabiesForUser() async {
    // Retrieve the logged-in user's ID from the UserSession
    //final userId = UserSession().userId;

    final userId = 1; // This should be replaced with UserSession().userId when implementing real user session logic

    if (userId == null) {
      print("[getBabiesForUser] No user is logged in.");
      return [];
    }

    print("[getBabiesForUser] Fetching babies for userId: $userId");

    // Retrieve all babies linked to the user
    final babies = await babyHelper.getBabiesByUserId(userId);

    if (babies.isEmpty) {
      print("[getBabiesForUser] No babies found for userId: $userId");
      return [];
    }

    print("[getBabiesForUser] Found ${babies.length} babies for userId: $userId");

    return babies;
  }
}
