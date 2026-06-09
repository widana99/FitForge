import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final double? height;
  final String? workoutGoal;
  final String? trainingLevel;
  final String? avatarUrl;
  final bool hasEquipment;
  final String flowPreference;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final int streak;
  final int totalWorkouts;
  final double totalCalories;
  final int totalDuration;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.height,
    this.workoutGoal,
    this.trainingLevel,
    this.avatarUrl,
    this.hasEquipment = false,
    this.flowPreference = 'guided',
    required this.createdAt,
    required this.lastActiveAt,
    this.streak = 0,
    this.totalWorkouts = 0,
    this.totalCalories = 0,
    this.totalDuration = 0,
  });

  bool get isPro => flowPreference == 'efficient';

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  double get bmi {
    if (weight == null || height == null || height == 0) return 0;
    return weight! / ((height! / 100) * (height! / 100));
  }

  String get bmiCategory {
    final b = bmi;
    if (b == 0) return '-';
    if (b < 18.5) return 'Kurus';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Gemuk';
    return 'Obesitas';
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: map['gender'],
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      workoutGoal: map['workoutGoal'],
      trainingLevel: map['trainingLevel'],
      avatarUrl: map['avatarUrl'],
      hasEquipment: map['hasEquipment'] ?? false,
      flowPreference: map['flowPreference'] ?? 'guided',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActiveAt: map['lastActiveAt'] != null
          ? (map['lastActiveAt'] as Timestamp).toDate()
          : DateTime.now(),
      streak: map['streak'] ?? 0,
      totalWorkouts: map['totalWorkouts'] ?? 0,
      totalCalories: (map['totalCalories'] as num?)?.toDouble() ?? 0,
      totalDuration: map['totalDuration'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'weight': weight,
      'height': height,
      'workoutGoal': workoutGoal,
      'trainingLevel': trainingLevel,
      'avatarUrl': avatarUrl,
      'hasEquipment': hasEquipment,
      'flowPreference': flowPreference,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'streak': streak,
      'totalWorkouts': totalWorkouts,
      'totalCalories': totalCalories,
      'totalDuration': totalDuration,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    String? workoutGoal,
    String? trainingLevel,
    String? avatarUrl,
    bool? hasEquipment,
    String? flowPreference,
    int? streak,
    int? totalWorkouts,
    double? totalCalories,
    int? totalDuration,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      workoutGoal: workoutGoal ?? this.workoutGoal,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasEquipment: hasEquipment ?? this.hasEquipment,
      flowPreference: flowPreference ?? this.flowPreference,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      streak: streak ?? this.streak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalCalories: totalCalories ?? this.totalCalories,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}
