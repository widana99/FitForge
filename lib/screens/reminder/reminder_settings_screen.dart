import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _enabled = true;
  bool _showMotivation = true;
  int _minutesBefore = 15;
  final Set<int> _selectedDays = {1, 3, 5};
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengingat Latihan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main toggle
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktifkan Pengingat',
                          style: AppTextStyles.labelLarge(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Dapatkan notifikasi sebelum jadwal latihan',
                          style: AppTextStyles.bodySmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            if (_enabled) ...[
              const SizedBox(height: AppDimensions.xxl),
              Text(
                'Hari Latihan',
                style: AppTextStyles.labelLarge(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final d in [
                    (1, 'Sen'),
                    (2, 'Sel'),
                    (3, 'Rab'),
                    (4, 'Kam'),
                    (5, 'Jum'),
                    (6, 'Sab'),
                    (7, 'Min'),
                  ])
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedDays.contains(d.$1)
                            ? _selectedDays.remove(d.$1)
                            : _selectedDays.add(d.$1);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _selectedDays.contains(d.$1)
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedDays.contains(d.$1)
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkElevated
                                      : AppColors.lightElevated),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d.$2,
                            style: AppTextStyles.labelSmall(
                              color: _selectedDays.contains(d.$1)
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.xxl),
              Text(
                'Waktu Pengingat',
                style: AppTextStyles.labelLarge(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Text(
                        _time.format(context),
                        style: AppTextStyles.h4(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xxl),
              // Motivation toggle
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        'Tampilkan Quote Motivasi',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _showMotivation,
                      onChanged: (v) => setState(() => _showMotivation = v),
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xxl),
              // Preview
              Text(
                'Preview Notifikasi',
                style: AppTextStyles.labelLarge(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'FitForge',
                          style: AppTextStyles.labelSmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_time.format(context)}',
                          style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '🏋️ Waktunya Latihan!',
                      style: AppTextStyles.labelMedium(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (_showMotivation)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '"Konsistensi mengalahkan motivasi"',
                          style: AppTextStyles.bodySmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.xxxl),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonLg,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
