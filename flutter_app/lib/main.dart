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
import 'screens/budget_screen.dart';
import 'screens/recurring_screen.dart';
import 'screens/export_screen.dart';
import 'screens/split_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/currency_screen.dart';
import 'screens/reminder_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    debugPrint('DEBUG: Attempting to initialize Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('DEBUG: Firebase initialized successfully');
    debugPrint(
      'DEBUG: Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}',
    );
  } catch (e) {
    debugPrint('DEBUG: Firebase initialization failed: $e');
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
  bool _isAuthLoading = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Health',
    'Education',
    'Groceries',
    'Rent',
    'Investments',
    'Travel',
    'Other',
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
        // Logged in
      }
    } catch (e) {
      debugPrint("Login Failed: $e");
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
        // Logged in
      }
    } catch (e) {
      debugPrint("Guest Login Failed: $e");
    } finally {
      setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      if (_authService.currentUser != null) {
        await _authService.logout();
      }
      // Logged out
    } catch (e) {
      debugPrint("Logout Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Modern Emerald
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF34D399),
          tertiary: const Color(0xFF6366F1), // Indigo accent for variation
          error: const Color(0xFFEF4444),
          surface: const Color(0xFFF8FAFC), // Slate-50
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
          seedColor: const Color(0xFF10B981),
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF34D399),
          tertiary: const Color(0xFF818CF8),
          surface: const Color(0xFF0F172A), // Slate-900
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
          return LoginScreen(
            onLogin: _login,
            onGuestLogin: _loginAsGuest,
            isLoading: _isAuthLoading,
          );
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  Future<void> _addIncome(Income income) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.addIncome(income, userId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add income: $e')));
      }
    }
  }

  Future<void> _addExpense(Expense expense) async {
    try {
      final userId = widget.user?.uid ?? '';
      debugPrint('DEBUG: Calling addExpense with userId: "$userId"');
      await ApiService.addExpense(expense, userId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add expense: $e')));
      }
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.deleteExpense(id, userId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete expense: $e')));
      }
    }
  }

  Future<void> _addPayment(Payment payment) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.addPayment(payment, userId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add payment: $e')));
      }
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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> screens = [
      DashboardScreen(
        expenses: _expenses,
        payments: _payments,
        incomes: _incomes,
        isDark: widget.isDark,
        user: widget.user,
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

      AIScreen(expenses: _expenses, isDark: widget.isDark),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? LucideIcons.sun : LucideIcons.moon),
            color: widget.isDark ? Colors.white : Colors.black,
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell),
            color: widget.isDark ? Colors.white : Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReminderScreen(user: widget.user, isDark: widget.isDark),
                ),
              );
            },
          ),
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
                    ? const Icon(
                        LucideIcons.user,
                        size: 20,
                        color: Color(0xFF10B981),
                      )
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
                    colors: [
                      Color(0xFF064E3B),
                      Color(0xFF065F46),
                    ], // Darker greens for dark mode
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF34D399),
                    ], // Emerald to lighter teal
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
        ),

        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: widget.isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
              ),
              accountName: Text(
                widget.user?.name ?? 'User',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                widget.user?.email ?? '',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: widget.user?.pictureUrl != null
                    ? NetworkImage(widget.user!.pictureUrl!)
                    : null,
                child: widget.user?.pictureUrl == null
                    ? const Icon(LucideIcons.user, color: Colors.green)
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(
                LucideIcons.wallet,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Monthly Budgets',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BudgetScreen(
                      user: widget.user,
                      categories: widget.categories,
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.repeat,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Recurring Expenses',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecurringScreen(
                      user: widget.user,
                      categories: widget.categories,
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.downloadCloud,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Export Data',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ExportScreen(user: widget.user, isDark: widget.isDark),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.users,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Split Expenses',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SplitScreen(user: widget.user, isDark: widget.isDark),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.scanLine,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Receipt Scanner',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ScannerScreen(user: widget.user, isDark: widget.isDark),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.target,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Goals & Savings',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GoalsScreen(user: widget.user, isDark: widget.isDark),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.arrowRightLeft,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Currency Converter',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurrencyScreen(
                      user: widget.user,
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                LucideIcons.bell,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Notifications',
                style: GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReminderScreen(
                      user: widget.user,
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            // Placeholder for other features
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color(0xFF020617)
              : const Color(0xFFF5F7FA),
          gradient: null,
        ),
        child: screens[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
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
