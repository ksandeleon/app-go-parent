class CollagePictures {
  final int collageId;
  final int pictureId;

  CollagePictures({
    required this.collageId,
    required this.pictureId,
  });

  // Create a CollagePictures instance from a map (useful when reading from database)
  factory CollagePictures.fromMap(Map<String, dynamic> map) {
    return CollagePictures(
      collageId: map['collageId'] as int,
      pictureId: map['pictureId'] as int,
    );
  }

  // Convert a CollagePictures instance to a map (useful when writing to database)
  Map<String, dynamic> toMap() {
    return {
      'collageId': collageId,
      'pictureId': pictureId,
    };
  }

  // Override toString for easier debugging
  @override
  String toString() {
    return 'CollagePictures(collageId: $collageId, pictureId: $pictureId)';
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CollagePictures &&
      other.collageId == collageId &&
      other.pictureId == pictureId;
  }

  // Override hashCode
  @override
  int get hashCode => collageId.hashCode ^ pictureId.hashCode;

  // Create a copy of this CollagePictures with modified fields
  CollagePictures copyWith({
    int? collageId,
    int? pictureId,
  }) {
    return CollagePictures(
      collageId: collageId ?? this.collageId,
      pictureId: pictureId ?? this.pictureId,
    );
  }
}
