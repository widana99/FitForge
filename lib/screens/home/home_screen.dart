import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../models/workout_model.dart';
import '../../models/user_model.dart';
import '../../services/workout_presets.dart';
import '../../screens/workout/workout_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();
  late String _greeting;
  late String _quote;

  @override
  void initState() {
    super.initState();
    _greeting = _getGreetingText();
    _quote = WorkoutPresets.motivationQuotes[_random.nextInt(WorkoutPresets.motivationQuotes.length)];
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final homeDataFuture = Future.wait([
      WorkoutPresets.getRecommendation(
        user.workoutGoal ?? 'muscle_building',
        user.trainingLevel ?? 'beginner',
      ),
      WorkoutPresets.getRelatedRecommendations(
        user.workoutGoal ?? 'muscle_building',
        user.trainingLevel ?? 'beginner',
      ),
    ]);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(user, isDark),
              const SizedBox(height: AppDimensions.xxl),
              
              _buildStatsRow(user, isDark),
              const SizedBox(height: AppDimensions.xxxl),
              Text("Fokus Tubuh", style: AppTextStyles.h4(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: AppDimensions.lg),
              _buildFocusSection(isDark),

              const SizedBox(height: AppDimensions.xxxl),

              FutureBuilder<List<dynamic>>(
                future: homeDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox();
                  }

                  final WorkoutModel featuredWorkout = snapshot.data![0];
                  final List<WorkoutModel> suggestions = snapshot.data![1];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Latihan Hari Ini", style: AppTextStyles.h4(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      const SizedBox(height: AppDimensions.lg),
                      _buildFeaturedCard(featuredWorkout, isDark),
                      
                      const SizedBox(height: AppDimensions.xxxl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("Rekomendasi Untukmu", style: AppTextStyles.h5(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context, 
                              AppRoutes.recommendationsList,
                              arguments: suggestions,
                            ),
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _buildHorizontalRecommendations(suggestions, isDark),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: AppDimensions.xxxl),
              Text("Kategori Tujuan", style: AppTextStyles.h4(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: AppDimensions.lg),
              _buildGoalSelectionSection(isDark),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(UserModel user, bool isDark) {
    final unreadCount = context.select<AuthProvider, int>((p) => p.unreadCount);

    return Row(
      children: [
        _buildAvatar(user),
        const SizedBox(width: AppDimensions.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, ${user.name.split(' ')[0]}',
                style: AppTextStyles.h4(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _quote,
                      maxLines: 2, // Allow 2 lines for motivation
                      style: AppTextStyles.caption(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? AppColors.darkElevated : AppColors.lightElevated),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 22),
                if (unreadCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.darkBg : AppColors.lightBg, width: 2),
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(UserModel user) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
            : const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
      ),
    );
  }

  Widget _buildStatsRow(UserModel user, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildPremiumStatCard('Streak', '${user.streak}', 'Hari', Icons.local_fire_department_rounded, AppColors.secondary, isDark)),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _buildPremiumStatCard('Total', '${(user.totalDuration / 60).toStringAsFixed(0)}', 'Menit', Icons.timer_outlined, AppColors.primary, isDark)),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _buildPremiumStatCard('Sesi', '${user.totalWorkouts}', 'Selesai', Icons.fitness_center_rounded, AppColors.accent, isDark)),
      ],
    );
  }

  Widget _buildPremiumStatCard(String label, String value, String unit, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg, horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: AppTextStyles.h4(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit, style: AppTextStyles.caption(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(WorkoutModel workout, bool isDark) {
    return GestureDetector(
      onTap: () => _startWorkout(workout),
      child: Container(
        constraints: const BoxConstraints(minHeight: 220), // Use constraints instead of fixed height
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=2069&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Wrap content
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('REKOMENDASI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 12),
              Text(workout.name, style: AppTextStyles.h3(color: Colors.white)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('${workout.estimatedDuration} menit', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 12),
                  const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(workout.difficulty.toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Text('Mulai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalRecommendations(List<WorkoutModel> suggestions, bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.lg),
        itemBuilder: (context, i) => _buildMiniWorkoutCard(suggestions[i], isDark),
      ),
    );
  }

  Widget _buildMiniWorkoutCard(WorkoutModel workout, bool isDark) {
    final images = [
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1920&auto=format&fit=crop', // yoga
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop', // strength
    ];
    final imgUrl = workout.id.contains('gen_fit') ? images[0] : images[1];

    return GestureDetector(
      onTap: () => _startWorkout(workout),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelLarge(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  const SizedBox(height: 4),
                  Text('${workout.estimatedDuration} min • ${workout.difficulty}', style: AppTextStyles.caption(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startWorkout(WorkoutModel workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutSessionScreen(workout: workout)),
    );
  }

  Widget _buildFocusSection(bool isDark) {
    final List<Map<String, dynamic>> focusCategories = [
      {'title': 'Seluruh Tubuh', 'icon': Icons.accessibility_new_rounded},
      {'title': 'Otot Perut', 'icon': Icons.airline_seat_flat_angled_rounded},
      {'title': 'Lengan', 'icon': Icons.fitness_center_rounded},
      {'title': 'Bokong/Pinggul', 'icon': Icons.sports_gymnastics_rounded},
      {'title': 'Kaki', 'icon': Icons.directions_run_rounded},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: focusCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
        itemBuilder: (context, i) {
          final cat = focusCategories[i];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context, 
                AppRoutes.focusWorkout, 
                arguments: cat['title'],
              );
            },
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                    ],
                  ),
                  child: Icon(cat['icon'] as IconData, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['title'] as String,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalSelectionSection(bool isDark) {
    final List<Map<String, dynamic>> goals = [
      {'id': 'fat_loss', 'title': 'Bakar Lemak', 'icon': Icons.local_fire_department_rounded, 'color': Colors.redAccent},
      {'id': 'muscle_building', 'title': 'Bangun Otot', 'icon': Icons.fitness_center_rounded, 'color': AppColors.primary},
      {'id': 'general_fitness', 'title': 'Jaga Kebugaran', 'icon': Icons.favorite_rounded, 'color': AppColors.accent},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
        itemBuilder: (context, i) {
          final goal = goals[i];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context, 
                '/goal_workout', 
                arguments: goal['id'],
              );
            },
            child: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: goal['color'].withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                ],
                border: Border.all(color: goal['color'].withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(goal['icon'] as IconData, size: 30, color: goal['color'] as Color),
                  const SizedBox(height: 8),
                  Text(
                    goal['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
