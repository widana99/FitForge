import '../models/workout_model.dart';
import 'dart:math';

// Mengimpor database modular yang sangat ekstensif dan tersertifikasi.
import 'data/upper_body_db.dart';
import 'data/core_glutes_db.dart';
import 'data/lower_full_db.dart';

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

  // ==========================================
  // DATABASE GERAKAN GABUNGAN MODULAR (100% BEBAS BLEEDING)
  // Menyerap 3 file raksasa untuk performa memori optimal.
  // ==========================================
  static final Map<String, Map<String, dynamic>> exerciseDB = {
    ...upperBodyDB,
    ...coreGluteDB,
    ...lowerFullDB,
  };

  static String stringImg(String s) => strengthImg; // fallback

  static WorkoutModel getRecommendation(String goal, String level, bool hasEquipment) {
    return getRelatedRecommendations(goal, level, hasEquipment).first;
  }

  // ==========================================
  // GENERATOR REKOMENDASI TERKAIT (DINAMIS HOMESCREEN)
  // ==========================================
  static List<WorkoutModel> getRelatedRecommendations(String goal, String level, bool hasEquipment) {
    if (goal == 'fat_loss') {
      return [
        getWorkoutsByFocus('Otot Perut', level, hasEquipment).first,
        getWorkoutsByFocus('Seluruh Tubuh', level, hasEquipment).last,
      ];
    } else if (goal == 'muscle_building') {
      return [
        getWorkoutsByFocus('Lengan', level, hasEquipment).first,
        getWorkoutsByFocus('Bokong/Pinggul', level, hasEquipment).first,
      ];
    }
    return [
       getWorkoutsByFocus('Seluruh Tubuh', level, hasEquipment).first,
       getWorkoutsByFocus('Kaki', level, hasEquipment).last,
    ];
  }

  // Fungsi helper konstruktor
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
  // ALGORITMA FOKUS TUBUH (STRICT NO-BLEEDING ALGORITHM)
  // ==========================================
  static List<WorkoutModel> getWorkoutsByFocus(String focusStr, String level, bool hasEquipment) {
    List<String> targetTags = [];
    if (focusStr == 'Seluruh Tubuh') targetTags = ['Seluruh Tubuh'];
    else if (focusStr == 'Otot Perut') targetTags = ['Perut'];
    else if (focusStr == 'Bokong/Pinggul') targetTags = ['Bokong'];
    else if (focusStr == 'Lengan') targetTags = ['Lengan', 'Bahu'];
    else if (focusStr == 'Kaki') targetTags = ['Kaki'];
    else targetTags = ['Seluruh Tubuh'];

    String strEquip = hasEquipment ? 'Alat' : 'Tanpa Alat';
    String strLevel = level == 'beginner' ? 'Pemula' : (level == 'intermediate' ? 'Menengah' : 'Mahir');
    
    // 2. Kumpulkan exercises mutlak ketat dari DB Gabungan
    List<WorkoutExercise> matchedExercises = [];
    exerciseDB.forEach((id, data) {
      List<String> tags = List<String>.from(data['tags']);
      
      bool matchesFocus = targetTags.any((t) => tags.contains(t));
      bool matchesEquip = tags.contains(strEquip); // WAJIB alat benar
      bool matchesLevel = tags.contains(strLevel); // WAJIB tier level benar
      
      if (matchesFocus && matchesEquip && matchesLevel) {
        int finalDuration = 0;
        int finalReps = 0;
        
        if (!hasEquipment) {
            // TIME-BASED for Bodyweight
            finalDuration = level == 'beginner' ? 30 : (level == 'intermediate' ? 45 : 60);
            finalReps = 0; // UI will use timer
        } else {
            // REP-RANGE for Equipment
            finalReps = level == 'beginner' ? 12 : 15;
            finalDuration = 0;
        }

        // Special override for planks
        if (data['name'].toLowerCase().contains('plank') || data['name'].toLowerCase().contains('hold')) {
            finalDuration = 45;
            finalReps = 0;
        }

        matchedExercises.add(WorkoutExercise(
          exerciseId: id,
          exerciseName: data['name'],
          sets: level == 'beginner' ? 3 : (level == 'intermediate' ? 4 : 5),
          reps: finalReps,
          duration: finalDuration,
          restTime: level == 'beginner' ? 30 : 20,
        ));
      }
    });

    final list = <WorkoutModel>[];
    matchedExercises.shuffle();
    
    if (matchedExercises.length >= 6) {
      int half = matchedExercises.length ~/ 2;
      list.add(_createCustomModel(
        'Intensif $focusStr A (${hasEquipment ? "Alat" : "Beban Badan"})', 
        'Repertoar hipertrofi sudut otot variatif kelas eksekutif medis.', 
        'focus', level, 12 + half * 2, 120 + half * 20, strengthImg, 
        matchedExercises.sublist(0, half)
      ));
      list.add(_createCustomModel(
        'Intensif $focusStr B (${hasEquipment ? "Alat" : "Beban Badan"})', 
        'Perputaran rotasi baru khusus menjangkau stimulasi serat otot tak terduga.', 
        'focus', level, 12 + half * 2, 120 + half * 20, yogaImg, 
        matchedExercises.sublist(half)
      ));
    } else {
      list.add(_createCustomModel(
        'Fokus Utama: $focusStr', 
        'Konsumsi target terfokus memecah massa $focusStr spesifik bersama Pro Guide.', 
        'focus', level, 10 + matchedExercises.length * 3, 100 + matchedExercises.length * 25, featuredImg, 
        matchedExercises
      ));
    }

    // Hindari mengembalikan list kosong (fallback total safety-net)
    if (list.isEmpty) {
        list.add(_createCustomModel('Kebugaran Basis $focusStr', 'Paket transisi aman bagi persendian.', 'focus', level, 15, 100, featuredImg, [WorkoutExercise(exerciseId: 'plank', exerciseName: 'Plank Fungsional', sets: 3, reps: 0, duration: 45, restTime: 30)]));
    }

    return list;
  }

  // ==========================================
  // ALGORITMA TUBUH BERBASIS GOALS (METODOLOGI)
  // ==========================================
  static List<WorkoutModel> getWorkoutsByGoal(String goalKey, String level, bool hasEquipment) {
    List<String> targetTags = [];
    int baseSets = 3;
    int baseReps = 12;
    int restTime = 30;
    
    if (goalKey == 'fat_loss') {
      targetTags = ['Perut', 'Seluruh Tubuh', 'Kaki'];
      baseSets = level == 'beginner' ? 3 : 4;
      baseReps = level == 'beginner' ? 15 : 20; // High reps for cardio
      restTime = 15; // 15 SECONDS! True HIIT
    } else if (goalKey == 'muscle_building') {
      targetTags = ['Lengan', 'Bahu', 'Bokong', 'Dada'];
      baseSets = level == 'beginner' ? 4 : 5; // Extra volume
      baseReps = level == 'beginner' ? 10 : 8; // Heavy weight, low reps
      restTime = 60; // 60 SECONDS! True hypertrophy rest
    } else {
      // General Fitness
      targetTags = ['Seluruh Tubuh', 'Perut', 'Lengan', 'Kaki'];
      baseSets = level == 'beginner' ? 3 : 4;
      baseReps = 12;
      restTime = 30; // standard rest
    }

    String strEquip = hasEquipment ? 'Alat' : 'Tanpa Alat';
    String strLevel = level == 'beginner' ? 'Pemula' : (level == 'intermediate' ? 'Menengah' : 'Mahir');
    
    List<WorkoutExercise> matchedExercises = [];
    exerciseDB.forEach((id, data) {
      List<String> tags = List<String>.from(data['tags']);
      bool matchesFocus = targetTags.any((t) => tags.contains(t));
      bool matchesEquip = tags.contains(strEquip);
      bool matchesLevel = tags.contains(strLevel);
      
      if (matchesFocus && matchesEquip && matchesLevel) {
        int finalDuration = 0;
        int finalReps = 0;

        if (!hasEquipment) {
            // TIME-BASED: Fat loss = fast, Muscle = max effort
            finalDuration = goalKey == 'fat_loss' ? 30 : (goalKey == 'muscle_building' ? 60 : 45);
            finalReps = 0;
        } else {
            // RANGE-REPS
            finalReps = baseReps;
            finalDuration = 0;
        }

        if (data['name'].toLowerCase().contains('plank') || data['name'].toLowerCase().contains('hold')) {
            finalDuration = 60;
            finalReps = 0;
        }

        matchedExercises.add(WorkoutExercise(
          exerciseId: id,
          exerciseName: data['name'],
          sets: baseSets,
          reps: finalReps,
          duration: finalDuration,
          restTime: restTime,
        ));
      }
    });

    matchedExercises.shuffle();
    // Potong agar tidak kelamaan (max 7 exercise untuk goal)
    if (matchedExercises.length > 7) {
      matchedExercises = matchedExercises.sublist(0, 7);
    }
    
    String title = goalKey == 'fat_loss' ? 'Sirkuit Lemak' : (goalKey == 'muscle_building' ? 'Hipertrofi Max' : 'Kebugaran Total');
    String desc = goalKey == 'fat_loss' ? 'Jeda istirahat sangat singkat. Bakar kalori secara brutal!' : (goalKey == 'muscle_building' ? 'Repetisi rendah, beban tinggi. Istirahat 60 detik.' : 'Proporsi seimbang seluruh tulang dan sendi.');

    int totalEstimatedSeconds = 0;
    for (var ex in matchedExercises) {
      int timePerSet = ex.duration > 0 ? ex.duration : (ex.reps * 3); // Asumsi 3 detik per repetisi
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
      list.add(_createCustomModel('Kebugaran Basis', 'Paket transisi aman bagi persendian.', goalKey, level, 15, 100, featuredImg, [WorkoutExercise(exerciseId: 'plank', exerciseName: 'Plank Fungsional', sets: 3, reps: 0, duration: 45, restTime: 30)]));
    }

    return list;
  }
}

