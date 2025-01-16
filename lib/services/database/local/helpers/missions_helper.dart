import 'package:sqflite/sqflite.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';


class MissionHelper {
  final Database db;

  MissionHelper(this.db);



Future<void> insertAllMissions() async {
  final missions = [
    // 1 to 3 months
    MissionModel(
      title: 'Create a Facebook Messenger group',
      category: 'Social',
      content: 'Connect with local parents who have babies the same age',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    MissionModel(
      title: 'Share one baby moment daily',
      category: 'Social',
      content: "Post a photo or story about today's feeding, sleeping, or playtime",
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),

    ),
    MissionModel(
      title: 'Join a 10-minute video call for baby songs',
      category: 'Social',
      content: 'Learn and sing traditional Filipino lullabies together',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // 4 to 6 months
    MissionModel(
      title: 'Visit the local market with your baby',
      category: 'Social',
      content: 'Introduce baby to 3 friendly vendors and take photos',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Arrange an outdoor meet with another parent',
      category: 'Social',
      content: 'Share baby tips while babies observe each other',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Document and share a new baby skill',
      category: 'Social',
      content: "Take a video of baby's newest achievement",
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // 7 to 9 months
    MissionModel(
      title: 'Host a simple art session with another baby',
      category: 'Social',
      content: 'Create handprints using safe, edible materials',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Share mealtime with another baby',
      category: 'Social',
      content: 'Practice safe shared mealtimes while babies observe each other',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Connect with grandparents through video call',
      category: 'Social',
      content: 'Show new skills to family members online',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // 10 to 12 months
    MissionModel(
      title: 'Visit three community helpers',
      category: 'Social',
      content: 'Meet your local sari-sari store owner, guard, or street sweeper',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Join or host a mini baby talent showcase',
      category: 'Social',
      content: 'Share a song, dance, or skill with other babies',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Visit a neighbor’s garden with baby',
      category: 'Social',
      content: 'Explore plants and nature with another family',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Toddler years (1-3)
    MissionModel(
      title: 'Form a weekly playgroup with toddlers',
      category: 'Social',
      content: 'Take turns hosting simple play sessions',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Join community clean-up with your toddler',
      category: 'Social',
      content: 'Practice simple volunteering while socializing',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Create and exchange artwork with toddlers',
      category: 'Social',
      content: 'Make simple drawings to give to friends',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Preschool years (4-5)
    MissionModel(
      title: 'Start a mini reading group',
      category: 'Social',
      content: 'Take turns sharing picture books with 2-3 children',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Plant seeds with neighbor children',
      category: 'Social',
      content: 'Grow simple vegetables in recycled containers together',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Organize a simple neighborhood show',
      category: 'Social',
      content: 'Present songs or dances with other children',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

      // Creative Missions 1-3 months
    MissionModel(
      title: 'Introduce one new color daily',
      category: 'Creative',
      content: 'Show baby different red objects for 5 minutes, repeat with new colors daily',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Create different sounds using household items',
      category: 'Creative',
      content: 'Make gentle music with spoons, containers, or bottles',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Math Missions 1-3 months
    MissionModel(
      title: 'Count out loud during daily routines',
      category: 'Math',
      content: 'Count 1-3 during diaper changes, feeding, or playtime',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Create simple sound patterns',
      category: 'Math',
      content: 'Alternate between two distinct sounds (tap-clap-tap-clap)',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Creative Missions 4-6 months
    MissionModel(
      title: 'Create a touch-and-feel book',
      category: 'Creative',
      content: 'Attach different fabrics to cardboard pages',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Arrange baby food in simple shapes',
      category: 'Creative',
      content: 'Create simple shapes with pureed food during mealtimes',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Math Missions 4-6 months
    MissionModel(
      title: 'Point out basic shapes in daily objects',
      category: 'Math',
      content: 'Find circles and squares around the house',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Compare quantities during daily activities',
      category: 'Math',
      content: 'Show "more" rice vs "less" rice during meals',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Creative Missions 7-9 months
    MissionModel(
      title: 'Create edible finger paint',
      category: 'Creative',
      content: 'Use mashed vegetables for color exploration',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Build simple instruments from recyclables',
      category: 'Creative',
      content: 'Create shakers using plastic bottles and dried beans',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Math Missions 7-9 months
    MissionModel(
      title: 'Sort similar objects during playtime',
      category: 'Math',
      content: 'Group spoons, clothespins, or bottle caps by color',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Compare object sizes during daily routines',
      category: 'Math',
      content: 'Find big and small versions of the same item',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Creative Missions 10-12 months
    MissionModel(
      title: 'Create an art display using handprints',
      category: 'Creative',
      content: 'Make monthly handprint art using safe paint',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Create simple dance moves',
      category: 'Creative',
      content: 'Make up three easy movements to favorite tunes',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Math Missions 10-12 months
    MissionModel(
      title: 'Count steps during daily activities',
      category: 'Math',
      content: 'Count 1-5 steps while walking with support',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Create basic shapes using household items',
      category: 'Math',
      content: 'Make circles and squares using string or sticks',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Creative Missions Toddler Years (12-36 months)
    MissionModel(
      title: 'Make simple picture stories',
      category: 'Creative',
      content: 'Cut and paste pictures to create a story sequence',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Experiment with color mixing',
      category: 'Creative',
      content: 'Mix primary colors to discover new ones',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Math Missions Toddler Years (12-36 months)
    MissionModel(
      title: 'Count fruits during market trips',
      category: 'Math',
      content: 'Count up to 5 items while shopping',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Create patterns with everyday objects',
      category: 'Math',
      content: 'Arrange items in simple sequences (spoon-fork-spoon-fork)',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Creative Missions Preschool Years (48-60 months)
    MissionModel(
      title: 'Create sculptures from recyclables',
      category: 'Creative',
      content: 'Build animals or vehicles using boxes and bottles',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Make art using natural materials',
      category: 'Creative',
      content: 'Create pictures using leaves, flowers, and stones',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Math Missions Preschool Years (48-60 months)
    MissionModel(
      title: 'Practice simple addition with coins',
      category: 'Math',
      content: 'Count small amounts using real or play money',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Find geometric shapes in environment',
      category: 'Math',
      content: 'Identify circles, squares, triangles in daily life',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Physical Development Missions 1-3 months
    MissionModel(
      title: 'Complete tummy time sessions',
      category: 'Physical',
      content: 'Place baby on clean mat for supervised tummy play',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Practice gentle leg movements',
      category: 'Physical',
      content: "Guide baby's legs in cycling motion for 1 minute",
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Help baby reach for objects',
      category: 'Physical',
      content: 'Dangle colorful cloth strips for tracking practice',
      minAge: 1,
      maxAge: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Physical Development Missions 4-6 months
    MissionModel(
      title: 'Support baby in sitting position',
      category: 'Physical',
      content: 'Use pillows or clean rice sacks for back support',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Practice grabbing safe objects',
      category: 'Physical',
      content: 'Offer wooden spoons or plastic cups for grasping',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Encourage rolling practice',
      category: 'Physical',
      content: 'Guide baby from back to tummy and reverse',
      minAge: 4,
      maxAge: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Physical Development Missions 7-9 months
    MissionModel(
      title: 'Create safe crawling path',
      category: 'Physical',
      content: 'Place toys at increasing distances on clean mat',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Practice supported standing',
      category: 'Physical',
      content: 'Use sturdy furniture for balance practice',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Set up mini obstacle course',
      category: 'Physical',
      content: 'Guide baby through crawling challenges',
      minAge: 7,
      maxAge: 9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Physical Development Missions 10-12 months
    MissionModel(
      title: 'Create safe walking path',
      category: 'Physical',
      content: 'Use old clothes as cushions along furniture',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Practice ball play',
      category: 'Physical',
      content: 'Roll soft ball back and forth',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Learn hand coordination games',
      category: 'Physical',
      content: 'Learn simple hand movements to songs',
      minAge: 10,
      maxAge: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Physical Development Missions Toddler Years (12-36 months)
    MissionModel(
      title: 'Create safe running path',
      category: 'Physical',
      content: 'Mark start and finish lines for supervised runs',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Practice jumping',
      category: 'Physical',
      content: 'Make safe landing spots with old clothes',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Practice throwing at targets',
      category: 'Physical',
      content: 'Use cloth balls and boxed targets',
      minAge: 12,
      maxAge: 36,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Physical Development Missions Preschool Years (48-60 months)
    MissionModel(
      title: 'Practice animal movements',
      category: 'Physical',
      content: 'Practice hopping, crawling, and jumping like animals',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Walk on straight line',
      category: 'Physical',
      content: 'Practice balance with arms out',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MissionModel(
      title: 'Learn simple dance moves',
      category: 'Physical',
      content: 'Practice coordination through guided dancing',
      minAge: 48,
      maxAge: 60,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  print("mission insert success");

  for (final mission in missions) {
    await db.insert(
      'missionsdb',
      mission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}


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
