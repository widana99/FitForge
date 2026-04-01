import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';

class ScheduleSetupScreen extends StatefulWidget {
  const ScheduleSetupScreen({super.key});

  @override
  State<ScheduleSetupScreen> createState() => _ScheduleSetupScreenState();
}

class _ScheduleSetupScreenState extends State<ScheduleSetupScreen> {
  final Set<int> _selectedDays = {1, 3, 5}; // default: Mon, Wed, Fri
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);

  final List<_DayData> _days = [
    _DayData(id: 1, short: 'Sen', full: 'Senin'),
    _DayData(id: 2, short: 'Sel', full: 'Selasa'),
    _DayData(id: 3, short: 'Rab', full: 'Rabu'),
    _DayData(id: 4, short: 'Kam', full: 'Kamis'),
    _DayData(id: 5, short: 'Jum', full: 'Jumat'),
    _DayData(id: 6, short: 'Sab', full: 'Sabtu'),
    _DayData(id: 7, short: 'Min', full: 'Minggu'),
  ];

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _startTraining() {
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.main, (route) => false);
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
                'Atur Jadwal\nLatihanmu 📅',
                style: AppTextStyles.h2(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Pilih hari dan waktu latihan yang cocok untukmu',
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: AppDimensions.xxxl),

              // Day selector
              Text('Pilih Hari Latihan',
                  style: AppTextStyles.labelLarge(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)),
              const SizedBox(height: AppDimensions.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _days.map((day) {
                  final isSelected = _selectedDays.contains(day.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(day.id);
                        } else {
                          _selectedDays.add(day.id);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkElevated
                                  : AppColors.lightElevated),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day.short,
                          style: AppTextStyles.labelSmall(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.xxxl),

              // Time picker
              Text('Waktu Latihan',
                  style: AppTextStyles.labelLarge(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)),
              const SizedBox(height: AppDimensions.lg),
              GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkElevated
                          : AppColors.lightElevated,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: const Icon(Icons.access_time_rounded,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: AppDimensions.lg),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jam Latihan',
                              style: AppTextStyles.bodySmall(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight)),
                          Text(
                            _selectedTime.format(context),
                            style: AppTextStyles.h4(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.xxl),

              // Summary
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        '${_selectedDays.length} hari latihan per minggu',
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed:
                      _selectedDays.isNotEmpty ? _startTraining : null,
                  child: const Text('Mulai Latihan 🚀'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayData {
  final int id;
  final String short;
  final String full;
  _DayData({required this.id, required this.short, required this.full});
}
