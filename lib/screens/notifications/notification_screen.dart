import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark as read when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().markNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = context.watch<AuthProvider>().notifications;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi'),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.xl),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _buildNotificationItem(n, isDark);
              },
            ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> n, bool isDark) {
    IconData icon;
    Color color;

    switch (n['type']) {
      case 'tips':
        icon = Icons.lightbulb_outline_rounded;
        color = AppColors.accent;
        break;
      case 'workout':
        icon = Icons.fitness_center_rounded;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = AppColors.secondary;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: n['isRead'] == false
              ? color.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n['title'],
                      style: AppTextStyles.labelLarge(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      n['time'],
                      style: AppTextStyles.caption(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n['body'],
                  style: AppTextStyles.bodySmall(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            'Belum ada notifikasi',
            style: AppTextStyles.bodyLarge(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
