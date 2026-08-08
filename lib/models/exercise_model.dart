import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String targetMuscle;
  final String level;
  final String type;
  final int duration;
  final String description;
  final List<Map<String, String>> youtubeVideos;
  final DateTime createdAt;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.level,
    required this.type,
    required this.duration,
    required this.description,
    this.youtubeVideos = const [],
    required this.createdAt,
  });

  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExerciseModel.fromMap(data, doc.id);
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> data, String docId) {
    return ExerciseModel(
      id: docId,
      name: data['name'] ?? '',
      targetMuscle: data['targetMuscle'] ?? '',
      level: data['level'] ?? 'Pemula',
      type: data['type'] ?? 'Repetisi',
      duration: (data['duration'] ?? 0).toInt(),
      description: data['description'] ?? '',
      youtubeVideos: (data['youtubeVideos'] as List<dynamic>?)
              ?.map((item) => Map<String, String>.from(item as Map))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}
