import 'package:flutter/foundation.dart';
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
import 'Providers/Excercise_provider.dart';
import 'Providers/auth_provider.dart';

class HiveConfig {
  static const String workoutDaysBox = 'workout_days';
  static const String extraExercisesBox = 'extra_exercises';
  static const String settingsBox = 'settings';
  static const String authBox = 'auth_data';

  static const int exerciseSetAdapterId = 1;
  static const int exerciseAdapterId = 3;
  static const int workoutDayAdapterId = 4;
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

/// Only initializes Hive - no UI logic here
Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HiveConfig.exerciseSetAdapterId)) {
      Hive.registerAdapter(ExerciseSetAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConfig.exerciseAdapterId)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConfig.workoutDayAdapterId)) {
      Hive.registerAdapter(WorkoutDayAdapter());
    }

    await Future.wait([
      Hive.openBox<WorkoutDay>(HiveConfig.workoutDaysBox),
      Hive.openBox(HiveConfig.extraExercisesBox),
      Hive.openBox(HiveConfig.settingsBox),
      Hive.openBox(HiveConfig.authBox),
    ]);

    debugPrint('✅ Hive initialized successfully');
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
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
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

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ExerciseProvider>(
      builder: (context, auth, exercise, child) {
        if (auth.isLoading || !exercise.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox.shrink(),
          );
        }

        FlutterNativeSplash.remove();

        if (auth.isLoggedIn) {
          return const NavigationRoutePage();
        }

        return const WelcomeScreen();
      },
    );
  }
}
