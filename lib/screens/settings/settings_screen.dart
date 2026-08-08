import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Tampilan', [
              _toggle('Mode Gelap', Icons.dark_mode_outlined, theme.isDark,
                (v) => theme.toggleTheme(), isDark),
            ], isDark),
            const SizedBox(height: AppDimensions.xxl),
            _section('Notifikasi', [
              _item('Pengingat Latihan', Icons.notifications_outlined,
                () => Navigator.pushNamed(context, AppRoutes.reminderSettings), isDark),
            ], isDark),
            const SizedBox(height: AppDimensions.xxl),
            _section('Akun', [
              _item('Ubah Password', Icons.lock_outline, () {}, isDark),
              _item('Hapus Akun', Icons.delete_outline, () {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Akun'),
                  content: const Text('Tindakan ini tidak dapat dibatalkan. Semua data akan dihapus permanen.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
                  ],
                ));
              }, isDark, color: AppColors.error),
            ], isDark),
            const SizedBox(height: AppDimensions.xxl),
            _section('Data', [
              _item('Export Data Latihan', Icons.download_outlined, () {}, isDark),
              _item('Clear Cache', Icons.cleaning_services_outlined, () {}, isDark),
            ], isDark),
            const SizedBox(height: AppDimensions.xxl),
            _section('Tentang', [
              _item('Beri Rating', Icons.star_outline, () {}, isDark),
              _item('Bagikan Aplikasi', Icons.share_outlined, () {}, isDark),
              _item('Kebijakan Privasi', Icons.privacy_tip_outlined, () {}, isDark),
              _item('Syarat & Ketentuan', Icons.description_outlined, () {}, isDark),
            ], isDark),
            const SizedBox(height: AppDimensions.xxl),
            Center(child: Text('FitForge v1.0.0',
              style: AppTextStyles.caption(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight))),
            const SizedBox(height: AppDimensions.xxl),
            SizedBox(
              width: double.infinity, height: AppDimensions.buttonLg,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Keluar', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelSmall(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        const SizedBox(height: AppDimensions.md),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _item(String title, IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 22, color: color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      title: Text(title, style: AppTextStyles.bodyMedium(color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
    );
  }

  Widget _toggle(String title, IconData icon, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return ListTile(
      leading: Icon(icon, size: 22, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      title: Text(title, style: AppTextStyles.bodyMedium(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }
}
