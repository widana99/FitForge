import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String? _selectedType;

  void _continue() async {
    if (_selectedType != null) {
      await context.read<AuthProvider>().updateUserProfile({
        'flowPreference': _selectedType,
      });
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.equipmentSetup);
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
                'Bagaimana kamu ingin\nmenggunakan FitForge? 📱',
                style: AppTextStyles.h2(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Pilih gaya antarmuka yang paling nyaman untukmu',
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              Expanded(
                child: Column(
                  children: [
                    _buildTypeCard(
                      id: 'guided',
                      title: 'User Awam',
                      subtitle: 'Suka panduan langkah-demi-langkah',
                      description: 'Tampilan lebih bersih, fokus pada satu latihan harian utama, dan tips teknis gerakan.',
                      icon: Icons.auto_awesome_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _buildTypeCard(
                      id: 'efficient',
                      title: 'User Terbiasa',
                      subtitle: 'Suka efisiensi dan data lengkap',
                      description: 'Dashboard penuh statistik, akses cepat ke semua kategori, dan navigasi yang lebih padat.',
                      icon: Icons.speed_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: _selectedType != null ? _continue : null,
                  child: const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedType == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
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
                color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
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
                    style: AppTextStyles.labelSmall(color: AppColors.primary),
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
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
