import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Text(
                'Progress Latihanmu 📊',
                style: AppTextStyles.h3(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyles.labelSmall(),
                tabs: const [
                  Tab(text: 'Mingguan'),
                  Tab(text: 'Bulanan'),
                  Tab(text: 'Semua'),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xxl),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            '12',
                            'Latihan Selesai',
                            Icons.fitness_center_rounded,
                            AppColors.primary,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: _buildProgressCard(
                            '2,450',
                            'Kalori Terbakar',
                            Icons.local_fire_department_rounded,
                            AppColors.secondary,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            '5.2 jam',
                            'Total Durasi',
                            Icons.timer_outlined,
                            AppColors.accent,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: _buildProgressCard(
                            '26 min',
                            'Rata-rata/Sesi',
                            Icons.speed_outlined,
                            AppColors.warning,
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.xxxl),

                    // Weight Chart Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Berat Badan',
                          style: AppTextStyles.h5(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildWeightChart(isDark),

                    const SizedBox(height: AppDimensions.xxxl),

                    // Streak Calendar
                    Text(
                      'Kalender Latihan',
                      style: AppTextStyles.h5(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildStreakCalendar(isDark),

                    const SizedBox(height: AppDimensions.xxxl),

                    // Achievements
                    Text(
                      'Pencapaian',
                      style: AppTextStyles.h5(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildAchievements(isDark),

                    const SizedBox(height: AppDimensions.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppDimensions.md),
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
            style: AppTextStyles.bodySmall(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(bool isDark) {
    final weights = [67.0, 66.5, 66.0, 65.5, 65.8, 65.2, 65.0];
    final maxW = 68.0;
    final minW = 64.0;
    final range = maxW - minW;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 140),
        painter: _WeightChartPainter(
          weights: weights,
          minWeight: minW,
          maxWeight: maxW,
          lineColor: AppColors.accent,
          dotColor: AppColors.accent,
          gridColor: isDark ? AppColors.darkElevated : AppColors.lightElevated,
        ),
      ),
    );
  }

  Widget _buildStreakCalendar(bool isDark) {
    // Demo: show 28 days (4 weeks)
    final workoutDays = {1, 3, 5, 8, 10, 12, 15, 17, 19, 22, 24, 26};

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: 28,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isWorkout = workoutDays.contains(day);
          return Container(
            decoration: BoxDecoration(
              color: isWorkout
                  ? AppColors.accent.withValues(alpha: 0.8)
                  : (isDark
                        ? AppColors.darkElevated.withValues(alpha: 0.4)
                        : AppColors.lightElevated),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$day',
                style: AppTextStyles.caption(
                  color: isWorkout
                      ? Colors.white
                      : (isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievements(bool isDark) {
    final achievements = [
      ('🥇', 'Latihan Pertama', true),
      ('🔥', 'Streak 7 Hari', true),
      ('💪', '10 Latihan', true),
      ('🏆', '30 Hari', false),
      ('⚡', '50 Latihan', false),
      ('🎯', '100 Latihan', false),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
        itemBuilder: (context, index) {
          final (emoji, title, unlocked) = achievements[index];
          return Container(
            width: 80,
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: unlocked
                  ? Border.all(color: AppColors.warning.withValues(alpha: 0.5))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: unlocked ? null : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.caption(
                    color: unlocked
                        ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                        : (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> weights;
  final double minWeight;
  final double maxWeight;
  final Color lineColor;
  final Color dotColor;
  final Color gridColor;

  _WeightChartPainter({
    required this.weights,
    required this.minWeight,
    required this.maxWeight,
    required this.lineColor,
    required this.dotColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final range = maxWeight - minWeight;
    final stepX = size.width / (weights.length - 1);

    // Grid lines
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line path
    final path = Path();
    for (var i = 0; i < weights.length; i++) {
      final x = i * stepX;
      final y = size.height - ((weights[i] - minWeight) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Dots
    for (var i = 0; i < weights.length; i++) {
      final x = i * stepX;
      final y = size.height - ((weights[i] - minWeight) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()
          ..color = dotColor.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
