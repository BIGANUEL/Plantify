import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection_container.dart' as di;
import 'core/utils/dark_mode_notifier.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/plants/presentation/bloc/plants_bloc.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const PlantifyApp());
}

class PlantifyApp extends StatefulWidget {
  const PlantifyApp({super.key});

  @override
  State<PlantifyApp> createState() => _PlantifyAppState();
}

// Global dark mode notifier
final darkModeNotifier = DarkModeNotifier();

class _PlantifyAppState extends State<PlantifyApp> {
  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    // Listen to dark mode changes
    darkModeNotifier.addListener(_onDarkModeChanged);
  }

  @override
  void dispose() {
    darkModeNotifier.removeListener(_onDarkModeChanged);
    super.dispose();
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('plantify_dark_mode') ?? false;
    darkModeNotifier.setDarkMode(isDarkMode);
  }

  void _onDarkModeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>()..add(const AuthInitialized()),
      child: ValueListenableBuilder<bool>(
        valueListenable: darkModeNotifier,
        builder: (context, isDarkMode, child) {
          return MaterialApp(
            title: 'Plantify',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: const Color(0xFF4CAF50), // Primary green
              scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Subtle off-white
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Inter', // Will fallback to system font if not available
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: const Color(0xFF4CAF50),
              scaffoldBackgroundColor: const Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'Inter',
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade800, width: 1),
                ),
              ),
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppNavigator(),
          );
        },
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  AppState _appState = AppState.loading;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasCompletedOnboarding = prefs.getBool('plantify_onboarding_complete') ?? false;

    if (kDebugMode) {
      debugPrint('([LOG debug_onboarding] ========= Forcing onboarding in debug mode)');
      hasCompletedOnboarding = false;
    }

    setState(() {
      if (hasCompletedOnboarding) {
        _appState = AppState.auth;
      } else {
        _appState = AppState.onboarding;
      }
    });
  }

  void _handleOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      debugPrint('([LOG debug_onboarding] ========= Skip persisting onboarding completion in debug mode)');
    } else {
      await prefs.setBool('plantify_onboarding_complete', true);
      debugPrint('([LOG onboarding_complete] ========= Persisted onboarding completion)');
    }
    setState(() {
      _appState = AppState.auth;
    });
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('plantify_onboarding_complete');
    if (!mounted) return;
    context.read<AuthBloc>().add(const LogoutRequested());
    debugPrint('([LOG handle_logout] ========= Cleared stored authentication data and onboarding status)');
    if (!mounted) return;
    setState(() {
      _userEmail = '';
      _appState = AppState.onboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() {
            _userEmail = state.user.email;
            _appState = AppState.dashboard;
          });
        }
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_appState == AppState.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_appState == AppState.onboarding) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }

    if (_appState == AppState.auth) {
      return const AuthPage();
    }

    return BlocProvider(
      create: (_) => di.sl<PlantsBloc>(),
      child: DashboardScreen(
        email: _userEmail,
        onLogout: _handleLogout,
      ),
    );
  }
}

enum AppState {
  loading,
  onboarding,
  auth,
  dashboard,
}
