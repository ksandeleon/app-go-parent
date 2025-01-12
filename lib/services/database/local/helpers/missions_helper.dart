import 'package:sqflite/sqflite.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';

class MissionHelper {
  final Database db;

  MissionHelper(this.db);


  /// Retrieve all missions
  Future<List<MissionModel>> getAllMissions() async {
    final List<Map<String, dynamic>> result = await db.query('missionsdb');
    return result.map((map) => MissionModel.fromMap(map)).toList();
  }

  /// Retrieve missions by category (e.g., 'Learning', 'Playtime')
  Future<List<MissionModel>> getMissionsByCategory(String category) async {
    final List<Map<String, dynamic>> result = await db.query(
      'missionsdb',
      where: 'category = ?',
      whereArgs: [category],
    );

    return result.map((map) => MissionModel.fromMap(map)).toList();
  }

  /// Retrieve missions based on the baby's age in months
  Future<List<MissionModel>> getMissionsByBabyMonthAge(int babyAgeInMonths) async {
    final List<Map<String, dynamic>> result = await db.query(
      'missionsdb',
      where: 'minAge <= ? AND maxAge >= ?',
      whereArgs: [babyAgeInMonths, babyAgeInMonths],
    );

    return result.map((map) => MissionModel.fromMap(map)).toList();
  }


  /// Insert a new mission into the database
  Future<int> insertMission(MissionModel mission) async {
    return await db.insert(
      'missionsdb',
      mission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve a mission by its ID
  Future<MissionModel?> getMissionById(int missionId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'missionsdb',
      where: 'missionId = ?',
      whereArgs: [missionId],
    );

    if (result.isNotEmpty) {
      return MissionModel.fromMap(result.first);
    }
    return null;
  }

  /// Delete a mission by its ID
  Future<int> deleteMission(int missionId) async {
    return await db.delete(
      'missionsdb',
      where: 'missionId = ?',
      whereArgs: [missionId],
    );
  }

  /// Count the number of missions by category
  Future<int> countMissionsByCategory(String category) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM missionsdb WHERE category = ?',
      [category],
    );

    return result.first['count'] as int;
  }

  /// Check if a mission exists by title
  Future<bool> missionExists(String title) async {
    final List<Map<String, dynamic>> result = await db.query(
      'missionsdb',
      where: 'title = ?',
      whereArgs: [title],
    );

    return result.isNotEmpty;
  }
}
