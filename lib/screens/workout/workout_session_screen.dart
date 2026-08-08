import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../models/workout_model.dart';
import '../../models/workout_history_model.dart';
import '../../services/firestore_service.dart';
import '../../services/audio_coaching_service.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel? workout;

  const WorkoutSessionScreen({super.key, this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with TickerProviderStateMixin {
  bool _started = false;
  bool _paused = false;
  bool _completed = false;
  bool _resting = false;
  bool _isTransitioning = false;

  int _currentExercise = 0;
  int _currentSet = 1;
  int _timeLeft = 30;
  int _restTime = 15;
  int _totalElapsed = 0;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late List<WorkoutExercise> _exercises;
  late String _workoutName;
  late String _workoutEmoji;

  // Audio Coaching Service - Requirements: 6.1
  late AudioCoachingService _audioCoaching;
  bool _audioEnabled = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeData();
    _initializeAudioCoaching();
  }

  /// Initialize AudioCoachingService - Requirements: 6.1
  Future<void> _initializeAudioCoaching() async {
    _audioCoaching = AudioCoachingService();
    await _audioCoaching.initialize();
    // Update audio enabled state based on initialization success
    setState(() {
      _audioEnabled = _audioCoaching.isEnabled;
    });
  }

  void _initializeData() {
    if (widget.workout != null) {
      _exercises = widget.workout!.exercises;
      _workoutName = widget.workout!.name;
      _workoutEmoji = _getEmojiForCategory(widget.workout!.category);
    } else {
      // Fallback/Default if no workout passed
      _exercises = [
        WorkoutExercise(
          exerciseId: 'pushup',
          exerciseName: 'Push Up',
          sets: 3,
          reps: 12,
          duration: 0,
          restTime: 15,
        ),
        WorkoutExercise(
          exerciseId: 'squat',
          exerciseName: 'Squat',
          sets: 3,
          reps: 15,
          duration: 0,
          restTime: 15,
        ),
      ];
      _workoutName = 'Full Body Workout';
      _workoutEmoji = '💪';
    }
  }

  String _getEmojiForCategory(String category) {
    switch (category) {
      case 'muscle_building':
        return '💪';
      case 'weight_loss':
        return '🔥';
      case 'general_fitness':
        return '❤️';
      default:
        return '🏋️';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioCoaching.dispose(); // Requirements: 6.3
    super.dispose();
  }

  void _startWorkout() {
    setState(() => _started = true);
    final ex = _exercises[_currentExercise];
    if (ex.duration > 0) {
      _timeLeft = ex.duration;
    }
    // Audio: Announce first exercise
    _audioCoaching.speakExerciseStart(ex.exerciseId, ex.exerciseName);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (!_paused) {
          _totalElapsed++;
          if (_resting) {
            _restTime--;

            // Enhanced Haptic: Graduated pattern (3=light, 2=medium, 1=heavy)
            if (_restTime == 3) {
              HapticFeedback.lightImpact();
              _audioCoaching.speakRestCountdown();
            } else if (_restTime == 2) {
              HapticFeedback.mediumImpact();
            } else if (_restTime == 1) {
              HapticFeedback.heavyImpact();
            } else if (_restTime == 0) {
              _playDoubleBurstHaptic();
            }

            if (_restTime <= 0) {
              _resting = false;
              _timer?.cancel();
              if (_isTransitioning) {
                _isTransitioning = false;
                _nextExercise();
              } else {
                _nextSet();
              }
            }
          } else if (_exercises[_currentExercise].duration > 0) {
            _timeLeft--;

            // Audio: Mid-cue at 50% of exercise duration
            final ex = _exercises[_currentExercise];
            if (ex.duration > 0 && _timeLeft == (ex.duration ~/ 2)) {
              _audioCoaching.speakExerciseMid(ex.exerciseId);
            }

            // Enhanced Haptic: Graduated pattern for work timer
            if (_timeLeft == 3) {
              HapticFeedback.lightImpact();
            } else if (_timeLeft == 2) {
              HapticFeedback.mediumImpact();
            } else if (_timeLeft == 1) {
              HapticFeedback.heavyImpact();
            } else if (_timeLeft == 0) {
              HapticFeedback.heavyImpact();
            }

            if (_timeLeft <= 0) {
              _timer?.cancel();
              _onSetComplete();
            }
          }
        }
      });
    });
  }

  void _onSetComplete() {
    final ex = _exercises[_currentExercise];
    if (_currentSet < ex.sets) {
      // Audio: Rest between sets
      _audioCoaching.speakRestStart();
      setState(() {
        _resting = true;
        _restTime = ex.restTime > 0 ? ex.restTime : 15;
      });
      _startTimer();
    } else {
      if (_currentExercise < _exercises.length - 1) {
        // Audio: Transition to next exercise
        final nextEx = _exercises[_currentExercise + 1];
        _audioCoaching.speakTransition(nextEx.exerciseName);
        setState(() {
          _resting = true;
          _isTransitioning = true;
          _restTime = 30; // Mandatory transition rest
        });
        _startTimer();
      } else {
        _nextExercise(); // This will trigger _completeWorkout
      }
    }
  }

  void _nextSet() {
    setState(() {
      _currentSet++;
      final ex = _exercises[_currentExercise];
      if (ex.duration > 0) {
        _timeLeft = ex.duration;
      }
    });
    // Audio: Announce new set
    final ex = _exercises[_currentExercise];
    _audioCoaching.speakExerciseStart(ex.exerciseId, ex.exerciseName);
    _startTimer();
  }

  void _nextExercise() {
    if (_currentExercise < _exercises.length - 1) {
      setState(() {
        _currentExercise++;
        _currentSet = 1;
        final ex = _exercises[_currentExercise];
        if (ex.duration > 0) {
          _timeLeft = ex.duration;
        }
        _resting = false;
      });
      // Audio: Announce new exercise
      final ex = _exercises[_currentExercise];
      _audioCoaching.speakExerciseStart(ex.exerciseId, ex.exerciseName);
      _startTimer();
    } else {
      _completeWorkout();
    }
  }

  Future<void> _completeWorkout() async {
    _timer?.cancel();
    setState(() => _completed = true);
    // Audio: Congratulations!
    _audioCoaching.speakExerciseStart('', 'Selamat! Latihan selesai. Kerja bagus hari ini!');

    final auth = context.read<AuthProvider>();
    final firestore = FirestoreService();

    if (auth.userModel != null) {
      final history = WorkoutHistoryModel(
        id: '',
        workoutId: widget.workout?.id ?? 'custom',
        workoutName: _workoutName,
        date: DateTime.now(),
        duration: _totalElapsed,
        caloriesBurned: (_totalElapsed / 60 * 8.5),
        exercisesCompleted: _exercises.length,
        totalExercises: _exercises.length,
        completedExercises: _exercises.map((e) => e.exerciseName).toList(),
      );

      await firestore.saveWorkoutHistory(auth.userModel!.uid, history);
      await auth.refreshUser();
    }
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
  }

  /// Toggle audio coaching ON/OFF - Requirements: 4.2, 4.5
  void _toggleAudioCoaching() {
    setState(() {
      _audioEnabled = !_audioEnabled;
    });
    _audioCoaching.toggleEnabled();
  }

  Future<void> _playDoubleBurstHaptic() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _buildCompletionView();
    if (!_started) return _buildPreSessionView();
    return _buildSessionView();
  }

  Widget _buildPreSessionView() {
    final auth = context.read<AuthProvider>();
    final user = auth.userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBeginner = user?.trainingLevel == 'beginner';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sesi Latihan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.xl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.workout?.thumbnailUrl != null &&
                            widget.workout!.thumbnailUrl.isNotEmpty
                        ? widget.workout!.thumbnailUrl
                        : 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(_workoutEmoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    _workoutName,
                    style: AppTextStyles.h3(color: Colors.white),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeaderChip(
                        isBeginner ? 'Pemula' : 'Berpengalaman',
                        Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderChip(
                        widget.workout?.category == 'fat_loss'
                            ? 'Fat Loss'
                            : 'Muscle',
                        Colors.white.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Text(
                    '${_exercises.length} gerakan • ~${widget.workout?.estimatedDuration ?? 20} min • ${widget.workout?.estimatedCalories ?? 250} kal',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isBeginner) ...[
              const SizedBox(height: AppDimensions.xl),
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tips: Fokus pada teknik gerakan yang benar daripada kecepatan.',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.xxl),
            Text(
              'Daftar Gerakan',
              style: AppTextStyles.h5(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Expanded(
              child: ListView.separated(
                itemCount: _exercises.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final ex = _exercises[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/exercises/detail',
                        arguments: ex.exerciseId,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkElevated
                              : AppColors.lightElevated,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.fitness_center_rounded,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.exerciseName,
                                  style: AppTextStyles.labelMedium(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  ex.reps > 0
                                      ? '${ex.sets} set × ${ex.reps > 2 ? ex.reps - 2 : ex.reps}-${ex.reps} Reps'
                                      : '${ex.sets} set × ${ex.duration} Detik',
                                  style: AppTextStyles.bodySmall(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonLg,
              child: ElevatedButton(
                onPressed: _startWorkout,
                child: const Text('Mulai Latihan 🚀'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSessionView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = _exercises[_currentExercise];
    final progress =
        (_currentExercise + _currentSet / ex.sets) / _exercises.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
              color: AppColors.primary,
              minHeight: 4,
            ),

            // Top controls
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                      IconButton(
                        onPressed: _toggleAudioCoaching,
                        icon: Icon(
                          _audioEnabled ? Icons.volume_up : Icons.volume_off,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Gerakan ${_currentExercise + 1}/${_exercises.length}',
                    style: AppTextStyles.labelMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${(_totalElapsed / 60 * (widget.workout?.category == 'fat_loss' ? 12 : 8.5)).toStringAsFixed(1)} kcal',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(_totalElapsed ~/ 60).toString().padLeft(2, '0')}:${(_totalElapsed % 60).toString().padLeft(2, '0')}',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_resting) ...[
                    Text(
                      'Istirahat',
                      style: AppTextStyles.bodyLarge(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Text(
                        '$_restTime',
                        style: AppTextStyles.h1(
                          color: AppColors.accent,
                        ).copyWith(fontSize: 72),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'detik',
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xxxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _restTime += 15),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('15 Detik'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black,
                            elevation: 0,
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _restTime = 0);
                          },
                          icon: const Icon(
                            Icons.fast_forward_rounded,
                            size: 18,
                          ),
                          label: const Text('Lewati ⏩'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text('🏋️', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: AppDimensions.xxl),
                    Text(
                      ex.exerciseName,
                      style: AppTextStyles.h2(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Set $_currentSet / ${ex.sets}',
                      style: AppTextStyles.bodyLarge(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xxxl),

                    if (ex.duration > 0)
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$_timeLeft',
                              style: AppTextStyles.h1(
                                color: AppColors.primary,
                              ).copyWith(fontSize: 48),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        '${ex.reps > 2 ? ex.reps - 2 : ex.reps}-${ex.reps} Reps',
                        style: AppTextStyles.h1(
                          color: AppColors.primary,
                        ).copyWith(fontSize: 48),
                      ),
                  ],
                ],
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    'Pause',
                    _togglePause,
                    isDark,
                  ),
                  if (!_resting)
                    SizedBox(
                      height: 64,
                      width: 180,
                      child: ElevatedButton(
                        onPressed: _onSetComplete,
                        child: const Text('Selesai Set ✓'),
                      ),
                    ),
                  _buildControlButton(
                    Icons.skip_next_rounded,
                    'Skip',
                    _nextExercise,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutes = _totalElapsed ~/ 60;
    final calories = (minutes * 8.5).toInt();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: AppDimensions.xxl),
              Text(
                'Latihan Selesai!',
                style: AppTextStyles.h2(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Kerja bagus! Tetap konsisten 💪',
                style: AppTextStyles.bodyLarge(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              Container(
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompletionStat('⏱', '${minutes}m', 'Durasi', isDark),
                    _buildCompletionStat('🔥', '$calories', 'Kalori', isDark),
                    _buildCompletionStat(
                      '💪',
                      '${_exercises.length}',
                      'Gerakan',
                      isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              Text(
                'Bagaimana sesimu?',
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < 4
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.warning,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStat(
    String emoji,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.h4(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
