import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with TickerProviderStateMixin {
  bool _started = false;
  bool _paused = false;
  bool _completed = false;
  bool _resting = false;

  int _currentExercise = 0;
  int _currentSet = 1;
  int _timeLeft = 30;
  int _restTime = 15;
  int _totalElapsed = 0;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<_ExerciseData> _exercises = [
    _ExerciseData('Push Up', 'Dada', 3, 12, 0, '💪'),
    _ExerciseData('Squat', 'Kaki', 3, 15, 0, '🦵'),
    _ExerciseData('Plank', 'Core', 3, 0, 30, '🧘'),
    _ExerciseData('Burpee', 'Kardio', 3, 10, 0, '🔥'),
    _ExerciseData('Mountain Climber', 'Kardio', 3, 0, 30, '🏔️'),
  ];

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startWorkout() {
    setState(() => _started = true);
    final ex = _exercises[_currentExercise];
    if (ex.duration > 0) {
      _timeLeft = ex.duration;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _totalElapsed++;
        if (_resting) {
          _restTime--;
          if (_restTime <= 0) {
            _resting = false;
            _timer?.cancel();
            _nextSet();
          }
        } else if (_exercises[_currentExercise].duration > 0) {
          _timeLeft--;
          if (_timeLeft <= 0) {
            _timer?.cancel();
            _onSetComplete();
          }
        }
      });
    });
  }

  void _onSetComplete() {
    final ex = _exercises[_currentExercise];
    if (_currentSet < ex.sets) {
      setState(() {
        _resting = true;
        _restTime = 15;
      });
      _startTimer();
    } else {
      _nextExercise();
    }
  }

  void _nextSet() {
    setState(() {
      _currentSet++;
      final ex = _exercises[_currentExercise];
      if (ex.duration > 0) {
        _timeLeft = ex.duration;
        _startTimer();
      }
    });
  }

  void _nextExercise() {
    if (_currentExercise < _exercises.length - 1) {
      setState(() {
        _currentExercise++;
        _currentSet = 1;
        final ex = _exercises[_currentExercise];
        if (ex.duration > 0) {
          _timeLeft = ex.duration;
          _startTimer();
        }
      });
    } else {
      setState(() => _completed = true);
      _timer?.cancel();
    }
  }

  void _togglePause() {
    if (_paused) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    setState(() => _paused = !_paused);
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _buildCompletionView();
    if (!_started) return _buildPreSessionView();
    return _buildSessionView();
  }

  Widget _buildPreSessionView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              child: Column(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Full Body Workout',
                    style: AppTextStyles.h3(color: Colors.white),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    '${_exercises.length} gerakan • ~20 min • 250 kal',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
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
                  return Container(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
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
                          child: Center(
                            child: Text(
                              ex.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: AppTextStyles.labelMedium(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                ex.reps > 0
                                    ? '${ex.sets} set × ${ex.reps} rep'
                                    : '${ex.sets} set × ${ex.duration}s',
                                style: AppTextStyles.bodySmall(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          ex.muscle,
                          style: AppTextStyles.caption(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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
                  IconButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Text(
                    'Gerakan ${_currentExercise + 1}/${_exercises.length}',
                    style: AppTextStyles.labelMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    '${(_totalElapsed ~/ 60).toString().padLeft(2, '0')}:${(_totalElapsed % 60).toString().padLeft(2, '0')}',
                    style: AppTextStyles.labelMedium(color: AppColors.primary),
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
                  ] else ...[
                    // Exercise emoji
                    Text(ex.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: AppDimensions.xxl),
                    Text(
                      ex.name,
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
                        '${ex.reps} rep',
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
                  // Pause
                  _buildControlButton(
                    _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    'Pause',
                    _togglePause,
                    isDark,
                  ),
                  // Done / Next
                  if (!_resting && ex.reps > 0)
                    SizedBox(
                      height: 64,
                      width: 180,
                      child: ElevatedButton(
                        onPressed: _onSetComplete,
                        child: const Text('Selesai Set ✓'),
                      ),
                    ),
                  // Skip
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

              // Stats row
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

              // Rating
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

class _ExerciseData {
  final String name;
  final String muscle;
  final int sets;
  final int reps;
  final int duration;
  final String emoji;

  _ExerciseData(
    this.name,
    this.muscle,
    this.sets,
    this.reps,
    this.duration,
    this.emoji,
  );
}
