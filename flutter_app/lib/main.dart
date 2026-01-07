import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/expense.dart';
import 'models/payment.dart';
import 'models/income.dart';
import 'models/user_model.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/history_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('DEBUG: Attempting to initialize Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('DEBUG: Firebase initialized successfully');
    print('DEBUG: Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  } catch (e) {
    print('DEBUG: Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = true;
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isAuthLoading = false;

  List<String> _categories = [
    'Food', 'Transport', 'Utilities', 'Entertainment', 'Shopping', 
    'Health', 'Education', 'Groceries', 'Rent', 'Investments', 'Travel', 'Other'
  ];

  void _addCategory(String category) {
    if (!_categories.contains(category)) {
      setState(() {
        _categories.add(category);
      });
    }
  }

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  Future<void> _login() async {
    setState(() => _isAuthLoading = true);
    try {
      await _authService.loginWithGoogle();
      if (_authService.currentUser != null) {
        setState(() => _isLoggedIn = true);
      }
    } catch (e) {
       print("Login Failed: $e");
    } finally {
      // Check if mounted before calling setState in async gaps if needed, 
      // but strictly following current style
      setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isAuthLoading = true);
    try {
       await _authService.loginAsGuest();
        if (_authService.currentUser != null) {
        setState(() => _isLoggedIn = true);
      }
    } catch (e) {
      print("Guest Login Failed: $e");
    } finally {
      setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _logout() async {
     try {
      if (_authService.currentUser != null) {
        await _authService.logout();
      }
      setState(() => _isLoggedIn = false);
    } catch (e) {
      print("Logout Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009B6E), // Teal
          primary: const Color(0xFF009B6E),
          secondary: const Color(0xFF00E5A7), // Brighter teal/cyan accent
          error: const Color(0xFFE74C3C),
          surface: const Color(0xFFF5F7FA), // Light Surface
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009B6E),
          primary: const Color(0xFF009B6E),
          secondary: const Color(0xFF00E5A7),
          surface: const Color(0xFF1E2028), // Dark Navy Surface
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1E2028),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<UserModel?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return MainScreen(
              toggleTheme: toggleTheme, 
              isDark: isDark, 
              user: snapshot.data, 
              onLogout: _logout,
              categories: _categories,
              onAddCategory: _addCategory,
            );
          }
          return LoginScreen(onLogin: _login, onGuestLogin: _loginAsGuest, isLoading: _isAuthLoading);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;
  final UserModel? user;
  final VoidCallback onLogout;
  final List<String> categories;
  final Function(String) onAddCategory;

  const MainScreen({
    super.key, 
    required this.toggleTheme, 
    required this.isDark,
    required this.user,
    required this.onLogout,
    required this.categories,
    required this.onAddCategory,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Expense> _expenses = [];
  List<Payment> _payments = [];
  List<Income> _incomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = widget.user?.uid ?? '';
      final expenses = await ApiService.getExpenses(userId);
      final payments = await ApiService.getPayments(userId);
      final incomes = await ApiService.getIncomes(userId);
      setState(() {
        _expenses = expenses;
        _payments = payments;
        _incomes = incomes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  Future<void> _addIncome(Income income) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.addIncome(income, userId);
      await _loadData();
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add income: $e')),
      );
    }
  }

  Future<void> _addExpense(Expense expense) async {
    try {
      final userId = widget.user?.uid ?? '';
      print('DEBUG: Calling addExpense with userId: "$userId"');
      await ApiService.addExpense(expense, userId);
      await _loadData();
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.deleteExpense(id, userId);
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense: $e')),
      );
    }
  }

  Future<void> _addPayment(Payment payment) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.addPayment(payment, userId);
      await _loadData();
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add payment: $e')),
      );
    }
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          user: widget.user, 
          onLogout: widget.onLogout, 
          onThemeToggle: widget.toggleTheme, 
          isDark: widget.isDark,
          categories: widget.categories,
          onAddCategory: widget.onAddCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> _screens = [
      DashboardScreen(
        expenses: _expenses,
        payments: _payments,
        incomes: _incomes,
        isDark: widget.isDark,
      ),

      PaymentsScreen(
        payments: _payments,
        onAdd: _addPayment,
        isDark: widget.isDark,
      ),
      
      HistoryScreen(
        expenses: _expenses,
        payments: _payments,
        isDark: widget.isDark,
      ),
      
      AIScreen(
        expenses: _expenses,
        isDark: widget.isDark,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _navigateToProfile,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                backgroundImage: widget.user?.pictureUrl != null
                  ? NetworkImage(widget.user!.pictureUrl.toString())
                  : null,
                child: widget.user?.pictureUrl == null
                  ? const Icon(LucideIcons.user, size: 20, color: Colors.green)
                  : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: widget.isDark
                ? const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF065F46)], // Darker greens for dark mode
                  )
                : const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)], // Emerald to Dark Green
                  ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
          decoration: BoxDecoration(
             color: widget.isDark ? const Color(0xFF020617) : const Color(0xFFF5F7FA),
             gradient: null
          ),
          child: _screens[_selectedIndex]
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ExpensesScreen(
                    expenses: _expenses,
                    onAdd: _addExpense,
                    onAddIncome: _addIncome,
                    onDelete: _deleteExpense,
                    isDark: widget.isDark,
                    categories: widget.categories,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF27AE60),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.creditCard),
            label: 'Pay',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.messageSquare),
            label: 'AI',
          ),
        ],
      ),
    );
  }
}
