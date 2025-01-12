class UserMission {
  final int? userMissionId;
  final int userId;
  final int missionId;
  final bool isCompleted;
  final DateTime? completedAt;

  UserMission({
    this.userMissionId,
    required this.userId,
    required this.missionId,
    this.isCompleted = false,
    this.completedAt,
  });

  // Factory constructor to create a UserMission object from a map (database row).
  factory UserMission.fromMap(Map<String, dynamic> map) {
    return UserMission(
      userMissionId: map['userMissionId'] as int?,
      userId: map['userId'] as int,
      missionId: map['missionId'] as int,
      isCompleted: map['isCompleted'] == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }

  // Method to convert a UserMission object to a map (for database insertion).
  Map<String, dynamic> toMap() {
    return {
      'userMissionId': userMissionId,
      'userId': userId,
      'missionId': missionId,
      'isCompleted': isCompleted ? 1 : 0, // Convert boolean to integer
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}



