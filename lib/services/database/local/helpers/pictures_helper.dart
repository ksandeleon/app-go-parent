import 'package:sqflite/sqflite.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';

class PictureHelper {
  final Database db;

  PictureHelper(this.db);


  Future<int> insertPicture({
    required int userId,
    required int userMissionId,
    required String photoPath,
    bool isCollage = false,
  }) async {
    // First verify the user_mission exists and belongs to the user
    final userMission = await db.query(
      'usermissionsdb',
      where: 'userMissionId = ? AND userId = ?',
      whereArgs: [userMissionId, userId],
    );

    if (userMission.isEmpty) {
      throw Exception('Invalid userMissionId or userId combination');
    }

    final picture = PictureModel(
      userId: userId,
      userMissionId: userMissionId,
      photoPath: photoPath,
      isCollage: isCollage,
    );

    return await db.insert(
      'picturesdb',
      picture.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

/// Retrieve all pictures for a specific user
  Future<List<PictureModel>> getPicturesByUserId(int userId) async {
    try {
      print('getPicturesByUserId: Starting query for userId=$userId');

      final List<Map<String, dynamic>> result = await db.query(
        'picturesdb',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      print('getPicturesByUserId: Query result - ${result.length} rows fetched');

      final pictures = result.map((map) => PictureModel.fromMap(map)).toList();
      print('getPicturesByUserId: Mapped ${pictures.length} PictureModel objects');

      return pictures;
    } catch (e) {
      print('getPicturesByUserId: Error occurred - $e');
      rethrow; // Rethrow the error to be handled elsewhere if needed
    }
  }



/// Retrieve a picture by ID
  Future<PictureModel?> getPictureById(int pictureId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'picturesdb',
      where: 'pictureId = ?',
      whereArgs: [pictureId],
    );

    if (result.isNotEmpty) {
      return PictureModel.fromMap(result.first);
    }
    return null;
  }


  /// Retrieve all pictures
  Future<List<PictureModel>> getAllPictures() async {
    final List<Map<String, dynamic>> result = await db.query('picturesdb');

    return result.map((map) => PictureModel.fromMap(map)).toList();
  }


  /// Retrieve all pictures for a specific user mission
  Future<List<PictureModel>> getPicturesByUserMissionId(int userMissionId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'picturesdb',
      where: 'userMissionId = ?',
      whereArgs: [userMissionId],
    );

    return result.map((map) => PictureModel.fromMap(map)).toList();
  }


  /// Retrieve pictures marked as part of a collage
  Future<List<PictureModel>> getPicturesForCollage() async {
    final List<Map<String, dynamic>> result = await db.query(
      'picturesdb',
      where: 'isCollage = 1',
    );

    return result.map((map) => PictureModel.fromMap(map)).toList();
  }


  /// Update picture details
  Future<int> updatePicture(PictureModel picture) async {
    if (picture.pictureId == null) {
      throw Exception('Picture ID is required for updating');
    }

    return await db.update(
      'picturesdb',
      picture.toMap(),
      where: 'pictureId = ?',
      whereArgs: [picture.pictureId],
    );
  }


  /// Mark a picture as part of a collage
  Future<int> markAsCollage(int pictureId) async {
    final picture = await getPictureById(pictureId);
    if (picture == null) {
      throw Exception('Picture not found');
    }

    return await db.update(
      'picturesdb',
      {'isCollage': 1},
      where: 'pictureId = ?',
      whereArgs: [pictureId],
    );
  }


  /// Delete a picture by ID
  Future<int> deletePicture(int pictureId) async {
    final picture = await getPictureById(pictureId);
    if (picture == null) {
      throw Exception('Picture not found');
    }

    return await db.delete(
      'picturesdb',
      where: 'pictureId = ?',
      whereArgs: [pictureId],
    );
  }


  /// Count total pictures for a specific user mission
  Future<int> countPicturesByUserMissionId(int userMissionId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM picturesdb WHERE userMissionId = ?',
      [userMissionId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }


  /// Count total pictures marked for a collage
  Future<int> countPicturesForCollage() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM picturesdb WHERE isCollage = 1',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
