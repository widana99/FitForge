import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../models/workout_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/workout_presets.dart';
import '../workout/workout_session_screen.dart';

class FocusWorkoutScreen extends StatefulWidget {
  final String focusCategory;
  final bool isGoalWorkout;

  const FocusWorkoutScreen({super.key, required this.focusCategory, this.isGoalWorkout = false});

  @override
  State<FocusWorkoutScreen> createState() => _FocusWorkoutScreenState();
}

class _FocusWorkoutScreenState extends State<FocusWorkoutScreen> {
  late String _selectedLevel;
  late bool _hasEquipment;
  late List<WorkoutModel> _workouts;

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal mengambil riwayat pengguna
    final auth = context.read<AuthProvider>();
    _selectedLevel = auth.userModel?.trainingLevel ?? 'beginner';
    _hasEquipment = auth.userModel?.hasEquipment ?? false;
    
    _generateWorkouts();
  }

  void _generateWorkouts() {
    setState(() {
      if (widget.isGoalWorkout) {
        _workouts = WorkoutPresets.getWorkoutsByGoal(
          widget.focusCategory, 
          _selectedLevel, 
          _hasEquipment
        );
      } else {
        _workouts = WorkoutPresets.getWorkoutsByFocus(
          widget.focusCategory, 
          _selectedLevel, 
          _hasEquipment
        );
      }
    });
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
        title: Text(widget.isGoalWorkout 
           ? 'Tujuan: ${widget.focusCategory == 'fat_loss' ? 'Turun BB' : (widget.focusCategory == 'muscle_building' ? 'Bentuk Otot' : 'Kebugaran')}' 
           : 'Fokus: ${widget.focusCategory}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterSection(isDark),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _workouts.isEmpty 
              ? Center(child: Text("Tidak ada latihan tersedia.", style: AppTextStyles.bodyLarge(color: isDark ? Colors.white54 : Colors.black54)))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  itemCount: _workouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.lg),
                  itemBuilder: (context, index) {
                    return _buildWorkoutCard(_workouts[index], isDark);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkBg : AppColors.lightBg,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Atur Tingkat Kesulitan:", style: AppTextStyles.labelMedium(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChoiceChip('Pemula', 'beginner', isDark),
                const SizedBox(width: 8),
                _buildChoiceChip('Menengah', 'intermediate', isDark),
                const SizedBox(width: 8),
                _buildChoiceChip('Mahir', 'advanced', isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text("Atur Peralatan:", style: AppTextStyles.labelMedium(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildEquipChip('Tanpa Alat', false, isDark),
              const SizedBox(width: 8),
              _buildEquipChip('Memakai Alat', true, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, bool isDark) {
    bool isSelected = _selectedLevel == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _selectedLevel = value;
          _generateWorkouts();
        }
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    );
  }

  Widget _buildEquipChip(String label, bool value, bool isDark) {
    bool isSelected = _hasEquipment == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
         if (selected) {
            _hasEquipment = value;
            _generateWorkouts();
         }
      },
      selectedColor: AppColors.accent.withValues(alpha: 0.2),
      checkmarkColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutSessionScreen(workout: workout)),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          image: DecorationImage(
            image: NetworkImage(workout.thumbnailUrl.isNotEmpty ? workout.thumbnailUrl : 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5), 
              BlendMode.darken
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                 child: Text(workout.difficulty.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(
                workout.name,
                style: AppTextStyles.h4(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text('${workout.estimatedDuration} min', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  const Icon(Icons.fitness_center_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text('${workout.exercises.length} Gerakan', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
