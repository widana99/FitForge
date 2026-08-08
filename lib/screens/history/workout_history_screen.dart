import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/workout_history_model.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

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
                  _buildSummary('${user?.totalWorkouts ?? 0}', 'Sesi'),
                  Container(width: 1, height: 30,
                      color: Colors.white.withValues(alpha: 0.3)),
                  _buildSummary('${(user?.totalDuration ?? 0) ~/ 60}m', 'Durasi'),
                  Container(width: 1, height: 30,
                      color: Colors.white.withValues(alpha: 0.3)),
                  _buildSummary('${user?.totalCalories.toInt() ?? 0}', 'Kalori'),
                ],
              ),
            ),
          ),

          // History list
          Expanded(
            child: StreamBuilder<List<WorkoutHistoryModel>>(
              stream: FirestoreService().workoutHistoryStream(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var history = snapshot.data ?? [];
                
                // Apply Filter
                final now = DateTime.now();
                if (_filter == 'Minggu Ini') {
                  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                  history = history.where((h) => h.date.isAfter(startOfWeek)).toList();
                } else if (_filter == 'Bulan Ini') {
                  final startOfMonth = DateTime(now.year, now.month, 1);
                  history = history.where((h) => h.date.isAfter(startOfMonth)).toList();
                }

                if (history.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(history[index], isDark);
                  },
                );
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
        Text(value, style: AppTextStyles.h5(color: Colors.white)),
        Text(label, style: AppTextStyles.caption(color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildHistoryCard(WorkoutHistoryModel item, bool isDark) {
    final daysDiff = DateTime.now().difference(item.date).inDays;
    String dateText;
    if (daysDiff == 0) {
      dateText = 'Hari ini, ${DateFormat('HH:mm').format(item.date)}';
    } else if (daysDiff == 1) {
      dateText = 'Kemarin, ${DateFormat('HH:mm').format(item.date)}';
    } else {
      dateText = DateFormat('dd MMM yyyy').format(item.date);
    }

    // Default emoji
    final emoji = item.workoutName.contains('Body') ? '💪' : '🏋️';

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
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.workoutName,
                    style: AppTextStyles.labelMedium(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)),
                const SizedBox(height: 4),
                Text('${item.duration ~/ 60}min • ${item.caloriesBurned.toInt()}kal • ${item.exercisesCompleted} gerakan',
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
