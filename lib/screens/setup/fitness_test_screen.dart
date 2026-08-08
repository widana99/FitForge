import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class FitnessTestScreen extends StatefulWidget {
  const FitnessTestScreen({super.key});

  @override
  State<FitnessTestScreen> createState() => _FitnessTestScreenState();
}

class _FitnessTestScreenState extends State<FitnessTestScreen> {
  final _pushUpController = TextEditingController();
  final _squatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pushUpController.dispose();
    _squatController.dispose();
    super.dispose();
  }

  void _evaluateAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final pushUps = int.tryParse(_pushUpController.text) ?? 0;
    final squats = int.tryParse(_squatController.text) ?? 0;

    // ALGORITHM FOR PUSH-UP
    double pushUpScore = 1; // Beginner
    if (pushUps > 25) {
      pushUpScore = 3; // Advanced
    } else if (pushUps >= 10) {
      pushUpScore = 2; // Intermediate
    }

    // ALGORITHM FOR SQUAT
    double squatScore = 1; // Beginner
    if (squats > 35) {
      squatScore = 3; // Advanced
    } else if (squats >= 15) {
      squatScore = 2; // Intermediate
    }

    final averageScore = (pushUpScore + squatScore) / 2;

    String calculatedLevel = 'beginner';
    if (averageScore > 2.5) {
      calculatedLevel = 'advanced';
    } else if (averageScore > 1.5) {
      calculatedLevel = 'intermediate';
    }

    await context.read<AuthProvider>().updateUserProfile({
      'trainingLevel': calculatedLevel,
    });

    if (mounted) {
      // Show result dialog
      _showResultDialog(calculatedLevel);
    }
  }

  void _showResultDialog(String level) {
    String levelName = '';
    String emoji = '';
    
    switch (level) {
      case 'advanced':
        levelName = 'Mahir';
        emoji = '🔥';
        break;
      case 'intermediate':
        levelName = 'Menengah';
        emoji = '⚡';
        break;
      default:
        levelName = 'Pemula';
        emoji = '🌱';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Text(
            'Evaluasi Selesai $emoji',
            style: AppTextStyles.h4(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Berdasarkan hasil tes fisik Anda, program latihan akan disesuaikan pada level:\n\n**$levelName**',
            style: AppTextStyles.bodyMedium(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonLg,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamed(context, AppRoutes.scheduleSetup); // Proceed
                },
                child: const Text('Lanjutkan'),
              ),
            ),
          ],
        );
      },
    );
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
                'Fitness Placement Test ⏱️',
                style: AppTextStyles.h2(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Kami tidak ingin sekadar menebak. Lakukan Push-Up dan Squat sebanyak mungkin (hingga kelelahan/dalam waktu 60 detik) untuk menentukan level awal yang presisi bagi Anda.',
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Jumlah Push-Up', isDark),
                        const SizedBox(height: AppDimensions.sm),
                        TextFormField(
                          controller: _pushUpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: 12',
                            prefixIcon: Icon(Icons.fitness_center_rounded),
                            suffixText: 'Repetisi',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Harap isi jumlah Push-up';
                            if (int.tryParse(v) == null) return 'Harus berupa angka valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        
                        _buildInputLabel('Jumlah Squat', isDark),
                        const SizedBox(height: AppDimensions.sm),
                        TextFormField(
                          controller: _squatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: 25',
                            prefixIcon: Icon(Icons.accessibility_new_rounded),
                            suffixText: 'Repetisi',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Harap isi jumlah Squat';
                            if (int.tryParse(v) == null) return 'Harus berupa angka valid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: AppDimensions.buttonLg,
                child: ElevatedButton(
                  onPressed: _evaluateAndContinue,
                  child: const Text('Evaluasi & Lanjutkan'),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.trainingLevel);
                },
                child: Text(
                  'Lewati Tes (Pilih Level Manual)',
                  style: AppTextStyles.labelMedium(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
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
}
