import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../models/exercise_model.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  Future<ExerciseModel?> _fetchExercise(String id) async {
    // -- DUMMY DATA UNTUK TESTING YOUTUBE PLAYER --
    if (id == 'pushup' || id == 'dummy') {
      return ExerciseModel(
        id: 'pushup',
        name: 'Push Up (Contoh Dummy)',
        targetMuscle: 'Dada, Trisep',
        level: 'Pemula',
        type: 'Repetisi',
        duration: 12,
        description: 'Pastikan badan lurus.\nTurun perlahan.',
        createdAt: DateTime.now(),
        youtubeVideos: [
          {'title': 'Tampak Depan', 'id': 'dQw4w9WgXcQ'}, // Rick roll as dummy
          {'title': 'Tampak Samping', 'id': 'IODxDxX7oi4'}, // Another dummy
          {'title': 'Tingkat Lanjut', 'id': 'y6120QOlsfU'}  // Another dummy
        ],
      );
    }
    // ----------------------------------------------
    
    final doc = await FirebaseFirestore.instance.collection('exercises').doc(id).get();
    if (doc.exists) {
      return ExerciseModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String exerciseId = ModalRoute.of(context)?.settings.arguments as String? ?? 'pushup';

    return Scaffold(
      body: FutureBuilder<ExerciseModel?>(
        future: _fetchExercise(exerciseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data gerakan tidak ditemukan.'));
          }

          final exercise = snapshot.data!;
          // Untuk tips, jika description berisi multiple lines, kita bisa memisahnya dengan newline
          final List<String> tips = exercise.description
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .toList();
          
          final tags = [exercise.targetMuscle.split(',').first, exercise.level, exercise.type];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: exercise.youtubeVideos.isNotEmpty ? 320 : 250,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: exercise.youtubeVideos.isNotEmpty
                      ? _YoutubePlayerWidget(youtubeVideos: exercise.youtubeVideos)
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('💪', style: TextStyle(fontSize: 64)),
                                SizedBox(height: 12),
                                Icon(
                                  Icons.play_circle_filled_rounded,
                                  color: Colors.white,
                                  size: 56,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: AppTextStyles.h2(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: tags.map((t) => _tag(t, AppColors.primary)).toList(),
                      ),
                      const SizedBox(height: AppDimensions.xxl),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.lg),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _info('Target', exercise.targetMuscle, isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxl),
                      Text(
                        'Panduan & Tips',
                        style: AppTextStyles.h5(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      ...tips.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t,
                                  style: AppTextStyles.bodyMedium(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tag(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
    ),
    child: Text(t, style: AppTextStyles.labelSmall(color: c)),
  );

  Widget _info(String l, String v, bool d) => Expanded(
        child: Column(
          children: [
            Text(
              v,
              textAlign: TextAlign.center,
              style: AppTextStyles.h5(
                color: d ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l,
              style: AppTextStyles.caption(
                color: d ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
}

class _YoutubePlayerWidget extends StatefulWidget {
  final List<Map<String, String>> youtubeVideos;

  const _YoutubePlayerWidget({required this.youtubeVideos});

  @override
  State<_YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<_YoutubePlayerWidget> {
  YoutubePlayerController? _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.youtubeVideos.isNotEmpty) {
      _initController(widget.youtubeVideos.first['id'] ?? '');
    }
  }

  void _initController(String videoId) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _changeVideo(int index) {
    if (index == _currentIndex) return;
    final videoId = widget.youtubeVideos[index]['id'] ?? '';
    if (videoId.isEmpty) return;

    setState(() {
      _currentIndex = index;
    });
    // Gunakan cue agar tidak langsung terputar, sesuai permintaan user
    _controller?.cue(videoId);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            progressColors: const ProgressBarColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.accent,
            ),
          ),
        ),
        if (widget.youtubeVideos.length > 1)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.youtubeVideos.length, (index) {
                  final isSelected = index == _currentIndex;
                  final title = widget.youtubeVideos[index]['title'] ?? 'Video ${index + 1}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(title),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) _changeVideo(index);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}

