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

import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'payments_screen.dart';
import 'history_screen.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';
import 'budget_screen.dart';
import 'recurring_screen.dart';
import 'export_screen.dart';
import 'split_screen.dart';
import 'scanner_screen.dart';
import 'goals_screen.dart';
import 'currency_screen.dart';
import 'reminder_screen.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = widget.user?.uid ?? '';
      final expenses = await ApiService.getExpenses(userId);
      final payments = await ApiService.getPayments(userId);
      final incomes = await ApiService.getIncomes(userId);

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

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          user: widget.user,
          onLogout: widget.onLogout,
          categories: widget.categories,
          onAddCategory: widget.onAddCategory,
        ),
      ),
    );
  }

  void _showAddMenu() {
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
                color: const Color(0xFF10B981),
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

      HistoryScreen(expenses: _expenses, payments: _payments, isDark: isDark),

      AIScreen(
        expenses: _expenses,
        isDark: isDark,
        user: widget.user,
        onDataChanged: _loadData,
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
            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon),
            color: isDark ? Colors.white : Colors.black,
            onPressed: themeProvider.toggleTheme,
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
        backgroundColor: const Color(0xFF009B6E),
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
                      ? const Color(0xFF009B6E)
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 0),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.creditCard,
                  color: _selectedIndex == 1
                      ? const Color(0xFF009B6E)
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 1),
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: Icon(
                  LucideIcons.history,
                  color: _selectedIndex == 2
                      ? const Color(0xFF009B6E)
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 2),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.messageSquare,
                  color: _selectedIndex == 3
                      ? const Color(0xFF009B6E)
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
                ? const Icon(LucideIcons.user, color: Colors.green)
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
            LucideIcons.arrowRightLeft,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Currency Converter',
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
                    CurrencyScreen(user: widget.user, isDark: isDark),
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
