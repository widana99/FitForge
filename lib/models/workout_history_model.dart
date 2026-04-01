class WorkoutHistoryModel {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime date;
  final int duration; // seconds
  final double caloriesBurned;
  final int exercisesCompleted;
  final int totalExercises;
  final int rating;
  final List<String> completedExercises;

  WorkoutHistoryModel({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
    required this.exercisesCompleted,
    required this.totalExercises,
    this.rating = 0,
    this.completedExercises = const [],
  });

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }

  double get completionRate =>
      totalExercises > 0 ? exercisesCompleted / totalExercises : 0;

  factory WorkoutHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutHistoryModel(
      id: id,
      workoutId: map['workoutId'] ?? '',
      workoutName: map['workoutName'] ?? '',
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['date'].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      duration: map['duration'] ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0,
      exercisesCompleted: map['exercisesCompleted'] ?? 0,
      totalExercises: map['totalExercises'] ?? 0,
      rating: map['rating'] ?? 0,
      completedExercises: List<String>.from(map['completedExercises'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'workoutName': workoutName,
      'date': date,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'exercisesCompleted': exercisesCompleted,
      'totalExercises': totalExercises,
      'rating': rating,
      'completedExercises': completedExercises,
    };
  }
}
