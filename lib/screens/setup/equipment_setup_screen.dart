import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class EquipmentSelectionScreen extends StatefulWidget {
  const EquipmentSelectionScreen({super.key});

  @override
  State<EquipmentSelectionScreen> createState() => _EquipmentSelectionScreenState();
}

class _EquipmentSelectionScreenState extends State<EquipmentSelectionScreen> {
  bool? _hasEquipment;

  void _continue() async {
    if (_hasEquipment != null) {
      await context.read<AuthProvider>().updateUserProfile({
        'hasEquipment': _hasEquipment,
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
                'Punya alat latihan\ndi rumah? 🏋️',
                style: AppTextStyles.h2(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Ini akan membantu kami menyesuaikan jenis latihanmu',
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              Expanded(
                child: Column(
                  children: [
                    _buildEquipmentCard(
                      value: false,
                      title: 'Tanpa Alat',
                      subtitle: 'Hanya berat tubuh',
                      description: 'Cocok untuk yang ingin latihan di mana saja tanpa perlengkapan tambahan.',
                      icon: Icons.accessibility_new_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildEquipmentCard(
                      value: true,
                      title: 'Menggunakan Alat',
                      subtitle: 'Dengan perlengkapan minimal',
                      description: 'Punya Dumbbell, Resistance Band, atau Pull-up Bar untuk variasi gerakan.',
                      icon: Icons.fitness_center_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: _hasEquipment != null ? _continue : null,
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard({
    required bool value,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _hasEquipment == value;

    return GestureDetector(
      onTap: () => setState(() => _hasEquipment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.secondary : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h5(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}
