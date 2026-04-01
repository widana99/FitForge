class ExerciseModel {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String difficulty;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration; // seconds, 0 if rep-based
  final int reps; // 0 if time-based
  final int sets;
  final List<String> tips;
  final List<String> equipment;
  final DateTime createdAt;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.difficulty,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.duration = 0,
    this.reps = 0,
    this.sets = 3,
    this.tips = const [],
    this.equipment = const [],
    required this.createdAt,
  });

  bool get isTimeBased => duration > 0;
  bool get isRepBased => reps > 0;

  factory ExerciseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExerciseModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      difficulty: map['difficulty'] ?? 'beginner',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      duration: map['duration'] ?? 0,
      reps: map['reps'] ?? 0,
      sets: map['sets'] ?? 3,
      tips: List<String>.from(map['tips'] ?? []),
      equipment: List<String>.from(map['equipment'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'difficulty': difficulty,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'reps': reps,
      'sets': sets,
      'tips': tips,
      'equipment': equipment,
      'createdAt': createdAt,
    };
  }
}
