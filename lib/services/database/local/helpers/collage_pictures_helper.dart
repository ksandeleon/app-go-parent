import 'package:sqflite/sqflite.dart';

class CollagePicturesHelper {
  final Database db;

  CollagePicturesHelper(this.db);

   Future<void> insertCollagePictures(List<Map<String, dynamic>> collagePictures) async {
    await db.transaction((txn) async {
      for (final collagePicture in collagePictures) {
        await txn.insert('collage_pictures', collagePicture,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Retrieve all picture IDs linked to a specific collage
  Future<List<int>> getPictureIdsByCollageId(int collageId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'collage_pictures',
      columns: ['pictureId'],
      where: 'collageId = ?',
      whereArgs: [collageId],
    );

    return result.map((map) => map['pictureId'] as int).toList();
  }

  /// Retrieve all collage IDs linked to a specific picture
  Future<List<int>> getCollageIdsByPictureId(int pictureId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'collage_pictures',
      columns: ['collageId'],
      where: 'pictureId = ?',
      whereArgs: [pictureId],
    );

    return result.map((map) => map['collageId'] as int).toList();
  }

  /// Retrieve all collage-picture pairs (useful for administrative purposes)
  Future<List<Map<String, dynamic>>> getAllCollagePictures() async {
    return await db.query('collage_pictures');
  }

  /// Delete a specific collage-picture pair
  Future<int> deleteCollagePicture(int collageId, int pictureId) async {
    return await db.delete(
      'collage_pictures',
      where: 'collageId = ? AND pictureId = ?',
      whereArgs: [collageId, pictureId],
    );
  }

  /// Count the number of pictures linked to a specific collage
  Future<int> countPicturesByCollageId(int collageId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM collage_pictures WHERE collageId = ?',
      [collageId],
    );

    return result.first['count'] as int;
  }

  /// Count the number of collages linked to a specific picture
  Future<int> countCollagesByPictureId(int pictureId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM collage_pictures WHERE pictureId = ?',
      [pictureId],
    );

    return result.first['count'] as int;
  }

  /// Check if a collage-picture pair exists
  Future<bool> collagePictureExists(int collageId, int pictureId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'collage_pictures',
      where: 'collageId = ? AND pictureId = ?',
      whereArgs: [collageId, pictureId],
    );

    return result.isNotEmpty;
  }
}
