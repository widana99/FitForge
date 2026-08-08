import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/routes/app_routes.dart';
import '../../models/exercise_model.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String _selectedGroup = 'Semua';
  final _searchController = TextEditingController();
  bool _isGrid = false;

  final List<String> _muscleGroups = [
    'Semua',
    'Dada',
    'Punggung',
    'Bahu',
    'Lengan',
    'Perut',
    'Kaki',
    'Kardio',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.xl,
                AppDimensions.xl,
                AppDimensions.xl,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Gerakan 🏋️',
                    style: AppTextStyles.h3(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                    icon: Icon(
                      _isGrid
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari gerakan...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.xl,
                ),
                itemCount: _muscleGroups.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final group = _muscleGroups[index];
                  final isActive = _selectedGroup == group;
                  return ChoiceChip(
                    label: Text(group),
                    selected: isActive,
                    onSelected: (_) => setState(() => _selectedGroup = group),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: AppTextStyles.labelSmall(
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                    ),
                    side: BorderSide(
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkElevated
                                : AppColors.lightElevated),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // Exercise list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('exercises').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada data gerakan.'));
                  }

                  List<ExerciseModel> allExercises = snapshot.data!.docs
                      .map((doc) => ExerciseModel.fromFirestore(doc))
                      .toList();

                  List<ExerciseModel> filteredList = allExercises.where((ex) {
                    bool matchGroup = _selectedGroup == 'Semua' || 
                        ex.targetMuscle.toLowerCase().contains(_selectedGroup.toLowerCase());
                    
                    bool matchSearch = _searchController.text.isEmpty || 
                        ex.name.toLowerCase().contains(_searchController.text.toLowerCase());
                        
                    return matchGroup && matchSearch;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return const Center(child: Text('Gerakan tidak ditemukan.'));
                  }

                  return _isGrid
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.xl,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppDimensions.md,
                                crossAxisSpacing: AppDimensions.md,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildGridCard(filteredList[index], isDark);
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.xl,
                          ),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppDimensions.md),
                          itemBuilder: (context, index) {
                            return _buildListCard(filteredList[index], isDark);
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(ExerciseModel ex, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetail, arguments: ex.id),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(_getEmojiForMuscle(ex.targetMuscle), style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: AppTextStyles.labelMedium(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(child: _buildTag(ex.targetMuscle.split(',').first, AppColors.primary, isDark)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: _buildTag(
                          _levelName(ex.level),
                          _levelColor(ex.level),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              ex.type == 'Waktu'
                  ? '3×${ex.duration}s'
                  : '3×${ex.duration}',
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(ExerciseModel ex, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetail, arguments: ex.id),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(_getEmojiForMuscle(ex.targetMuscle), style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              ex.name,
              style: AppTextStyles.labelMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(child: _buildTag(ex.targetMuscle.split(',').first, AppColors.primary, isDark)),
                const SizedBox(width: 4),
                Flexible(
                  child: _buildTag(
                    _levelName(ex.level),
                    _levelColor(ex.level),
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmojiForMuscle(String targetMuscle) {
    final lower = targetMuscle.toLowerCase();
    if (lower.contains('dada') || lower.contains('pektoral')) return '🦍';
    if (lower.contains('punggung')) return '🦇';
    if (lower.contains('bahu')) return '🗿';
    if (lower.contains('lengan')) return '💪';
    if (lower.contains('kaki') || lower.contains('quad') || lower.contains('bokong')) return '🦵';
    if (lower.contains('perut') || lower.contains('inti')) return '🍫';
    return '🔥';
  }

  Widget _buildTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        text, 
        style: AppTextStyles.caption(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _levelName(String d) {
    if (d.toLowerCase().contains('pemula')) return 'Pemula';
    if (d.toLowerCase().contains('menengah')) return 'Menengah';
    if (d.toLowerCase().contains('mahir')) return 'Mahir';
    return d;
  }

  Color _levelColor(String d) {
    final lower = d.toLowerCase();
    if (lower.contains('pemula')) return AppColors.accent;
    if (lower.contains('menengah')) return AppColors.primary;
    if (lower.contains('mahir')) return AppColors.secondary;
    return AppColors.primary;
  }
}
