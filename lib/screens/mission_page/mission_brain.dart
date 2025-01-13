import 'package:flutter/material.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/missions_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_mission_helper.dart';
import 'package:go_parent/services/database/local/models/baby_model.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class MissionBrain {
  final MissionHelper missionHelper;
  final BabyHelper babyHelper;
  final PictureHelper pictureHelper;
  final UserMissionHelper userMissionHelper;

  List<MissionModel> _missions = [];

  MissionBrain(this.missionHelper, this.babyHelper, this.pictureHelper, this.userMissionHelper);

  List<MissionModel> get missions => _missions;

  //Missions funcions
  final ImagePicker _picker = ImagePicker();

  Future<bool> completeMission(int userId, int missionId) async {
    try {
      // Mark mission as completed and get the userMissionId in one transaction
      final result = await userMissionHelper.markMissionAsCompleted(
        userId: userId,
        missionId: missionId
      );

      if (result <= 0) {
        print('Failed to complete the mission for userId: $userId, missionId: $missionId');
        return false;
      }

      // Get the userMissionId right after completion
      final userMissionId = await getUserMissionId(userId, missionId);
      if (userMissionId == null) {
        print('Failed to get userMissionId after completion');
        return false;
      }

      return true;
    } catch (e) {
      print('Error completing mission for userId: $userId, missionId: $missionId: $e');
      return false;
    }
  }

  Future<int?> savePhotoToDatabase(
    int userMissionId,
    int userId,
    String photoPath,
    {bool isCollage = false}
  ) async {
    try {
      return await pictureHelper.insertPicture(
        userId: userId,
        userMissionId: userMissionId,
        photoPath: photoPath,
        isCollage: isCollage,
      );
    } catch (e) {
      print('Error saving photo to database: $e');
      return null;
    }
  }

  Future<bool> completeMissionWithPhoto(
    BuildContext context,
    int missionId,
    {bool isCollage = false}
  ) async {
    // Retrieve the logged-in user's ID from the UserSession singleton
    final userId = UserSession().userId;
    // Check if user is logged in
    if (userId == null) {
      await Alert(
        context: context,
        type: AlertType.error,
        title: "Login Required",
        desc: "Please log in to complete this mission.",
        buttons: [
          DialogButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ).show();
      print("No user is logged in.");
      return false;
    }

    String? photoPath = await takePhotoOrPickFile();
    if (!validatePhotoSelection(photoPath)) {
      await Alert(
        context: context,
        type: AlertType.warning,
        title: "Submission Cancelled",
        desc: "Please select or take a photo to submit on this  mission.",
        buttons: [
          DialogButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ).show();
      print("No photo selected");
      return false;
    }

    print('Photo validated successfully: $photoPath');

    try {
      // First complete the mission
      final completed = await completeMission(userId, missionId);
      if (!completed) {
        await Alert(
          context: context,
          type: AlertType.error,
          title: "Mission Error",
          desc: "Failed to complete the mission. Please try again.",
          buttons: [
            DialogButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ).show();
        return false;
      }

      // Get the userMissionId
      final userMissionId = await getUserMissionId(userId, missionId);
      if (userMissionId == null) {
        await Alert(
          context: context,
          type: AlertType.error,
          title: "Mission ID Error",
          desc: "Could not retrieve mission information. Please try again.",
          buttons: [
            DialogButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ).show();
        return false;
      }

      // Save the photo
      final photoId = await savePhotoToDatabase(
        userMissionId,
        userId,
        photoPath!,
        isCollage: isCollage
      );

      if (photoId == null) {
        await Alert(
          context: context,
          type: AlertType.error,
          title: "Photo Save Error",
          desc: "Failed to save the photo. Please try again.",
          buttons: [
            DialogButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ).show();
        return false;
      }

      // Show success message
      await Alert(
        context: context,
        type: AlertType.success,
        title: "Submission Success!",
        desc: "Submission has been completed with your photo.",
        buttons: [
          DialogButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ).show();

      return true;
    } catch (e) {
      print('Error in completeMissionWithPhoto: $e');
      await Alert(
        context: context,
        type: AlertType.error,
        title: "Unexpected Error",
        desc: "An unexpected error occurred. Please try again.",
        buttons: [
          DialogButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ).show();
      return false;
    }
  }










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


  Future<int?> getUserMissionId(int userId, int missionId) async {
  try {
    final result = await userMissionHelper.getUserMissionId(userId: userId, missionId: missionId);
    return result;
  } catch (e) {
    print('Error getting userMissionId: $e');
    return null;
  }
}


  bool validatePhotoSelection(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      print('DEBUG: photoSelectionCancelled');
      return false;
    }
      print('DEBUG: photoSelectionSuccess');
    return true;
  }

  Future<void> loadAllMissions() async {
    try {
      _missions = await missionHelper.getAllMissions();
    } catch (e) {
      print('Error loading missions: $e');
      _missions = [];
    }
  }

  Future<List<MissionModel>> getMissionsByAge(int age) async {
    final missions = await missionHelper.getMissionsByBabyMonthAge(age);
    return missions.map((mission) => MissionModel(
      missionId: mission.missionId,
      title: mission.title,
      category: mission.category,
      content: mission.content,
      minAge: mission.minAge,
      maxAge: mission.maxAge,
      createdAt: mission.createdAt,
      updatedAt: mission.updatedAt
    )).toList();
  }


  // Retrieve all babies linked to the logged-in user
  Future<List<BabyModel>> getBabiesForUser() async {
    // Retrieve the logged-in user's ID from the UserSession
    final userId = UserSession().userId;

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
