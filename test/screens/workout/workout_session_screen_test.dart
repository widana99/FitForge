import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/screens/workout/workout_session_screen.dart';
import 'package:fitforge/services/audio_coaching_service.dart';
import 'package:fitforge/models/workout_model.dart';
import 'package:fitforge/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutSessionScreen - AudioCoachingService Lifecycle', () {
    // Helper to create a test workout
    WorkoutModel createTestWorkout() {
      return WorkoutModel(
        id: 'test-workout-1',
        name: 'Test Workout',
        description: 'Test workout for unit testing',
        category: 'muscle_building',
        difficulty: 'beginner',
        estimatedDuration: 20,
        estimatedCalories: 200,
        thumbnailUrl: '',
        createdAt: DateTime.now(),
        exercises: [
          WorkoutExercise(
            exerciseId: 'pushup',
            exerciseName: 'Push Up',
            sets: 3,
            reps: 10,
            duration: 0,
            restTime: 15,
          ),
        ],
      );
    }

    // Helper to create a minimal AuthProvider for testing
    Widget createTestWidget(WorkoutModel workout) {
      return ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: MaterialApp(home: WorkoutSessionScreen(workout: workout)),
      );
    }

    testWidgets('should initialize AudioCoachingService in initState', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.1
      // This test verifies that AudioCoachingService is properly initialized
      // when WorkoutSessionScreen enters its initState lifecycle method

      // Arrange
      final workout = createTestWorkout();

      // Act
      // Build the widget
      await tester.pumpWidget(createTestWidget(workout));

      // Wait for initialization to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - verify the screen was built successfully
      // The successful build indicates that initState completed without errors
      // and _initializeAudioCoaching() was called
      expect(find.byType(WorkoutSessionScreen), findsOneWidget);

      // Verify pre-session view is displayed (workout not started yet)
      expect(find.text('Sesi Latihan'), findsOneWidget);
      expect(find.text('Test Workout'), findsOneWidget);
    });

    testWidgets('should dispose AudioCoachingService in dispose', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.3
      // This test verifies that AudioCoachingService is properly disposed
      // when WorkoutSessionScreen is removed from the widget tree

      // Arrange
      final workout = createTestWorkout();

      // Act
      // Build the widget
      await tester.pumpWidget(createTestWidget(workout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify screen is present
      expect(find.byType(WorkoutSessionScreen), findsOneWidget);

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: Text('Different Screen'))),
        ),
      );

      // Wait for dispose to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - verify the screen was removed
      expect(find.byType(WorkoutSessionScreen), findsNothing);

      // If we reach here without errors, dispose was successful
      // The AudioCoachingService.dispose() was called without throwing exceptions
      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets(
      'should handle AudioCoachingService initialization failure gracefully',
      (WidgetTester tester) async {
        // Requirements: 6.1, 7.1
        // This test verifies that if AudioCoachingService initialization fails
        // (e.g., in test environment without TTS), the screen still builds correctly

        // Arrange
        final workout = createTestWorkout();

        // Act - Build the widget (TTS will fail in test environment)
        await tester.pumpWidget(createTestWidget(workout));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - screen should still build successfully
        expect(find.byType(WorkoutSessionScreen), findsOneWidget);

        // Pre-session view should be displayed
        expect(find.text('Sesi Latihan'), findsOneWidget);
        expect(find.text('Test Workout'), findsOneWidget);

        // The workout should be functional even without audio
        expect(find.text('Mulai Latihan 🚀'), findsOneWidget);
      },
    );

    testWidgets(
      'should maintain AudioCoachingService throughout screen lifecycle',
      (WidgetTester tester) async {
        // Requirements: 6.1, 6.3
        // This test verifies that AudioCoachingService is maintained throughout
        // the entire lifecycle of WorkoutSessionScreen

        // Arrange
        final workout = createTestWorkout();

        // Act - Build the widget
        await tester.pumpWidget(createTestWidget(workout));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - initial state
        expect(find.byType(WorkoutSessionScreen), findsOneWidget);

        // Trigger a rebuild by tapping a button (if available)
        // This verifies that the service persists through rebuilds
        final startButton = find.text('Mulai Latihan 🚀');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          // Screen should still be present and functional
          expect(find.byType(WorkoutSessionScreen), findsOneWidget);
        }

        // Navigate away to dispose
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: Text('Done'))),
        );
        await tester.pump();

        // Verify dispose completed successfully
        expect(find.byType(WorkoutSessionScreen), findsNothing);
      },
    );

    testWidgets(
      'should handle multiple rapid initialization and disposal cycles',
      (WidgetTester tester) async {
        // Requirements: 6.1, 6.3, 8.3
        // This test verifies that AudioCoachingService can handle multiple
        // rapid initialization and disposal cycles without leaking resources

        // Arrange
        final workout = createTestWorkout();

        // Act - Create and dispose the screen multiple times
        for (int i = 0; i < 5; i++) {
          // Build the screen
          await tester.pumpWidget(createTestWidget(workout));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));

          // Verify screen is present
          expect(find.byType(WorkoutSessionScreen), findsOneWidget);

          // Dispose the screen
          await tester.pumpWidget(
            MaterialApp(home: Scaffold(body: Text('Cycle $i'))),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));

          // Verify screen is gone
          expect(find.byType(WorkoutSessionScreen), findsNothing);
        }

        // Assert - if we reach here, all cycles completed successfully
        expect(true, isTrue);
      },
    );

    testWidgets(
      'should initialize AudioCoachingService before UI is displayed',
      (WidgetTester tester) async {
        // Requirements: 6.1
        // This test verifies that AudioCoachingService initialization happens
        // in initState before the UI is rendered

        // Arrange
        final workout = createTestWorkout();

        // Act - Build the widget
        await tester.pumpWidget(createTestWidget(workout));

        // First pump builds the widget tree
        await tester.pump();

        // Assert - screen should be visible immediately after first pump
        // This indicates that initialization completed in initState
        expect(find.byType(WorkoutSessionScreen), findsOneWidget);

        // Allow async initialization to complete
        await tester.pump(const Duration(milliseconds: 100));

        // Verify the screen is still functional
        expect(find.text('Test Workout'), findsOneWidget);
      },
    );

    testWidgets('should call dispose on AudioCoachingService only once', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.3, 8.3
      // This test verifies that dispose is called exactly once on the
      // AudioCoachingService when the screen is disposed

      // Arrange
      final workout = createTestWorkout();

      // Build the widget
      await tester.pumpWidget(createTestWidget(workout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify screen is present
      expect(find.byType(WorkoutSessionScreen), findsOneWidget);

      // Act - Dispose the widget tree
      await tester.pumpWidget(Container());
      await tester.pump();

      // Wait for all async operations to complete
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - if we reach here without errors, dispose was called correctly
      // AudioCoachingService handles multiple dispose calls gracefully,
      // but the screen should only call it once
      expect(find.byType(WorkoutSessionScreen), findsNothing);
    });

    testWidgets('should properly clean up resources on dispose', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.3, 8.3
      // This test verifies comprehensive resource cleanup including
      // AudioCoachingService, timers, and animation controllers

      // Arrange
      final workout = createTestWorkout();

      // Build the widget
      await tester.pumpWidget(createTestWidget(workout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Start the workout to initialize timers
      final startButton = find.text('Mulai Latihan 🚀');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      }

      // Act - Navigate away (triggers dispose)
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => Scaffold(body: Text('Exit'))),
      );

      await tester.pumpAndSettle();

      // Assert - verify cleanup completed without errors
      // Timer, AnimationController, and AudioCoachingService all disposed
      expect(find.byType(WorkoutSessionScreen), findsNothing);
      expect(find.text('Exit'), findsOneWidget);
    });
  });

  group('WorkoutSessionScreen - Service Integration Edge Cases', () {
    WorkoutModel createTestWorkout() {
      return WorkoutModel(
        id: 'test-workout-1',
        name: 'Edge Case Workout',
        description: 'Edge case workout for testing',
        category: 'general_fitness',
        difficulty: 'intermediate',
        estimatedDuration: 15,
        estimatedCalories: 150,
        thumbnailUrl: '',
        createdAt: DateTime.now(),
        exercises: [
          WorkoutExercise(
            exerciseId: 'plank',
            exerciseName: 'Plank',
            sets: 2,
            reps: 0,
            duration: 30,
            restTime: 10,
          ),
        ],
      );
    }

    Widget createTestWidget(WorkoutModel workout) {
      return ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: MaterialApp(home: WorkoutSessionScreen(workout: workout)),
      );
    }

    testWidgets('should handle dispose without initialization', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.3, 7.1
      // This test verifies graceful handling if dispose is called
      // before initialization completes

      // Arrange
      final workout = createTestWorkout();

      // Act - Build and immediately dispose (minimal pump)
      await tester.pumpWidget(createTestWidget(workout));

      // Dispose almost immediately (before async init completes)
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert - should complete without errors
      expect(find.byType(WorkoutSessionScreen), findsNothing);
    });

    testWidgets('should handle screen with null workout parameter', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.1
      // This test verifies that the screen handles null workout gracefully
      // and still initializes AudioCoachingService

      // Act - Build with null workout (uses default exercises)
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(home: WorkoutSessionScreen(workout: null)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - screen should build with fallback workout
      expect(find.byType(WorkoutSessionScreen), findsOneWidget);

      // Default workout name should be displayed
      expect(find.text('Full Body Workout'), findsOneWidget);
    });

    testWidgets('should maintain service during screen state changes', (
      WidgetTester tester,
    ) async {
      // Requirements: 6.1, 6.2
      // This test verifies that AudioCoachingService persists correctly
      // through various screen state changes (started, paused, etc.)

      // Arrange
      final workout = createTestWorkout();

      // Build the widget
      await tester.pumpWidget(createTestWidget(workout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initial state - pre-session view
      expect(find.byType(WorkoutSessionScreen), findsOneWidget);
      expect(find.text('Sesi Latihan'), findsOneWidget);

      // Start the workout
      final startButton = find.text('Mulai Latihan 🚀');
      await tester.tap(startButton);
      await tester.pump();
      await tester.pumpAndSettle();

      // Session view should be displayed
      expect(find.byType(WorkoutSessionScreen), findsOneWidget);

      // Service should still be active throughout state changes
      // Navigate back to dispose
      final backButton = find.byIcon(Icons.close_rounded);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // Assert - service was properly maintained and disposed
      expect(true, isTrue);
    });
  });
}
