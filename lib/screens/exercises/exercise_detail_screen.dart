import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../services/workout_presets.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Retrieve passed exerciseId, fallback to 'pushup' if not provided
    final String exerciseId = ModalRoute.of(context)?.settings.arguments as String? ?? 'pushup';
    
    // Retrieve data from DB, fallback to 'default' if not found
    final Map<String, dynamic> exerciseData = WorkoutPresets.exerciseDB[exerciseId] ?? WorkoutPresets.exerciseDB['default']!;
    
    final String name = exerciseData['name'];
    final String focus = exerciseData['focus'];
    final List<String> tags = exerciseData['tags'];
    final String desc = exerciseData['desc'];
    final List<String> tips = exerciseData['tips'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💪', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 12),
                      Icon(
                        Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.h2(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: tags.map((t) => _tag(t, AppColors.primary)).toList(),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _info('Target', focus, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.h5(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    desc,
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  Text(
                    'Panduan & Tips',
                    style: AppTextStyles.h5(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  ...tips.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t,
                              style: AppTextStyles.bodyMedium(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxxl),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonLg,
                  ), // Removed empty space placeholder button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
    ),
    child: Text(t, style: AppTextStyles.labelSmall(color: c)),
  );

  Widget _info(String l, String v, bool d) => Expanded(
        child: Column(
          children: [
            Text(
              v,
              textAlign: TextAlign.center,
              style: AppTextStyles.h5(
                color: d ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l,
              style: AppTextStyles.caption(
                color: d ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
}
