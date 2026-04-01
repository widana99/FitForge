import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  String _filter = 'Semua';

  final List<_HistoryItem> _history = [
    _HistoryItem('Full Body Workout', DateTime.now().subtract(const Duration(hours: 3)),
        32, 245, 5, 5, '💪'),
    _HistoryItem('Upper Body', DateTime.now().subtract(const Duration(days: 1)),
        45, 380, 4, 6, '🏋️'),
    _HistoryItem('Core Training', DateTime.now().subtract(const Duration(days: 2)),
        20, 180, 4, 4, '🧘'),
    _HistoryItem('Leg Day', DateTime.now().subtract(const Duration(days: 3)),
        50, 420, 5, 7, '🦵'),
    _HistoryItem('HIIT Cardio', DateTime.now().subtract(const Duration(days: 5)),
        25, 310, 5, 5, '🔥'),
    _HistoryItem('Full Body Workout', DateTime.now().subtract(const Duration(days: 7)),
        35, 280, 4, 5, '💪'),
    _HistoryItem('Stretch & Recovery', DateTime.now().subtract(const Duration(days: 8)),
        15, 80, 3, 4, '🧘'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Latihan'),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.xl, vertical: AppDimensions.sm),
            child: Row(
              children: ['Semua', 'Minggu Ini', 'Bulan Ini'].map((f) {
                final isActive = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.sm),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isActive,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: AppTextStyles.labelSmall(
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    side: BorderSide(
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkElevated
                              : AppColors.lightElevated),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummary('7', 'Sesi'),
                  Container(width: 1, height: 30,
                      color: Colors.white.withValues(alpha: 0.3)),
                  _buildSummary('222m', 'Durasi'),
                  Container(width: 1, height: 30,
                      color: Colors.white.withValues(alpha: 0.3)),
                  _buildSummary('1,895', 'Kalori'),
                ],
              ),
            ),
          ),

          // History list
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏋️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppDimensions.lg),
                        Text('Belum ada riwayat latihan',
                            style: AppTextStyles.bodyLarge(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xl),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.md),
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(_history[index], isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.h5(color: Colors.white)),
        Text(label,
            style: AppTextStyles.caption(
                color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildHistoryCard(_HistoryItem item, bool isDark) {
    final daysDiff = DateTime.now().difference(item.date).inDays;
    String dateText;
    if (daysDiff == 0) {
      dateText = 'Hari ini';
    } else if (daysDiff == 1) {
      dateText = 'Kemarin';
    } else {
      dateText = '$daysDiff hari lalu';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTextStyles.labelMedium(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)),
                const SizedBox(height: 4),
                Text('${item.duration}min • ${item.calories}kal • ${item.exercises} gerakan',
                    style: AppTextStyles.bodySmall(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(dateText,
                        style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight)),
                    const SizedBox(width: AppDimensions.sm),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < item.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
        ],
      ),
    );
  }
}

class _HistoryItem {
  final String name;
  final DateTime date;
  final int duration;
  final int calories;
  final int rating;
  final int exercises;
  final String emoji;

  _HistoryItem(this.name, this.date, this.duration, this.calories,
      this.rating, this.exercises, this.emoji);
}
