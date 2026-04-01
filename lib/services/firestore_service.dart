import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/workout_history_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User Operations ──
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ── Schedule Operations ──
  Future<void> setSchedule(String uid, List<ScheduleModel> schedules) async {
    final batch = _db.batch();
    // Clear existing schedules
    final existing = await _db
        .collection('users')
        .doc(uid)
        .collection('schedule')
        .get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    // Add new ones
    for (final schedule in schedules) {
      final ref = _db.collection('users').doc(uid).collection('schedule').doc();
      batch.set(ref, schedule.toMap());
    }
    await batch.commit();
  }

  Stream<List<ScheduleModel>> scheduleStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('schedule')
        .orderBy('dayOfWeek')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ScheduleModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ── Exercise Operations ──
  Stream<List<ExerciseModel>> exercisesStream({String? muscleGroup}) {
    Query<Map<String, dynamic>> query = _db.collection('exercises');
    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      query = query.where('muscleGroup', isEqualTo: muscleGroup);
    }
    return query.snapshots().map(
      (snap) => snap.docs
          .map((doc) => ExerciseModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<ExerciseModel?> getExercise(String id) async {
    final doc = await _db.collection('exercises').doc(id).get();
    if (!doc.exists) return null;
    return ExerciseModel.fromMap(doc.data()!, id);
  }

  // ── Workout Operations ──
  Stream<List<WorkoutModel>> workoutsStream({
    String? category,
    String? difficulty,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('workouts');
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }
    return query.snapshots().map(
      (snap) => snap.docs
          .map((doc) => WorkoutModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // ── Workout History Operations ──
  Future<void> saveWorkoutHistory(
    String uid,
    WorkoutHistoryModel history,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('workoutHistory')
        .add(history.toMap());

    // Update user stats
    await _db.collection('users').doc(uid).update({
      'totalWorkouts': FieldValue.increment(1),
      'totalCalories': FieldValue.increment(history.caloriesBurned),
      'totalDuration': FieldValue.increment(history.duration),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<WorkoutHistoryModel>> workoutHistoryStream(
    String uid, {
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .doc(uid)
        .collection('workoutHistory')
        .orderBy('date', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots().map(
      (snap) => snap.docs
          .map((doc) => WorkoutHistoryModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // ── Weight Log Operations ──
  Future<void> addWeightLog(String uid, double weight) async {
    await _db.collection('users').doc(uid).collection('weightLog').add({
      'weight': weight,
      'date': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(uid).update({'weight': weight});
  }

  Stream<List<WeightLogModel>> weightLogStream(String uid, {int? limit}) {
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .doc(uid)
        .collection('weightLog')
        .orderBy('date', descending: false);
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots().map(
      (snap) => snap.docs
          .map((doc) => WeightLogModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // ── Reminder Settings ──
  Future<void> saveReminderSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminderSettings')
        .doc('settings')
        .set(settings, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getReminderSettings(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('reminderSettings')
        .doc('settings')
        .get();
    return doc.data();
  }
}
