import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Demo data
  final String _userName = 'Pengguna';
  final int _streak = 5;
  final int _totalMinutes = 120;
  final int _totalWorkouts = 12;
  final double _todayCalories = 245;
  final int _todayDuration = 32;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $_userName! 👋',
                        style: AppTextStyles.h3(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ayo mulai latihanmu hari ini',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.settings),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.xxl),

              // Today's Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latihan Hari Ini',
                          style: AppTextStyles.labelLarge(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            '🔥 Hari Latihan',
                            style: AppTextStyles.labelSmall(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    Row(
                      children: [
                        _buildSummaryItem(
                          '${_todayCalories.toInt()}',
                          'Kalori',
                          Icons.local_fire_department_rounded,
                        ),
                        const SizedBox(width: AppDimensions.xxl),
                        _buildSummaryItem(
                          '${_todayDuration}m',
                          'Durasi',
                          Icons.timer_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.workoutSession,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                        ),
                        child: const Text('Mulai Latihan'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '🔥',
                      '$_streak',
                      'Hari Streak',
                      AppColors.secondary.withValues(alpha: 0.12),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _buildStatCard(
                      '⏱',
                      '${_totalMinutes}m',
                      'Minggu Ini',
                      AppColors.accent.withValues(alpha: 0.12),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _buildStatCard(
                      '💪',
                      '$_totalWorkouts',
                      'Total',
                      AppColors.primary.withValues(alpha: 0.12),
                      isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.xxxl),

              // Weekly Progress
              _buildSectionHeader('Progress Mingguan', 'Lihat Semua', () {
                Navigator.pushNamed(context, AppRoutes.progress);
              }, isDark),
              const SizedBox(height: AppDimensions.lg),
              _buildWeeklyChart(isDark),

              const SizedBox(height: AppDimensions.xxxl),

              // Popular Exercises
              _buildSectionHeader('Gerakan Populer', 'Lihat Semua', () {
                Navigator.pushNamed(context, AppRoutes.exerciseList);
              }, isDark),
              const SizedBox(height: AppDimensions.lg),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppDimensions.md),
                  itemBuilder: (context, index) {
                    return _buildExerciseCard(index, isDark);
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              // Recent History
              _buildSectionHeader('Riwayat Latihan', 'Lihat Semua', () {
                Navigator.pushNamed(context, AppRoutes.workoutHistory);
              }, isDark),
              const SizedBox(height: AppDimensions.lg),
              ...List.generate(3, (i) => _buildHistoryItem(i, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
            const SizedBox(width: 6),
            Text(value, style: AppTextStyles.h3(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String emoji,
    String value,
    String label,
    Color bgColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildSectionHeader(
    String title,
    String action,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.h5(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: AppTextStyles.bodySmall(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final values = [0.7, 0.4, 0.9, 0.0, 0.6, 0.8, 0.0];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final isToday = index == DateTime.now().weekday - 1;
          return Column(
            children: [
              Container(
                width: 32,
                height: 100 * values[index] + 8,
                decoration: BoxDecoration(
                  color: values[index] > 0
                      ? (isToday
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3))
                      : (isDark
                            ? AppColors.darkElevated
                            : AppColors.lightElevated),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: AppTextStyles.caption(
                  color: isToday
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildExerciseCard(int index, bool isDark) {
    final exercises = [
      ('Push Up', 'Dada', '🏋️'),
      ('Squat', 'Kaki', '🦵'),
      ('Plank', 'Core', '💪'),
      ('Burpee', 'Kardio', '🔥'),
      ('Lunges', 'Kaki', '🏃'),
    ];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetail),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(
                  exercises[index].$3,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              exercises[index].$1,
              style: AppTextStyles.labelMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exercises[index].$2,
              style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(int index, bool isDark) {
    final items = [
      ('Upper Body Workout', '32 min', '245 kal', '⭐ 4.5'),
      ('Leg Day', '45 min', '380 kal', '⭐ 5.0'),
      ('Core Training', '20 min', '180 kal', '⭐ 4.0'),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[index].$1,
                  style: AppTextStyles.labelMedium(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${items[index].$2} • ${items[index].$3}',
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
            items[index].$4,
            style: AppTextStyles.bodySmall(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
