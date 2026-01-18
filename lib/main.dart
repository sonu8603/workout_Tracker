import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/login_sign_up/welcome_screen.dart';
import 'models/individual_set.dart';
import 'models/individual_exercise_model.dart';
import 'models/workout_day.dart';
import 'Providers/Excercise_provider.dart';
import 'Providers/auth_provider.dart';

class HiveConfig {
  static const String workoutDaysBox = 'workout_days';
  static const String extraExercisesBox = 'extra_exercises';
  static const String settingsBox = 'settings';
  static const String authBox = 'auth_data'; // 🆕 Auth box

  static const int exerciseSetAdapterId = 1;
  static const int exerciseAdapterId = 3;
  static const int workoutDayAdapterId = 4;
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeHive();

  runApp(const MyApp());
}

/// Only initializes Hive - no data operations
Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(HiveConfig.exerciseSetAdapterId)) {
      Hive.registerAdapter(ExerciseSetAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveConfig.exerciseAdapterId)) {
      Hive.registerAdapter(ExerciseAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveConfig.workoutDayAdapterId)) {
      Hive.registerAdapter(WorkoutDayAdapter());
    }

    // Open all boxes including auth box
    await Future.wait([
      Hive.openBox<WorkoutDay>(HiveConfig.workoutDaysBox),
      Hive.openBox(HiveConfig.extraExercisesBox),
      Hive.openBox(HiveConfig.settingsBox),
      Hive.openBox(HiveConfig.authBox),
    ]);

    debugPrint('✅ Hive initialized successfully');
    debugPrint('📦 Auth box opened: ${Hive.isBoxOpen(HiveConfig.authBox)}');
  } catch (e, stackTrace) {
    debugPrint(' Error initializing Hive: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🆕 Use MultiProvider to provide both ExerciseProvider and AuthProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // 🆕 Add AuthProvider
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
        home: const AppInitializationWrapper(),
      ),
    );
  }
}

/// Proper state management with initState
class AppInitializationWrapper extends StatefulWidget {
  const AppInitializationWrapper({super.key});

  @override
  State<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends State<AppInitializationWrapper> {
  String? _errorMessage;
  bool _errorShown = false;

  @override
  void initState() {
    super.initState();
    // Check for errors after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForErrors();
    });
  }

  void _checkForErrors() {
    final provider = Provider.of<ExerciseProvider>(context, listen: false);

    if (provider.lastError != null && !_errorShown && mounted) {
      _errorShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warning: ${provider.lastError}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              provider.clearError();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const _LoadingScreen();
        }

        // Show error screen if critical error
        if (provider.lastError != null && provider.days.isEmpty) {
          return _ErrorScreen(
            error: provider.lastError!,
            onRetry: () {
              setState(() {
                _errorShown = false;
              });
              provider.clearError();
            },
          );
        }

        // App is ready - show welcome screen
        return const WelcomeScreen();
      },
    );
  }
}

/// Extracted loading screen widget
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading your workout data...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Proper error screen
class _ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  },
                  child: const Text('Continue Anyway'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}