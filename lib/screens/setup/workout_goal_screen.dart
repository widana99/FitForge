import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class WorkoutGoalScreen extends StatefulWidget {
  const WorkoutGoalScreen({super.key});

  @override
  State<WorkoutGoalScreen> createState() => _WorkoutGoalScreenState();
}

class _WorkoutGoalScreenState extends State<WorkoutGoalScreen> {
  String? _selectedGoal;

  final List<_GoalData> _goals = [
    _GoalData(
      id: 'weight_loss',
      icon: Icons.local_fire_department_rounded,
      emoji: '🔥',
      title: 'Turun Berat Badan',
      description: 'Bakar kalori dan turunkan berat badan secara efektif',
      color: AppColors.secondary,
    ),
    _GoalData(
      id: 'muscle_building',
      icon: Icons.fitness_center_rounded,
      emoji: '💪',
      title: 'Bentuk Otot',
      description: 'Bangun massa otot dan tingkatkan kekuatan',
      color: AppColors.primary,
    ),
    _GoalData(
      id: 'general_fitness',
      icon: Icons.favorite_rounded,
      emoji: '❤️',
      title: 'Kebugaran Umum',
      description: 'Tingkatkan stamina dan kesehatan secara keseluruhan',
      color: AppColors.accent,
    ),
  ];

  void _continue() async {
    if (_selectedGoal != null) {
      await context.read<AuthProvider>().updateUserProfile({
        'workoutGoal': _selectedGoal,
      });
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.fitnessTest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Apa tujuan\nlatihanmu? 🎯',
                style: AppTextStyles.h2(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Pilih satu tujuan utama',
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              // Goal cards
              Expanded(
                child: ListView.separated(
                  itemCount: _goals.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.lg),
                  itemBuilder: (context, index) {
                    return _buildGoalCard(_goals[index], isDark);
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              SizedBox(
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: _selectedGoal != null ? _continue : null,
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(_GoalData goal, bool isDark) {
    final isSelected = _selectedGoal == goal.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? goal.color.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected
                ? goal.color
                : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: goal.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(goal.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: AppTextStyles.h5(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: goal.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalData {
  final String id;
  final IconData icon;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  _GoalData({
    required this.id,
    required this.icon,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
