import 'package:go_parent/services/database/local/models/user_mission_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:sqflite/sqflite.dart';

class UserMissionHelper {
  static final UserMissionHelper _instance = UserMissionHelper._internal();
  factory UserMissionHelper() => _instance;
  UserMissionHelper._internal();

  // Table name constant to ensure consistency
  static const String tableName = 'usermissionsdb';

  /// Add a new UserMission entry to the database
  Future<int> insertUserMission(UserMission userMission) async {
    final db = await DatabaseService.instance.database;
    return await db.insert(
      tableName,
      userMission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getUserMissionId({
    required int userId,
    required int missionId,
  }) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['userMissionId'],
      where: 'userId = ? AND missionId = ?',
      whereArgs: [userId, missionId],
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return result.first['userMissionId'] as int;
  }

  /// Retrieve all UserMission entries from the database
  Future<List<UserMission>> getAllUserMissions() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => UserMission.fromMap(map)).toList();
  }

  /// Retrieve UserMission entries by userId
  Future<List<UserMission>> getUserMissionsByUserId(int userId) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
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
      tableName,
      where: 'userId = ? AND missionId = ?',
      whereArgs: [userId, missionId],
    );
    if (existing.isEmpty) {
      // Insert a new record
      return await db.insert(tableName, {
        'userId': userId,
        'missionId': missionId,
        'isCompleted': 1,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Update the existing record
      return await db.update(
        tableName,
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
      tableName,
      where: 'userMissionId = ?',
      whereArgs: [userMissionId],
    );
  }

  /// Clear all entries from the usermissionsdb table
  Future<void> clearAllUserMissions() async {
    final db = await DatabaseService.instance.database;
    await db.delete(tableName);
  }

  Future<Set<int>> getUserCompletedMissions(int userId) async {
    final db = await DatabaseService.instance.database;

    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      columns: ['missionId'],  // Only select the missionId column for efficiency
      where: 'userId = ? AND isCompleted = ?',
      whereArgs: [userId, 1],  // 1 represents true in SQLite
    );

    // Convert the results to a Set of mission IDs
    return results.map<int>((row) => row['missionId'] as int).toSet();
  }



}
