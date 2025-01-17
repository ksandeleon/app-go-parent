import 'package:sqflite/sqflite.dart';
import 'package:go_parent/services/database/local/models/collage_model.dart';

class CollageHelper {
  final Database db;

  CollageHelper(this.db);

  /// Insert a new collage into the database
  Future<int> insertCollage(CollageModel collage) async {
    try {
      return await db.insert(
        'collagedb',
        collage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting collage: $e");
      return -1;
    }
  }

    /// Retrieve all collages by userId
  Future<List<CollageModel>> getAllCollagesByUserId(int userId) async {
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'collagedb',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return result.map((map) => CollageModel.fromMap(map)).toList();
    } catch (e) {
      print("Error retrieving collages by userId: $e");
      return []; // Return an empty list in case of an error
    }
  }

  /// Retrieve a collage by ID
  Future<CollageModel?> getCollageById(int collageId) async {
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'collagedb',
        where: 'collageId = ?',
        whereArgs: [collageId],
      );

      if (result.isNotEmpty) {
        return CollageModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print("Error retrieving collage by ID: $e");
      return null;
    }
  }


  /// Retrieve all collages by title (if needed)
  Future<List<CollageModel>> getCollagesByTitle(String title) async {
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'collagedb',
        where: 'title LIKE ?',
        whereArgs: ['%$title%'],
      );

      return result.map((map) => CollageModel.fromMap(map)).toList();
    } catch (e) {
      print("Error retrieving collages by title: $e");
      return [];
    }
  }

  /// Update collage details
  Future<int> updateCollage(CollageModel collage) async {
    try {
      return await db.update(
        'collagedb',
        collage.toMap(),
        where: 'collageId = ?',
        whereArgs: [collage.collageId],
      );
    } catch (e) {
      print("Error updating collage: $e");
      return -1;
    }
  }

  /// Delete a collage by ID
  Future<int> deleteCollage(int collageId) async {
    try {
      return await db.delete(
        'collagedb',
        where: 'collageId = ?',
        whereArgs: [collageId],
      );
    } catch (e) {
      print("Error deleting collage: $e");
      return -1;
    }
  }

  /// Count total collages in the database
  Future<int> countCollages() async {
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM collagedb');
      return result.first['count'] as int;
    } catch (e) {
      print("Error counting collages: $e");
      return 0;
    }
  }

}
