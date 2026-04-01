import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    'Push Up',
                    style: AppTextStyles.h2(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Row(
                    children: [
                      _tag('Dada', AppColors.primary),
                      const SizedBox(width: 8),
                      _tag('Pemula', AppColors.accent),
                    ],
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
                        _info('3', 'Set', isDark),
                        _info('12', 'Rep', isDark),
                        _info('30s', 'Istirahat', isDark),
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
                    'Push up melatih otot dada, bahu, dan trisep. Posisi telungkup, kedua tangan di samping dada, dorong tubuh ke atas. Pastikan tubuh lurus dari kepala hingga tumit.',
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  Text(
                    'Tips',
                    style: AppTextStyles.h5(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  ...[
                    'Jaga tubuh tetap lurus',
                    'Turunkan dada hampir menyentuh lantai',
                    'Tarik napas saat turun, hembuskan saat naik',
                    'Pemula bisa dari posisi lutut',
                  ].map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.accent,
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
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Tambahkan ke Latihan'),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
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

  Widget _info(String v, String l, bool d) => Column(
    children: [
      Text(
        v,
        style: AppTextStyles.h4(
          color: d ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      Text(
        l,
        style: AppTextStyles.caption(
          color: d ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    ],
  );
}
