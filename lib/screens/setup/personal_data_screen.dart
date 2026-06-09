import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dateOfBirth;
  String _gender = '';
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_dateOfBirth == null || _gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data pribadi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.updateUserProfile({
      'dateOfBirth': _dateOfBirth,
      'gender': _gender,
      'weight': double.tryParse(_weightController.text) ?? 0,
      'height': double.tryParse(_heightController.text) ?? 0,
    });

    if (auth.error == null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.workoutGoal);
    }
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pribadi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.xxl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sedikit lagi! 🚀',
                        style: AppTextStyles.h4(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'Kami butuh data ini untuk menyesuaikan program latihanmu.',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxxl),

                      // Date of birth
                      _buildInputLabel('Tanggal Lahir', isDark),
                      const SizedBox(height: AppDimensions.sm),
                      GestureDetector(
                        onTap: _selectDateOfBirth,
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkElevated
                                  : AppColors.lightElevated,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppDimensions.md),
                              Expanded(
                                child: Text(
                                  _dateOfBirth != null
                                      ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year} (${_calculateAge(_dateOfBirth!)} tahun)'
                                      : 'Pilih tanggal lahir',
                                  style: AppTextStyles.bodyMedium(
                                    color: _dateOfBirth != null
                                        ? (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight)
                                        : (isDark
                                              ? AppColors.textTertiaryDark
                                              : AppColors.textTertiaryLight),
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.xl),

                      // Gender
                      _buildInputLabel('Gender', isDark),
                      const SizedBox(height: AppDimensions.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption('Pria', Icons.male_rounded, isDark),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: _buildGenderOption(
                              'Wanita',
                              Icons.female_rounded,
                              isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.xl),

                      // Weight & Height
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel('Berat Badan', isDark),
                                const SizedBox(height: AppDimensions.sm),
                                TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                                    suffixText: 'kg',
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Isi' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel('Tinggi Badan', isDark),
                                const SizedBox(height: AppDimensions.sm),
                                TextFormField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.height_rounded),
                                    suffixText: 'cm',
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Isi' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (auth.error != null) ...[
                        const SizedBox(height: AppDimensions.lg),
                        Text(
                          auth.error!,
                          style: AppTextStyles.bodySmall(color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xxl),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _saveData,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lanjutkan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Text(
      label,
      style: AppTextStyles.labelMedium(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon, bool isDark) {
    final isSelected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : null, size: 28),
            const SizedBox(height: AppDimensions.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
