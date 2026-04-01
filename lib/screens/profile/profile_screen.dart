import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.lg),

              // Avatar & Name
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text('Pengguna FitForge',
                  style: AppTextStyles.h4(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)),
              const SizedBox(height: 4),
              Text('user@email.com',
                  style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)),
              const SizedBox(height: AppDimensions.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text('🌱 Pemula',
                    style: AppTextStyles.labelSmall(
                        color: AppColors.primary)),
              ),

              const SizedBox(height: AppDimensions.xxl),

              // Body Stats
              Container(
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBodyStat('65', 'kg', 'Berat', isDark),
                    Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? AppColors.darkElevated
                            : AppColors.lightElevated),
                    _buildBodyStat('170', 'cm', 'Tinggi', isDark),
                    Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? AppColors.darkElevated
                            : AppColors.lightElevated),
                    _buildBodyStat('22.5', '', 'BMI', isDark),
                    Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? AppColors.darkElevated
                            : AppColors.lightElevated),
                    _buildBodyStat('24', 'thn', 'Usia', isDark),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              // Menu items
              _buildMenuItem(Icons.edit_outlined, 'Edit Profil', () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              }, isDark),
              _buildMenuItem(Icons.flag_outlined, 'Ubah Tujuan Latihan', () {
                Navigator.pushNamed(context, AppRoutes.workoutGoal);
              }, isDark),
              _buildMenuItem(Icons.calendar_today_outlined, 'Ubah Jadwal',
                  () {
                Navigator.pushNamed(context, AppRoutes.scheduleSetup);
              }, isDark),
              _buildMenuItem(
                  Icons.notifications_outlined, 'Pengingat Latihan', () {
                Navigator.pushNamed(context, AppRoutes.reminderSettings);
              }, isDark),
              _buildMenuItem(Icons.history_rounded, 'Riwayat Latihan', () {
                Navigator.pushNamed(context, AppRoutes.workoutHistory);
              }, isDark),
              _buildMenuItem(Icons.settings_outlined, 'Pengaturan', () {
                Navigator.pushNamed(context, AppRoutes.settings);
              }, isDark),

              const SizedBox(height: AppDimensions.lg),

              // Logout
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonLg,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Keluar'),
                        content: const Text(
                            'Apakah kamu yakin ingin keluar dari akun?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, AppRoutes.login, (r) => false);
                            },
                            child: const Text('Keluar',
                                style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.error),
                  label: const Text('Keluar',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyStat(
      String value, String unit, String label, bool isDark) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: value,
            style: AppTextStyles.h5(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            children: [
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)),
      ],
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(icon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        ),
        title: Text(title,
            style: AppTextStyles.bodyMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}
