import 'package:go_parent/services/database/local/models/user_mission_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:sqflite/sqflite.dart';

class UserMissionHelper {
  static final UserMissionHelper _instance = UserMissionHelper._internal();
  factory UserMissionHelper() => _instance;

  UserMissionHelper._internal();

  /// Add a new UserMission entry to the database
  Future<int> insertUserMission(UserMission userMission) async {
    final db = await DatabaseService.instance.database;
    return await db.insert(
      'usermissionsdb',
      userMission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all UserMission entries from the database
  Future<List<UserMission>> getAllUserMissions() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('usermissionsdb');

    return maps.map((map) => UserMission.fromMap(map)).toList();
  }

  /// Retrieve UserMission entries by userId
  Future<List<UserMission>> getUserMissionsByUserId(int userId) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usermissionsdb',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => UserMission.fromMap(map)).toList();
  }

    /// Mark a mission as completed
  Future<int> markMissionAsCompleted({
    required int userId,
    required int missionId,
  }) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      'usermissionsdb',
      where: 'userId = ? AND missionId = ?',
      whereArgs: [userId, missionId],
    );

    if (existing.isEmpty) {
      // Insert a new record
      return await db.insert('usermissionsdb', {
        'userId': userId,
        'missionId': missionId,
        'isCompleted': 1,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Update the existing record
      return await db.update(
        'usermissionsdb',
        {
          'isCompleted': 1,
          'completed_at': DateTime.now().toIso8601String(),
        },
        where: 'userId = ? AND missionId = ?',
        whereArgs: [userId, missionId],
      );
    }
  }

  /// Delete a UserMission entry by ID
  Future<int> deleteUserMission(int userMissionId) async {
    final db = await DatabaseService.instance.database;
    return await db.delete(
      'usermissionsdb',
      where: 'userMissionId = ?',
      whereArgs: [userMissionId],
    );
  }

  /// Clear all entries from the usermissionsdb table
  Future<void> clearAllUserMissions() async {
    final db = await DatabaseService.instance.database;
    await db.delete('usermissionsdb');
  }


}
