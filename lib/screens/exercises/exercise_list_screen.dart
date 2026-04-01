import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String _selectedGroup = 'Semua';
  final _searchController = TextEditingController();
  bool _isGrid = false;

  final List<String> _muscleGroups = [
    'Semua',
    'Dada',
    'Punggung',
    'Kaki',
    'Bahu',
    'Lengan',
    'Core',
    'Kardio',
  ];

  final List<_Exercise> _exercises = [
    _Exercise('Push Up', 'Dada', 'beginner', 3, 12, 0, '💪'),
    _Exercise('Bench Press', 'Dada', 'intermediate', 4, 10, 0, '🏋️'),
    _Exercise('Squat', 'Kaki', 'beginner', 3, 15, 0, '🦵'),
    _Exercise('Deadlift', 'Punggung', 'advanced', 4, 8, 0, '🏋️'),
    _Exercise('Plank', 'Core', 'beginner', 3, 0, 30, '🧘'),
    _Exercise('Burpee', 'Kardio', 'intermediate', 3, 10, 0, '🔥'),
    _Exercise('Pull Up', 'Punggung', 'intermediate', 3, 8, 0, '💪'),
    _Exercise('Lunges', 'Kaki', 'beginner', 3, 12, 0, '🏃'),
    _Exercise('Shoulder Press', 'Bahu', 'intermediate', 3, 10, 0, '💪'),
    _Exercise('Bicep Curl', 'Lengan', 'beginner', 3, 12, 0, '💪'),
    _Exercise('Mountain Climber', 'Kardio', 'intermediate', 3, 0, 30, '🏔️'),
    _Exercise('Russian Twist', 'Core', 'beginner', 3, 15, 0, '🧘'),
  ];

  List<_Exercise> get _filtered {
    var list = _exercises;
    if (_selectedGroup != 'Semua') {
      list = list.where((e) => e.muscle == _selectedGroup).toList();
    }
    if (_searchController.text.isNotEmpty) {
      list = list
          .where(
            (e) => e.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.xl,
                AppDimensions.xl,
                AppDimensions.xl,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Gerakan 🏋️',
                    style: AppTextStyles.h3(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                    icon: Icon(
                      _isGrid
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari gerakan...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.xl,
                ),
                itemCount: _muscleGroups.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final group = _muscleGroups[index];
                  final isActive = _selectedGroup == group;
                  return ChoiceChip(
                    label: Text(group),
                    selected: isActive,
                    onSelected: (_) => setState(() => _selectedGroup = group),
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
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // Exercise list
            Expanded(
              child: _isGrid
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xl,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppDimensions.md,
                            crossAxisSpacing: AppDimensions.md,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        return _buildGridCard(_filtered[index], isDark);
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xl,
                      ),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDimensions.md),
                      itemBuilder: (context, index) {
                        return _buildListCard(_filtered[index], isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(_Exercise ex, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetail),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(ex.emoji, style: const TextStyle(fontSize: 28)),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(ex.muscle, AppColors.primary, isDark),
                      const SizedBox(width: 6),
                      _buildTag(
                        _levelName(ex.difficulty),
                        _levelColor(ex.difficulty),
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              ex.reps > 0
                  ? '${ex.sets}×${ex.reps}'
                  : '${ex.sets}×${ex.duration}s',
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(_Exercise ex, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetail),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(ex.emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              ex.name,
              style: AppTextStyles.labelMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildTag(ex.muscle, AppColors.primary, isDark),
                const SizedBox(width: 4),
                _buildTag(
                  _levelName(ex.difficulty),
                  _levelColor(ex.difficulty),
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(text, style: AppTextStyles.caption(color: color)),
    );
  }

  String _levelName(String d) {
    switch (d) {
      case 'beginner':
        return 'Pemula';
      case 'intermediate':
        return 'Menengah';
      case 'advanced':
        return 'Mahir';
      default:
        return d;
    }
  }

  Color _levelColor(String d) {
    switch (d) {
      case 'beginner':
        return AppColors.accent;
      case 'intermediate':
        return AppColors.primary;
      case 'advanced':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }
}

class _Exercise {
  final String name;
  final String muscle;
  final String difficulty;
  final int sets;
  final int reps;
  final int duration;
  final String emoji;

  _Exercise(
    this.name,
    this.muscle,
    this.difficulty,
    this.sets,
    this.reps,
    this.duration,
    this.emoji,
  );
}
