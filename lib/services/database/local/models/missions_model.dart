class MissionModel {
  final int? missionId;
  final String title;
  final String category;
  final String content;
  final int minAge;
  final int maxAge;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionModel({
    this.missionId,
    required this.title,
    required this.category,
    required this.content,
    required this.minAge,
    required this.maxAge,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a MissionModel from a database map
  factory MissionModel.fromMap(Map<String, dynamic> map) {
    print("Parsing MissionModel from map: $map");
    return MissionModel(
      missionId: map['missionId'] as int?,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      content: map['content'] as String? ?? '',
      minAge: map['minAge'] as int? ?? 0,
      maxAge: map['maxAge'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  // Method to convert a MissionModel to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'missionId': missionId,
      'title': title,
      'category': category,
      'content': content,
      'minAge': minAge,
      'maxAge': maxAge,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
