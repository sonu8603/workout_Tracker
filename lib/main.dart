
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/login_sign_up/welcome_screen.dart';
import 'Navigation_Controll/navigation_controll.dart';
import 'models/individual_set.dart';
import 'models/individual_exercise_model.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'models/workout_day.dart';
import 'models/workout_log_model.dart';
import 'Providers/Excercise_provider.dart';
import 'Providers/auth_provider.dart';

// 🔥 CHANGED: Updated HiveConfig for user-specific boxes
class HiveConfig {
  // Shared box (for auth only)
  static const String authBox = 'auth_data';

  // 🔥 NEW: User-specific box name generators
  static String workoutDaysBox(String userId) => '${userId}_workouts';
  static String extraExercisesBox(String userId) => '${userId}_extras';
  static String settingsBox(String userId) => '${userId}_settings';
  static String workoutLogsBox(String userId) => '${userId}_logs';
  static String metaBox(String userId) => '${userId}_meta';

  // Adapter IDs (unchanged)
  static const int exerciseSetAdapterId = 1;
  static const int exerciseAdapterId = 3;
  static const int workoutDayAdapterId = 4;
  static const int completedExerciseAdapterId = 5;
  static const int workoutLogAdapterId = 6;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeHive();

  runApp(const MyApp());
}

// 🔥 CHANGED: Only open auth box on app start
Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(HiveConfig.exerciseSetAdapterId)) {
      Hive.registerAdapter(ExerciseSetAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConfig.exerciseAdapterId)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConfig.workoutDayAdapterId)) {
      Hive.registerAdapter(WorkoutDayAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConfig.completedExerciseAdapterId)) {
      Hive.registerAdapter(CompletedExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConfig.workoutLogAdapterId)) {
      Hive.registerAdapter(WorkoutLogAdapter());
    }

    // 🔥 CHANGED: Only open auth box here
    // User-specific boxes will be opened after login by ExerciseProvider
    await Hive.openBox(HiveConfig.authBox);

    debugPrint('✅ Hive initialized (auth box only)');
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Hive: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
      ],
      child: MaterialApp(
        title: 'FitMetrics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AppEntryPoint(),
      ),
    );
  }
}

// 🔥 CHANGED: Better initialization logic
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ExerciseProvider>(
      builder: (context, auth, exercise, child) {
        // Show splash while auth is loading
        if (auth.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox.shrink(),
          );
        }

        // If logged in but exercise provider not initialized
        if (auth.isLoggedIn && !exercise.isInitialized) {
          // 🔥 NEW: Initialize exercise provider with userId
          final userId = auth.userId;
          if (userId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              exercise.initializeForUser(userId);
            });
          }

          // Show loading while initializing
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox.shrink(),
          );
        }

        FlutterNativeSplash.remove();

        // Show appropriate screen
        if (auth.isLoggedIn && exercise.isInitialized) {
          return const NavigationRoutePage();
        }

        return const WelcomeScreen();
      },
    );
  }
}