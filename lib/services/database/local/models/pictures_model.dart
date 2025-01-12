class PictureModel {
  final int? pictureId;
  final int userId;
  final int userMissionId;
  final String photoPath;
  final bool isCollage;
  final DateTime? createdAt;

  PictureModel({
    this.pictureId,
    required this.userId,
    required this.userMissionId,
    required this.photoPath,
    this.isCollage = false,
    this.createdAt,
  });

  factory PictureModel.fromMap(Map<String, dynamic> map) {
    return PictureModel(
      pictureId: map['pictureId'],
      userId: map['userId'],
      userMissionId: map['userMissionId'],
      photoPath: map['photoPath'],
      isCollage: map['isCollage'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

Map<String, dynamic> toMap() {
    return {
      if (pictureId != null) 'pictureId': pictureId,
      'userId': userId,
      'userMissionId': userMissionId,
      'photoPath': photoPath,
      'isCollage': isCollage ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
}
}
