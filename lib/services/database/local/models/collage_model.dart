class CollageModel {
  int? collageId;
  int userId;
  String title;
  String? collageData;
  DateTime createdAt;
  DateTime updatedAt;

  CollageModel({
    this.collageId,
    required this.userId,
    required this.title,
    this.collageData,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert a Collage object into a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'collageId': collageId,
      'userId': userId,
      'title': title,
      'collageData': collageData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert a map into a Collage object
  factory CollageModel.fromMap(Map<String, dynamic> map) {
    return CollageModel(
      collageId: map['collageId'],
      userId: map['userId'],
      title: map['title'],
      collageData: map['collageData'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

}
