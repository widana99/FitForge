import 'package:flutter/material.dart';
import '../../screens/notifications/notification_screen.dart';
import '../../screens/home/recommendations_list_screen.dart';
import '../../screens/home/focus_workout_screen.dart';

import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/setup/workout_goal_screen.dart';
import '../../screens/setup/training_level_screen.dart';
import '../../screens/setup/fitness_test_screen.dart';
import '../../screens/setup/schedule_setup_screen.dart';
import '../../screens/setup/personal_data_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/main_navigation.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/progress/progress_screen.dart';
import '../../screens/workout/workout_session_screen.dart';
import '../../screens/history/workout_history_screen.dart';
import '../../screens/exercises/exercise_list_screen.dart';
import '../../screens/exercises/exercise_detail_screen.dart';
import '../../screens/reminder/reminder_settings_screen.dart';
import '../../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String workoutGoal = '/setup/goal';
  static const String trainingLevel = '/setup/level';
  static const String fitnessTest = '/setup/fitness_test';

  static const String scheduleSetup = '/setup/schedule';
  static const String personalData = '/setup/personal';
  static const String main = '/main';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String progress = '/progress';
  static const String workoutSession = '/workout/session';
  static const String workoutHistory = '/history';
  static const String exerciseList = '/exercises';
  static const String exerciseDetail = '/exercises/detail';
  static const String reminderSettings = '/reminder';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String recommendationsList = '/recommendations_list';
  static const String focusWorkout = '/focus_workout';

  static Map<String, WidgetBuilder> get routes {
    return {
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      workoutGoal: (context) => const WorkoutGoalScreen(),
      trainingLevel: (context) => const TrainingLevelScreen(),
      fitnessTest: (context) => const FitnessTestScreen(),

      scheduleSetup: (context) => const ScheduleSetupScreen(),
      personalData: (context) => const PersonalDataScreen(),
      main: (context) => const MainNavigation(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      progress: (context) => const ProgressScreen(),
      workoutSession: (context) => const WorkoutSessionScreen(),
      workoutHistory: (context) => const WorkoutHistoryScreen(),
      exerciseList: (context) => const ExerciseListScreen(),
      exerciseDetail: (context) => const ExerciseDetailScreen(),
      reminderSettings: (context) => const ReminderSettingsScreen(),
      settings: (context) => const SettingsScreen(),
      notifications: (context) => const NotificationScreen(),
      recommendationsList: (context) => const RecommendationsListScreen(),
      focusWorkout: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as String?;
        return FocusWorkoutScreen(focusCategory: args ?? '');
      },
      '/goal_workout': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as String?;
        return FocusWorkoutScreen(focusCategory: args ?? 'fat_loss', isGoalWorkout: true);
      },
    };
  }
}
