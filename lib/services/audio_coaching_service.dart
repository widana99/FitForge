import 'package:flutter_tts/flutter_tts.dart';

/// Data class for storing coaching cues for an exercise
class CoachingCues {
  final String start;
  final String mid;

  const CoachingCues({required this.start, required this.mid});
}

class AudioCoachingService {
  static final AudioCoachingService _instance = AudioCoachingService._();
  factory AudioCoachingService() => _instance;
  AudioCoachingService._();

  final FlutterTts _tts = FlutterTts();
  bool _isEnabled = true;
  bool _isInitialized = false;

  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      print('TTS initialization failed: $e');
      _isInitialized = false;
      _isEnabled = false;
    }
  }

  void toggleEnabled() {
    _isEnabled = !_isEnabled;
    if (!_isEnabled) {
      stop(); // Fire-and-forget for immediate UI responsiveness
    }
  }

  // Private method to speak text with proper checks and error handling
  Future<void> _speak(String text) async {
    // Check if audio is enabled and initialized
    if (!_isEnabled || !_isInitialized) return;

    try {
      // Stop any ongoing speech to prevent overlap
      await _tts.stop();
      // Speak the new text
      await _tts.speak(text);
    } catch (e) {
      print('Speech failed: $e');
      // Continue silently without crashing
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  void dispose() {
    try {
      _tts.stop().catchError((e) {
        print('Error during disposal: $e');
      });
    } catch (e) {
      print('Error during disposal: $e');
    }
    _isInitialized = false;
  }

  // =============================================
  // GET COACHING CUES (with fallback)
  // =============================================
  CoachingCues _getCoachingCues(String exerciseId) {
    return _exerciseCues[exerciseId] ?? _genericCues;
  }

  // =============================================
  // PUBLIC COACHING METHODS
  // =============================================

  /// Speak exercise start cue with exercise name
  /// Requirements: 2.2
  Future<void> speakExerciseStart(
    String exerciseId,
    String exerciseName,
  ) async {
    final cues = _getCoachingCues(exerciseId);
    await _speak('$exerciseName. ${cues.start}');
  }

  /// Speak mid-point coaching cue
  /// Requirements: 2.3
  Future<void> speakExerciseMid(String exerciseId) async {
    final cues = _getCoachingCues(exerciseId);
    await _speak(cues.mid);
  }

  /// Speak rest start cue
  /// Requirements: 2.4
  Future<void> speakRestStart() async {
    await _speak('Istirahat. Tarik napas dalam.');
  }

  /// Speak rest countdown cue
  /// Requirements: 2.5
  Future<void> speakRestCountdown() async {
    await _speak('Bersiap! Tiga... dua... satu...');
  }

  /// Speak transition to next exercise
  /// Requirements: 2.6
  Future<void> speakTransition(String nextExerciseName) async {
    await _speak('Gerakan berikutnya: $nextExerciseName');
  }

  // =============================================
  // GENERIC/FALLBACK COACHING CUES
  // =============================================
  static const CoachingCues _genericCues = CoachingCues(
    start: 'Fokus pada teknik yang benar.',
    mid: 'Bagus! Pertahankan tempo.',
  );

  // =============================================
  // DATABASE: Exercise Coaching Cues (45+ exercises)
  // =============================================
  static final Map<String, CoachingCues> _exerciseCues = {
    // === UPPER BODY (15) ===
    'knee_pushup': CoachingCues(
      start:
          'Knee Push-up. Posisi merangkak, kunci pinggul lurus, tekuk siku 45 derajat.',
      mid: 'Jaga punggung tetap lurus. Jangan biarkan pinggul turun.',
    ),
    'wall_pushup': CoachingCues(
      start:
          'Wall Push-ups. Berdiri sejauh rentangan lengan dari dinding, dorong dan tolak.',
      mid: 'Kontrol gerakan. Jangan terburu-buru mendorong.',
    ),
    'arm_circles': CoachingCues(
      start:
          'Arm Circles. Rentangkan lengan, lukis lingkaran kecil yang perlahan membesar.',
      mid: 'Perlebar lingkaran. Rasakan peregangan di bahu.',
    ),
    'plank_taps': CoachingCues(
      start:
          'Plank Shoulder Taps. Posisi plank, tap bahu bergantian tanpa goyangkan pinggul.',
      mid: 'Panggul tetap diam. Stabilkan inti tubuh.',
    ),
    'inchworm_push': CoachingCues(
      start:
          'Inchworm. Merunduk, jalan tangan ke depan hingga plank, lalu mundur.',
      mid: 'Rentangkan langkah tangan sejauh mungkin.',
    ),
    'pushup': CoachingCues(
      start:
          'Push-up. Tangan selebar bahu, turun lambat 3 detik, dorong naik cepat.',
      mid: 'Bagus! Turunkan dada perlahan. Siku tetap 45 derajat.',
    ),
    'decline_pushup': CoachingCues(
      start:
          'Decline Push-up. Kaki di atas kursi, kontraksi perut, dorong sedalam mungkin.',
      mid: 'Perut tetap kencang. Jangan biarkan punggung melengkung.',
    ),
    'bench_dips': CoachingCues(
      start:
          'Bench Dips. Genggam tepi kursi, turun tekuk siku 90 derajat ke belakang.',
      mid: 'Jaga punggung dekat kursi. Siku lurus ke belakang.',
    ),
    'sphinx_pushup': CoachingCues(
      start:
          'Sphinx Push-up. Dari posisi forearm plank, dorong ke telapak tangan, lalu turun.',
      mid: 'Kontrol transisi dari siku ke telapak tangan.',
    ),
    'pike_pushup': CoachingCues(
      start:
          'Pike Push-up. Bentuk tubuh V terbalik, turunkan kepala di depan telapak tangan.',
      mid: 'Kepala turun di antara lengan. Tekan bahu ke atas.',
    ),
    'hindu_pushup': CoachingCues(
      start:
          'Dive Bomber. Dari posisi pike, menukik seperti pesawat merayap dekat lantai.',
      mid: 'Alur gerakan seperti ombak. Tetap mengalir.',
    ),
    'pseudo_planche': CoachingCues(
      start:
          'Pseudo Planche Push-up. Tarik tangan ke arah rusuk bawah, dorong badan ke depan.',
      mid: 'Dorong berat badan ke depan melewati tangan.',
    ),
    'clapping_pushup': CoachingCues(
      start:
          'Clapping Push-up. Tolakan meledak dari lantai, tepuk tangan, redam mendarat.',
      mid: 'Ledakkan! Redam mendarat dengan siku tertekuk.',
    ),
    'typewriter_pushup': CoachingCues(
      start:
          'Typewriter Push-up. Lebar tangan ekstra, turun ke satu sisi lalu menyapu ke sisi lain.',
      mid: 'Sapu badan perlahan dari sisi ke sisi.',
    ),
    'handstand_hold': CoachingCues(
      start:
          'Wall Handstand. Kunci siku lurus, perut kencang, tahan posisi handstand di dinding.',
      mid: 'Kunci siku. Perut super kencang. Tahan posisi.',
    ),

    // === LOWER BODY - KAKI (13) ===
    'bw_squat': CoachingCues(
      start:
          'Squat. Berdiri renggang bahu, punggung lurus, jongkok hingga paha sejajar lantai.',
      mid: 'Dorong lutut ke arah luar. Pertahankan keseimbangan.',
    ),
    'lunges': CoachingCues(
      start:
          'Forward Lunges. Langkah jauh ke depan, turunkan panggul, lutut belakang hampir sentuh lantai.',
      mid: 'Punggung tegak. Lutut depan jangan melewati jari kaki.',
    ),
    'side_lunge': CoachingCues(
      start:
          'Side Lunges. Langkah menyamping lebar, tekuk satu lutut, lalu kembali.',
      mid: 'Kaki lurus tetap menempel lantai. Dorong pinggul ke belakang.',
    ),
    'calf_raise': CoachingCues(
      start:
          'Calf Raises. Berdiri tegak, berjinjit angkat tumit setinggi mungkin, turun perlahan.',
      mid: 'Peras betis di puncak. Turun perlahan, jangan jatuh.',
    ),
    'wall_sit': CoachingCues(
      start:
          'Wall Sit. Sandar dinding, tekuk lutut 90 derajat, tahan posisi duduk.',
      mid: 'Tahan! Napas tetap teratur. Paha harus sejajar lantai.',
    ),
    'jump_squat': CoachingCues(
      start:
          'Jump Squat. Jongkok penuh, lalu lompat meledak ke atas, mendarat meredam.',
      mid: 'Mendarat lembut! Lutut meredam benturan.',
    ),
    'sissy_squat': CoachingCues(
      start:
          'Sissy Squat. Condongkan badan ke belakang, turun lutut ke depan, fokus paha.',
      mid: 'Kontrol badan ke belakang. Rasakan paha terbakar.',
    ),
    'cossack_squat': CoachingCues(
      start:
          'Deep Cossack Squat. Jongkok menyamping sedalam mungkin, satu kaki lurus.',
      mid: 'Turun sedalam mungkin. Buka pinggul selebar mungkin.',
    ),
    'step_ups': CoachingCues(
      start:
          'Step Ups. Naik kursi dengan satu kaki, dorong ke atas, turun terkendali.',
      mid: 'Dorong dari tumit kaki atas. Jangan mengayun.',
    ),
    'pistol_squat': CoachingCues(
      start:
          'Pistol Squat. Satu kaki di depan, jongkok penuh dengan satu kaki tumpu.',
      mid: 'Jaga keseimbangan. Kaki depan lurus terentang.',
    ),
    'shrimp_squat': CoachingCues(
      start:
          'Shrimp Squat. Pegang tumit belakang, jongkok satu kaki turun perlahan.',
      mid: 'Turun terkendali. Jangan jatuh terlalu cepat.',
    ),
    'jump_lunges': CoachingCues(
      start:
          'Jump Lunges. Lompat dan tukar kaki di udara, mendarat tanpa suara.',
      mid: 'Tukar kaki di puncak lompatan. Mendarat senyap.',
    ),
    'ghr_floor': CoachingCues(
      start:
          'Nordic Ham Raise. Kunci kaki, turun perlahan ke depan dengan kontrol hamstring.',
      mid: 'Turun selambat mungkin. Kontrol dengan hamstring.',
    ),

    // === LOWER BODY - SELURUH TUBUH (12) ===
    'jumping_jack': CoachingCues(
      start:
          'Jumping Jacks. Lompat buka kaki dan tangan bersamaan, tutup kembali ritmik.',
      mid: 'Jaga ritme konstan. Napas teratur.',
    ),
    'mtn_climber': CoachingCues(
      start:
          'Mountain Climbers. Posisi plank, tarik lutut bergantian ke dada dengan cepat.',
      mid: 'Percepat! Lutut ke dada sedekat mungkin.',
    ),
    'inchworm': CoachingCues(
      start:
          'Inchworms. Merunduk sentuh lantai, jalan tangan maju ke plank, lalu mundur.',
      mid: 'Jangan tekuk lutut saat merunduk. Rasakan hamstring.',
    ),
    'high_knees': CoachingCues(
      start:
          'High Knees. Berdiri tegak, angkat lutut tinggi bergantian secara ritmik.',
      mid: 'Lutut harus setinggi pinggul. Terus bergerak!',
    ),
    'squat_jab': CoachingCues(
      start:
          'Squat to Jab. Jongkok, lalu berdiri sambil melempar pukulan silang.',
      mid: 'Pukulan kencang dari pinggul. Jangan hanya lengan.',
    ),
    'burpee': CoachingCues(
      start:
          'Burpees. Turun ke plank, push-up, lompat kaki ke depan, lalu lompat ke atas!',
      mid: 'Terus bergerak! Jangan berhenti di tengah!',
    ),
    'bear_crawl': CoachingCues(
      start:
          'Bear Crawl. Merangkak maju lutut sejari dari lantai, tetap stabil.',
      mid: 'Lutut sejari dari lantai. Punggung rata.',
    ),
    'plank_to_squat': CoachingCues(
      start:
          'Plank to Squat. Dari plank, lompat kaki ke depan masuk posisi jongkok.',
      mid: 'Lompat kaki ke luar tangan. Dada tegak.',
    ),
    'heisman': CoachingCues(
      start:
          'Heisman Shuffles. Lompat samping ke samping, angkat lutut tinggi di setiap sisi.',
      mid: 'Angkat lutut tinggi di setiap sisi. Tetap lincah!',
    ),
    'navy_burpee': CoachingCues(
      start:
          'Navy Seal Burpees. Burpee ditambah push-up penuh, fokus dan ledakkan!',
      mid: 'Ini yang berat! Push-up penuh, lalu lompat maksimal!',
    ),
    'sprawl_jumps': CoachingCues(
      start:
          'Sprawl Jumps. Banting badan ke lantai, pantul terbang, lompat tinggi.',
      mid: 'Cepat turun, cepat naik! Jangan buang waktu!',
    ),
    'mule_kicks': CoachingCues(
      start:
          'Mule Kicks. Dari plank, tendang kedua kaki ke belakang atas bersamaan.',
      mid: 'Tendangan harus bertenaga. Kembali stabil ke plank.',
    ),

    // === CORE - PERUT (12) ===
    'plank': CoachingCues(
      start:
          'Forearm Plank. Kunci perut, kunci panggul, jaga tubuh lurus seperti papan.',
      mid: 'Tahan posisi. Jangan biarkan pinggul naik atau turun.',
    ),
    'knee_taps': CoachingCues(
      start:
          'Knee-to-Elbow Crunches. Telentang, tarik siku silang ke lutut bergantian.',
      mid: 'Rotasi dari perut, bukan dari leher.',
    ),
    'heel_taps': CoachingCues(
      start:
          'Heel Taps. Telentang lutut tekuk, ayunkan tangan menyentuh tumit bergantian.',
      mid: 'Pundak tetap terangkat. Remas sisi perut.',
    ),
    'dead_bug': CoachingCues(
      start:
          'Dead Bug. Telentang angkat kaki dan tangan, turunkan berlawanan bergantian.',
      mid: 'Punggung bawah tetap menempel lantai. Kontrol gerakan.',
    ),
    'russian_twist': CoachingCues(
      start:
          'Russian Twist. Duduk engsel miring V, putar badan kiri-kanan bergantian.',
      mid: 'Putar dari tulang rusuk, bukan hanya tangan.',
    ),
    'v_tuck': CoachingCues(
      start:
          'V-Tuck Crunches. Telentang, lipat tubuh membawa lutut dan dada bersamaan.',
      mid: 'Tarik napas saat turun, buang saat lipat.',
    ),
    'bird_dog': CoachingCues(
      start:
          'Bird-Dog. Merangkak, lempar tangan dan kaki berlawanan lurus sejajar.',
      mid: 'Diam dan stabil. Jangan goyangkan panggul.',
    ),
    'reverse_crunch': CoachingCues(
      start:
          'Reverse Crunch. Telentang, gulung panggul mengangkat pinggul ke atas.',
      mid: 'Gulung panggul, bukan hanya mengangkat kaki.',
    ),
    'dragon_flag': CoachingCues(
      start:
          'Dragon Flag. Pegang tuas atas kepala, angkat seluruh tubuh lurus ke atas.',
      mid: 'Kunci seluruh tubuh lurus. Ini gerakan elit!',
    ),
    'plank_jacks': CoachingCues(
      start:
          'Plank Jacks. Posisi plank, lompat buka tutup kaki seperti jumping jack.',
      mid: 'Perut tetap kencang saat kaki melompat.',
    ),
    'window_wipers': CoachingCues(
      start:
          'Floor Wipers. Telentang kaki lurus ke atas, jatuhkan ke samping bergantian.',
      mid: 'Kontrol penurunan ke samping. Jangan terburu-buru.',
    ),
    'hanging_leg': CoachingCues(
      start:
          'Floor L-Sit. Duduk tangan di lantai, angkat seluruh tubuh membentuk huruf L.',
      mid: 'Tekan tangan kuat ke lantai. Angkat panggul.',
    ),

    // === GLUTES - BOKONG (12) ===
    'glute_bridge': CoachingCues(
      start:
          'Glute Bridge. Telentang lutut tekuk, angkat panggul ke atas, kunci di puncak.',
      mid: 'Peras bokong kencang di puncak. Tahan sedetik.',
    ),
    'donkey_kicks': CoachingCues(
      start:
          'Donkey Kicks. Merangkak, tendang satu kaki ke atas belakang, kencangkan bokong.',
      mid: 'Tendang ke atas, bukan ke belakang. Kunci di puncak.',
    ),
    'clam_shells': CoachingCues(
      start:
          'Clamshells. Rebah menyamping, buka lutut atas seperti cangkang kerang.',
      mid: 'Buka lutut perlahan. Tumit tetap menempel.',
    ),
    'hip_circles': CoachingCues(
      start: 'Hip Circles. Merangkak, angkat lutut dan putar lingkaran besar.',
      mid: 'Lingkaran besar dan terkontrol. Jangan terburu-buru.',
    ),
    'frog_pumps': CoachingCues(
      start:
          'Frog Pumps. Telentang telapak kaki saling menempel, pompa panggul ke atas.',
      mid: 'Telapak kaki menempel. Pompa panggul kencang.',
    ),
    'rainbow_lifts': CoachingCues(
      start:
          'Rainbow Leg Lifts. Merangkak, angkat kaki lurus membuat busur pelangi.',
      mid: 'Kaki lurus saat membuat busur. Kontrol gerakan.',
    ),
    'side_plank_clam': CoachingCues(
      start: 'Side Plank Clamshell. Plank menyamping, buka tutup lutut atas.',
      mid: 'Panggul tetap terangkat. Buka lutut penuh.',
    ),
    'single_leg_bridge': CoachingCues(
      start:
          'Single Leg Bridge. Telentang, angkat panggul dengan satu kaki saja.',
      mid: 'Satu kaki menopang. Kencangkan bokong di puncak.',
    ),
    'elevated_bridge': CoachingCues(
      start:
          'Elevated Bridge. Kaki di atas kursi, angkat panggul dengan satu kaki.',
      mid: 'Tumit tekan di kursi. Angkat panggul tinggi.',
    ),
    'reverse_hyper': CoachingCues(
      start:
          'Reverse Hyperextension. Perut di tepi ranjang, angkat kedua kaki lurus ke atas.',
      mid: 'Angkat kaki dari bokong, bukan dari punggung.',
    ),
    'plyo_glute_bridge': CoachingCues(
      start:
          'Plyo Bridge Jumps. Glute bridge eksplosif, dorong panggul meledak ke atas.',
      mid: 'Dorong meledak ke atas! Mendarat meredam.',
    ),
    'fire_hydrant_pulse': CoachingCues(
      start:
          'Fire Hydrant Pulses. Merangkak, angkat lutut ke samping, pulsa kecil di atas.',
      mid: 'Tahan di atas. Pulsa kecil, bokong terbakar!',
    ),
  };
}
