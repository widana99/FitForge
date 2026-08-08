import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutPresets {
  static final List<String> motivationQuotes = [
    'Disiplin adalah kunci transformasi diri. 💪',
    'Jangan berhenti saat lelah, berhentilah saat selesai. 🔥',
    'Menurut studi, konsistensi 3 minggu akan membangun kebiasaan permanen. ❤️',
    'Otot dibangun dari 80% nutrisi dan 20% robekan mikro. ✨',
    'Kekuatan hipertrofi terlahir dari pengulangan konstan dekat ambang batas maksimal. ⚡',
  ];

  static const String featuredImg = 'featured_workout_bg_1775675212480.png';
  static const String yogaImg = 'yoga_workout_thumb_1775675252378.png';
  static const String strengthImg = 'strength_workout_thumb_1775675353599.png';

  static String stringImg(String s) => strengthImg;

  static Future<WorkoutModel> getRecommendation(String goal, String level) async {
    final recommendations = await getRelatedRecommendations(goal, level);
    return recommendations.first;
  }

  // ==========================================
  // GENERATOR REKOMENDASI TERKAIT
  // ==========================================
  static Future<List<WorkoutModel>> getRelatedRecommendations(String goal, String level) async {
    if (goal == 'fat_loss') {
      final absList = await getWorkoutsByFocus('Otot Perut', level);
      final fullList = await getWorkoutsByFocus('Seluruh Tubuh', level);
      return [
        absList.first,
        fullList.last,
      ];
    } else if (goal == 'muscle_building') {
      final armsList = await getWorkoutsByFocus('Lengan', level);
      final glutesList = await getWorkoutsByFocus('Bokong/Pinggul', level);
      return [
        armsList.first,
        glutesList.first,
      ];
    }
    
    final fullList = await getWorkoutsByFocus('Seluruh Tubuh', level);
    final legsList = await getWorkoutsByFocus('Kaki', level);
    return [
       fullList.first,
       legsList.last,
    ];
  }

  static WorkoutModel _createCustomModel(String name, String desc, String goal, String level, int dur, int cal, String thumb, List<WorkoutExercise> ex) {
    return WorkoutModel(
      id: 'gen_${name.hashCode}',
      name: name,
      description: desc,
      category: goal,
      difficulty: level,
      estimatedDuration: dur,
      estimatedCalories: cal,
      thumbnailUrl: thumb,
      exercises: ex,
      createdAt: DateTime.now(),
    );
  }

  // ==========================================
  // ALGORITMA FOKUS TUBUH (FIRESTORE)
  // ==========================================
  static Future<List<WorkoutModel>> getWorkoutsByFocus(String focusStr, String level) async {
    List<String> targetTags = [];
    if (focusStr == 'Seluruh Tubuh') targetTags = ['Seluruh Tubuh', 'Kardiovaskular'];
    else if (focusStr == 'Otot Perut') targetTags = ['Perut', 'Inti', 'Abdomen'];
    else if (focusStr == 'Bokong/Pinggul') targetTags = ['Bokong', 'Pinggul', 'Gluteus'];
    else if (focusStr == 'Lengan') targetTags = ['Lengan', 'Bahu', 'Pektoral'];
    else if (focusStr == 'Kaki') targetTags = ['Kaki', 'Quadrisep', 'Hamstring'];
    else targetTags = ['Seluruh Tubuh'];

    String strLevel = level == 'beginner' ? 'Pemula' : (level == 'intermediate' ? 'Menengah' : 'Mahir');
    
    // 1. Ambil semua data gerakan dari Firestore
    final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
    
    // 2. Filter data secara lokal
    List<WorkoutExercise> matchedExercises = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final targetMuscle = (data['targetMuscle'] ?? '').toString();
      final exerciseLevel = (data['level'] ?? '').toString();
      final name = (data['name'] ?? '').toString();
      final type = (data['type'] ?? '').toString();
      
      bool matchesFocus = targetTags.any((t) => targetMuscle.contains(t));
      bool matchesLevel = exerciseLevel.contains(strLevel);
      
      if (matchesFocus && matchesLevel) {
        int finalDuration = level == 'beginner' ? 30 : (level == 'intermediate' ? 45 : 60);
        int finalReps = 0;

        // Cek tipe: Waktu vs Repetisi
        if (type == 'Waktu' || name.toLowerCase().contains('plank') || name.toLowerCase().contains('hold')) {
            finalDuration = 45;
            finalReps = 0;
        } else {
            finalReps = (data['duration'] ?? 12).toInt();
            finalDuration = 0; // durasi 0 jika repetisi
        }

        matchedExercises.add(WorkoutExercise(
          exerciseId: doc.id,
          exerciseName: name,
          sets: level == 'beginner' ? 3 : (level == 'intermediate' ? 4 : 5),
          reps: finalReps,
          duration: finalDuration,
          restTime: level == 'beginner' ? 30 : 20,
        ));
      }
    }

    final list = <WorkoutModel>[];
    matchedExercises.shuffle();
    
    if (matchedExercises.length >= 6) {
      int half = matchedExercises.length ~/ 2;
      list.add(_createCustomModel(
        'Intensif $focusStr A', 
        'Repertoar hipertrofi sudut otot variatif.', 
        'focus', level, 12 + half * 2, 120 + half * 20, strengthImg, 
        matchedExercises.sublist(0, half)
      ));
      list.add(_createCustomModel(
        'Intensif $focusStr B', 
        'Stimulasi serat otot tak terduga.', 
        'focus', level, 12 + half * 2, 120 + half * 20, yogaImg, 
        matchedExercises.sublist(half)
      ));
    } else {
      list.add(_createCustomModel(
        'Fokus Utama: $focusStr', 
        'Konsumsi target terfokus area $focusStr spesifik bersama Pro Guide.', 
        'focus', level, 10 + matchedExercises.length * 3, 100 + matchedExercises.length * 25, featuredImg, 
        matchedExercises
      ));
    }

    // Hindari mengembalikan list kosong (fallback)
    if (list.isEmpty) {
        list.add(_createCustomModel('Kebugaran Basis $focusStr', 'Paket transisi aman.', 'focus', level, 15, 100, featuredImg, [WorkoutExercise(exerciseId: 'plank', exerciseName: 'Plank Fungsional', sets: 3, reps: 0, duration: 45, restTime: 30)]));
    }

    return list;
  }

  // ==========================================
  // ALGORITMA TUBUH BERBASIS GOALS (FIRESTORE)
  // ==========================================
  static Future<List<WorkoutModel>> getWorkoutsByGoal(String goalKey, String level) async {
    List<String> targetTags = [];
    int baseSets = 3;
    int restTime = 30;
    
    if (goalKey == 'fat_loss') {
      targetTags = ['Perut', 'Inti', 'Kaki', 'Quadrisep', 'Hamstring', 'Kardiovaskular'];
      baseSets = level == 'beginner' ? 3 : 4;
      restTime = 15; // True HIIT
    } else if (goalKey == 'muscle_building') {
      targetTags = ['Lengan', 'Bahu', 'Pektoral', 'Bokong', 'Dada'];
      baseSets = level == 'beginner' ? 4 : 5; 
      restTime = 60; // Hypertrophy rest
    } else {
      targetTags = ['Perut', 'Lengan', 'Kaki', 'Quadrisep', 'Pektoral'];
      baseSets = level == 'beginner' ? 3 : 4;
      restTime = 30; 
    }

    String strLevel = level == 'beginner' ? 'Pemula' : (level == 'intermediate' ? 'Menengah' : 'Mahir');
    
    final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
    
    List<WorkoutExercise> matchedExercises = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final targetMuscle = (data['targetMuscle'] ?? '').toString();
      final exerciseLevel = (data['level'] ?? '').toString();
      final type = (data['type'] ?? '').toString();
      final name = (data['name'] ?? '').toString();
      
      bool matchesFocus = targetTags.any((t) => targetMuscle.contains(t));
      bool matchesLevel = exerciseLevel.contains(strLevel);
      
      if (matchesFocus && matchesLevel) {
        int finalDuration = goalKey == 'fat_loss' ? 30 : (goalKey == 'muscle_building' ? 60 : 45);
        int finalReps = 0;

        if (type == 'Waktu' || name.toLowerCase().contains('plank') || name.toLowerCase().contains('hold')) {
            finalDuration = 60;
            finalReps = 0;
        } else {
            finalReps = (data['duration'] ?? 12).toInt();
            finalDuration = 0;
        }

        matchedExercises.add(WorkoutExercise(
          exerciseId: doc.id,
          exerciseName: name,
          sets: baseSets,
          reps: finalReps,
          duration: finalDuration,
          restTime: restTime,
        ));
      }
    }

    matchedExercises.shuffle();
    if (matchedExercises.length > 7) {
      matchedExercises = matchedExercises.sublist(0, 7);
    }
    
    String title = goalKey == 'fat_loss' ? 'Sirkuit Lemak' : (goalKey == 'muscle_building' ? 'Hipertrofi Max' : 'Kebugaran Total');
    String desc = goalKey == 'fat_loss' ? 'Jeda istirahat sangat singkat. Bakar kalori secara brutal!' : (goalKey == 'muscle_building' ? 'Repetisi rendah, beban tinggi. Istirahat 60 detik.' : 'Proporsi seimbang seluruh tulang dan sendi.');

    int totalEstimatedSeconds = 0;
    for (var ex in matchedExercises) {
      int timePerSet = ex.duration > 0 ? ex.duration : (ex.reps * 3); 
      totalEstimatedSeconds += (timePerSet + ex.restTime) * ex.sets;
    }
    int estimatedMinutes = (totalEstimatedSeconds / 60).ceil();
    if (estimatedMinutes < 5) estimatedMinutes = 5; 

    int calMultiplier = goalKey == 'fat_loss' ? 12 : (goalKey == 'muscle_building' ? 8 : 10);
    int totalCalories = estimatedMinutes * calMultiplier;

    final list = <WorkoutModel>[];
    if (matchedExercises.isNotEmpty) {
      list.add(_createCustomModel(
        title, 
        desc, 
        goalKey, level, estimatedMinutes, totalCalories, featuredImg, 
        matchedExercises
      ));
    } else {
      list.add(_createCustomModel('Kebugaran Basis', 'Paket transisi aman.', goalKey, level, 15, 100, featuredImg, [WorkoutExercise(exerciseId: 'plank', exerciseName: 'Plank Fungsional', sets: 3, reps: 0, duration: 45, restTime: 30)]));
    }

    return list;
  }
}
