import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class TrainingLevelScreen extends StatefulWidget {
  const TrainingLevelScreen({super.key});

  @override
  State<TrainingLevelScreen> createState() => _TrainingLevelScreenState();
}

class _TrainingLevelScreenState extends State<TrainingLevelScreen> {
  String? _selectedLevel;

  final List<_LevelData> _levels = [
    _LevelData(
      id: 'beginner',
      emoji: '🌱',
      title: 'Pemula',
      description: 'Baru mulai berolahraga atau sudah lama tidak aktif',
      frequency: '3x / minggu',
      duration: '15-20 menit',
      color: AppColors.accent,
    ),
    _LevelData(
      id: 'intermediate',
      emoji: '⚡',
      title: 'Menengah',
      description: 'Sudah terbiasa berolahraga secara rutin',
      frequency: '4-5x / minggu',
      duration: '30-45 menit',
      color: AppColors.primary,
    ),
    _LevelData(
      id: 'advanced',
      emoji: '🔥',
      title: 'Mahir',
      description: 'Atlet atau sudah berpengalaman bertahun-tahun',
      frequency: '5-6x / minggu',
      duration: '45-60 menit',
      color: AppColors.secondary,
    ),
  ];

  void _continue() async {
    if (_selectedLevel != null) {
      await context.read<AuthProvider>().updateUserProfile({
        'trainingLevel': _selectedLevel,
      });
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.scheduleSetup);
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
                'Level latihanmu\nsaat ini? 💪',
                style: AppTextStyles.h2(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Pilih yang paling sesuai denganmu',
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              Expanded(
                child: ListView.separated(
                  itemCount: _levels.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.lg),
                  itemBuilder: (context, index) {
                    return _buildLevelCard(_levels[index], isDark);
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              SizedBox(
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: _selectedLevel != null ? _continue : null,
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(_LevelData level, bool isDark) {
    final isSelected = _selectedLevel == level.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = level.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? level.color.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected
                ? level.color
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
                color: level.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(level.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.title,
                      style: AppTextStyles.h5(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)),
                  const SizedBox(height: 4),
                  Text(level.description,
                      style: AppTextStyles.bodySmall(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(
                          Icons.calendar_today_outlined, level.frequency, isDark),
                      _buildInfoChip(
                          Icons.timer_outlined, level.duration, isDark),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: level.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBg.withValues(alpha: 0.5)
            : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.caption(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _LevelData {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String frequency;
  final String duration;
  final Color color;

  _LevelData({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.frequency,
    required this.duration,
    required this.color,
  });
}
