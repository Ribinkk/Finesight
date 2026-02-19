import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/income.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import '../utils/currency_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'payments_screen.dart';
import 'history_screen.dart';

import 'profile_screen.dart';
import 'budget_screen.dart';
import 'recurring_screen.dart';
import 'export_screen.dart';
import 'split_screen.dart';
import 'scanner_screen.dart';
import 'goals_screen.dart';
import 'reminder_screen.dart';
import 'settings_screen.dart';
import '../widgets/ai_bot_widget.dart';

class MainScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onLogout;
  final List<String> categories;
  final Function(String) onAddCategory;

  const MainScreen({
    super.key,
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
    _initCurrencyAndLoadData();
  }

  Future<void> _initCurrencyAndLoadData() async {
    await CurrencyHelper.init(); // Load saved currency

    // Check if currency is set (we can check if it's default 'INR' and maybe ask?
    // Or just always ask once if we had a flag.
    // For now, let's checking SharedPreferences directly to see if it was ever set.
    // But CurrencyHelper.init() already hides that logic.
    // Let's modify init to return if it was loaded or default.
    // Or just check here:

    // Actually, asking the user "after account creation" implies we should ask
    // if it's their first time. Since I can't easily detect "first time after signup"
    // without more complex state or passing flags, I will just check if
    // SharedPreferences has the key 'currency'. If not, show dialog.

    final prefs = await SharedPreferences.getInstance();
    final hasSetCurrency = prefs.containsKey('currency');

    if (!hasSetCurrency && mounted) {
      // Short delay to let build finish or just show after
      Future.delayed(Duration.zero, () => _showCurrencyDialog());
    }

    _loadData();
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force selection
      builder: (ctx) => AlertDialog(
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        title: Text(
          'Select your Currency',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white
                : Colors.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: CurrencyHelper.symbols.length,
            itemBuilder: (context, index) {
              final code = CurrencyHelper.symbols.keys.elementAt(index);
              final symbol = CurrencyHelper.symbols[code]!;
              return ListTile(
                leading: Text(symbol, style: const TextStyle(fontSize: 20)),
                title: Text(code),
                onTap: () async {
                  await CurrencyHelper.setCurrency(code);
                  if (mounted && context.mounted) {
                    setState(() {}); // Rebuild to update UI
                    Navigator.of(ctx).pop();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = widget.user?.uid ?? '';

      // Parallelize API calls
      final results = await Future.wait([
        ApiService.getExpenses(userId),
        ApiService.getPayments(userId),
        ApiService.getIncomes(userId),
      ]);

      final expenses = results[0] as List<Expense>;
      final payments = results[1] as List<Payment>;
      final incomes = results[2] as List<Income>;

      if (mounted) {
        setState(() {
          _expenses = expenses;
          _payments = payments;
          _incomes = incomes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Failed to load data: $e');
        // Optional: Show snackbar, but debugPrint is less intrusive on boot if it's just a minor glitch
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

  Future<void> _updateExpense(Expense expense) async {
    try {
      final userId = widget.user?.uid ?? '';
      await ApiService.updateExpense(expense, userId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update expense: $e')));
      }
    }
  }

  void _navigateToEditExpense(Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExpensesScreen(
          expenses: _expenses,
          onAdd: _addExpense,
          onAddIncome: _addIncome,
          onDelete: _deleteExpense,
          onEdit: _updateExpense,
          expenseToEdit: expense,
          isDark: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
          categories: widget.categories,
        ),
      ),
    );
  }

  void _showAddMenu() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuButton(
                context,
                title: 'Income',
                icon: LucideIcons.arrowDownCircle,
                color: themeProvider.primaryColor,
                onTap: () => _navigateToAddWithType('Income'),
              ),
              _buildMenuButton(
                context,
                title: 'Transfer',
                icon: LucideIcons.arrowRightLeft,
                color: const Color(0xFF3B82F6),
                onTap: () => _navigateToAddWithType('Transfer'),
              ),
              _buildMenuButton(
                context,
                title: 'Expense',
                icon: LucideIcons.arrowUpCircle,
                color: const Color(0xFFEF4444),
                onTap: () => _navigateToAddWithType('Expense'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddWithType(String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExpensesScreen(
          expenses: _expenses,
          onAdd: _addExpense,
          onAddIncome: _addIncome,
          onDelete: _deleteExpense,
          isDark: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
          categories: widget.categories,
          initialType: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final totalExpenses = _expenses.fold(0.0, (sum, exp) => sum + exp.amount);
    final totalPayments = _payments.fold(
      0.0,
      (sum, p) => sum + (p.status == 'success' ? p.amount : 0),
    );
    final totalIncomes = _incomes.fold(0.0, (sum, inc) => sum + inc.amount);
    final currentBalance = (totalPayments + totalIncomes) - totalExpenses;

    final List<Widget> screens = [
      DashboardScreen(
        expenses: _expenses,
        payments: _payments,
        incomes: _incomes,
        isDark: isDark,
        user: widget.user,
      ),

      PaymentsScreen(
        user: widget.user,
        isDark: isDark,
        payments: _payments,
        expenses: _expenses,
        onAdd: _addPayment,
        onAddExpense: _addExpense,
        categories: widget.categories,
        currentBalance: currentBalance,
      ),

      HistoryScreen(
        expenses: _expenses,
        payments: _payments,
        isDark: isDark,
        onEditExpense: _navigateToEditExpense,
        onDeleteExpense: _deleteExpense,
      ),

      ProfileScreen(
        user: widget.user,
        onLogout: widget.onLogout,
        categories: widget.categories,
        onAddCategory: widget.onAddCategory,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Dashboard'
              : _selectedIndex == 1
              ? 'Payments'
              : _selectedIndex == 2
              ? 'History'
              : 'Profile',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon),
            color: isDark ? Colors.white : Colors.black,
            onPressed: themeProvider.toggleTheme,
          ),
          if (_selectedIndex == 3) // Profile Tab
            IconButton(
              icon: const Icon(LucideIcons.settings),
              color: isDark ? Colors.white : Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(user: widget.user),
                  ),
                );
              },
            ),
          const SizedBox(width: 16),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      themeProvider.primaryColor.withValues(alpha: 0.8),
                      themeProvider.primaryColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      themeProvider.primaryColor,
                      themeProvider.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
        ),

        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: _buildDrawerContent(context, isDark, themeProvider),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF020617) : const Color(0xFFF5F7FA),
              gradient: null,
            ),
            child: screens[_selectedIndex],
          ),
          AIBotWidget(user: widget.user, isDark: isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: themeProvider.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.home,
                  color: _selectedIndex == 0
                      ? themeProvider.primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 0),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.creditCard,
                  color: _selectedIndex == 1
                      ? themeProvider.primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 1),
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: Icon(
                  LucideIcons.history,
                  color: _selectedIndex == 2
                      ? themeProvider.primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 2),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.user,
                  color: _selectedIndex == 3
                      ? themeProvider.primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.primaryColor,
                themeProvider.primaryColor.withValues(alpha: 0.8),
              ],
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
                ? Icon(LucideIcons.user, color: themeProvider.primaryColor)
                : null,
          ),
        ),
        ListTile(
          leading: Icon(
            LucideIcons.wallet,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Monthly Budgets',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
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
                  isDark: isDark,
                ),
              ),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            LucideIcons.repeat,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Recurring Expenses',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
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
                  isDark: isDark,
                ),
              ),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            LucideIcons.downloadCloud,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Export Data',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExportScreen(user: widget.user, isDark: isDark),
              ),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            LucideIcons.users,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Split Expenses',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SplitScreen(user: widget.user, isDark: isDark),
              ),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            LucideIcons.scanLine,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Receipt Scanner',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ScannerScreen(user: widget.user, isDark: isDark),
              ),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            LucideIcons.target,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Goals & Savings',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalsScreen(user: widget.user, isDark: isDark),
              ),
            );
          },
        ),

        const Divider(height: 1),
        ListTile(
          leading: Icon(
            LucideIcons.bell,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Notifications',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReminderScreen(user: widget.user, isDark: isDark),
              ),
            );
          },
        ),
      ],
    );
  }
}
