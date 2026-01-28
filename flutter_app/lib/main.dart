import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    debugPrint('DEBUG: Attempting to initialize Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));

    debugPrint('DEBUG: Firebase initialized successfully');
  } catch (e) {
    debugPrint('DEBUG: Firebase initialization failed/timed out: $e');
  }
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Finesight AI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.primaryColor,
          primary: themeProvider.primaryColor,
          surface: const Color(0xFFF8FAFC),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.primaryColor,
          primary: themeProvider.primaryColor,
          surface: const Color(0xFF0F172A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF020617),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
          color: const Color(0xFF0F172A),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isAuthLoading = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Home',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Finance',
    'Travel',
    'Personal',
    'Pets',
    'Bills',
    'Family',
    'Charity',
    'Other',
  ];

  void _addCategory(String category) {
    if (!_categories.contains(category)) {
      setState(() {
        _categories.add(category);
      });
    }
  }

  Future<void> _login() async {
    setState(() => _isAuthLoading = true);
    try {
      await _authService.loginWithGoogle();
    } catch (e) {
      debugPrint("Login Failed: $e");
    } finally {
      if (mounted) setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isAuthLoading = true);
    try {
      await _authService.loginAsGuest();
    } catch (e) {
      debugPrint("Guest Login Failed: $e");
    } finally {
      if (mounted) setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      if (_authService.currentUser != null) {
        await _authService.logout();
      }
    } catch (e) {
      debugPrint("Logout Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return MainScreen(
            user: snapshot.data,
            onLogout: _logout,
            categories: _categories,
            onAddCategory: _addCategory,
          );
        }
        return LoginScreen(
          onLogin: _login,
          onGuestLogin: _loginAsGuest,
          isLoading: _isAuthLoading,
        );
      },
    );
  }
}
