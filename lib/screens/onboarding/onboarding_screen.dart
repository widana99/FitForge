import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/constants/app_constants.dart';
import '../../config/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.fitness_center_rounded,
      title: 'Latihan Personal',
      description:
          'Program latihan yang disesuaikan dengan level dan tujuanmu untuk hasil maksimal',
      gradient: AppColors.primaryGradient,
    ),
    OnboardingData(
      icon: Icons.trending_up_rounded,
      title: 'Pantau Progressmu',
      description:
          'Lihat perkembangan tubuh dan performamu setiap hari dengan grafik interaktif',
      gradient: AppColors.accentGradient,
    ),
    OnboardingData(
      icon: Icons.calendar_month_rounded,
      title: 'Jadwal Teratur',
      description:
          'Atur jadwal latihan dan dapatkan pengingat otomatis agar tetap konsisten',
      gradient: AppColors.warmGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], isDark);
                  },
                ),
              ),

              // Indicators + Button
              Padding(
                padding: const EdgeInsets.all(AppDimensions.xxl),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.xs,
                          ),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                            color: _currentPage == index
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkElevated
                                      : AppColors.lightElevated),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.xxxl),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonLg,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Mulai Sekarang'
                              : 'Lanjutkan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: data.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(data.icon, size: 80, color: Colors.white),
          ),

          const SizedBox(height: AppDimensions.huge),

          // Title
          Text(
            data.title,
            style: AppTextStyles.h2(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.lg),

          // Description
          Text(
            data.description,
            style: AppTextStyles.bodyLarge(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
