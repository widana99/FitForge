class AppConstants {
  // App Info
  static const String appName = 'FitForge';
  static const String appVersion = '1.0.0';

  // Workout Goals
  static const String goalWeightLoss = 'weight_loss';
  static const String goalMuscleBuilding = 'muscle_building';
  static const String goalGeneralFitness = 'general_fitness';

  // Training Levels
  static const String levelBeginner = 'beginner';
  static const String levelIntermediate = 'intermediate';
  static const String levelAdvanced = 'advanced';

  // Muscle Groups
  static const List<String> muscleGroups = [
    'Dada',
    'Punggung',
    'Kaki',
    'Bahu',
    'Lengan',
    'Core',
    'Kardio',
  ];

  // Default schedule recommendations by level
  static const Map<String, List<int>> recommendedDays = {
    levelBeginner: [1, 3, 5], // Mon, Wed, Fri
    levelIntermediate: [1, 2, 4, 5, 6], // Mon, Tue, Thu, Fri, Sat
    levelAdvanced: [1, 2, 3, 4, 5, 6], // Mon-Sat
  };

  // Calorie estimation factors
  static const Map<String, double> calorieFactors = {
    levelBeginner: 5.0,
    levelIntermediate: 7.0,
    levelAdvanced: 9.0,
  };

  // SharedPreferences Keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefThemeMode = 'theme_mode';
}
