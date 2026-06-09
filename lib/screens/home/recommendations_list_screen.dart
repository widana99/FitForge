import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../models/workout_model.dart';
import '../workout/workout_session_screen.dart';

class RecommendationsListScreen extends StatelessWidget {
  const RecommendationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Retrieve passed args
    final List<WorkoutModel> recommendations = 
        ModalRoute.of(context)?.settings.arguments as List<WorkoutModel>? ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rekomendasi Untukmu'),
        centerTitle: true,
      ),
      body: recommendations.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.xl),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.lg),
              itemBuilder: (context, index) {
                return _buildExerciseCard(context, recommendations[index], isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            'Tidak ada rekomendasi khusus saat ini.',
            style: AppTextStyles.bodyLarge(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutModel workout, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutSessionScreen(workout: workout)),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          image: DecorationImage(
            image: NetworkImage(workout.thumbnailUrl.isNotEmpty ? workout.thumbnailUrl : 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5), 
              BlendMode.darken
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                workout.name,
                style: AppTextStyles.h4(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text('${workout.estimatedDuration} min', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  const Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text('${workout.estimatedCalories} kal', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
