class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final String category; // weight_loss, muscle_building, general_fitness
  final String difficulty;
  final int estimatedDuration; // minutes
  final int estimatedCalories;
  final String thumbnailUrl;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.thumbnailUrl,
    required this.exercises,
    required this.createdAt,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'beginner',
      estimatedDuration: map['estimatedDuration'] ?? 0,
      estimatedCalories: map['estimatedCalories'] ?? 0,
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      exercises:
          (map['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e))
              .toList() ??
          [],
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
      'category': category,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'estimatedCalories': estimatedCalories,
      'thumbnailUrl': thumbnailUrl,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final int duration; // seconds
  final int restTime; // seconds

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.restTime,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 0,
      duration: map['duration'] ?? 0,
      restTime: map['restTime'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'restTime': restTime,
    };
  }
}
