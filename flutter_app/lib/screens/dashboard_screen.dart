import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/currency_helper.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/income.dart';
import '../models/user_model.dart'; // Needed for passing widget.user to AnalyticsScreen? Use widget.widget.user if available but DashboardScreen is stateless without user.
import 'analytics_screen.dart';
import '../services/api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Trying to access widget.user?
// DashboardScreen receives data, but AnalyticsScreen needs userId.
// Dashboard currently doesn't have widget.user object passed to it, only data.
// MainScreen has user.
// I need to update DashboardScreen to accept widget.user object or pass userId.

class DashboardScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Payment> payments;
  final List<Income> incomes;
  final bool isDark;
  final UserModel? user;

  const DashboardScreen({
    super.key,
    required this.expenses,
    required this.payments,
    required this.incomes,
    required this.isDark,
    required this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _aiTip;
  bool _isLoadingTip = true;

  @override
  void initState() {
    super.initState();
    _fetchAITip();
  }

  Future<void> _fetchAITip() async {
    try {
      // Create expense summary for context
      final totalSpent = widget.expenses.fold(0.0, (sum, e) => sum + e.amount);
      final categories = <String, double>{};
      for (var e in widget.expenses) {
        categories[e.category] = (categories[e.category] ?? 0) + e.amount;
      }
      final topCategory = categories.entries.isEmpty
          ? 'None'
          : categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final context = [
        {
          'role': 'system',
          'content':
              'User spent \$${totalSpent.toStringAsFixed(2)} total. Top category: $topCategory.',
        },
      ];

      final tip = await ApiService.chatWithAI(
        'Give me ONE short, actionable financial tip (max 2 sentences) based on my spending. Be specific and helpful.',
        context,
        widget.user?.uid ?? '',
      );

      if (mounted) {
        setState(() {
          _aiTip = tip;
          _isLoadingTip = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTip =
              'Track your daily expenses to identify savings opportunities!';
          _isLoadingTip = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = widget.expenses.fold(
      0.0,
      (sum, exp) => sum + exp.amount,
    );

    final now = DateTime.now();
    final thisMonthExpenses = widget.expenses.where((exp) {
      return exp.date.month == now.month && exp.date.year == now.year;
    });
    final monthTotal = thisMonthExpenses.fold(
      0.0,
      (sum, exp) => sum + exp.amount,
    );

    final successfulPayments = widget.payments
        .where((p) => p.status == 'success')
        .toList();
    final totalPaymentsValue = successfulPayments.fold(
      0.0,
      (sum, p) => sum + p.amount,
    );

    final upiExpenses = widget.expenses
        .where((e) => e.paymentMethod.toUpperCase() == 'UPI')
        .toList();
    final totalDigitalSpent = upiExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final totalIncomes = widget.incomes.fold(
      0.0,
      (sum, inc) => sum + inc.amount,
    );
    final grandTotalIncome = totalPaymentsValue + totalIncomes;

    // Calculate Category Totals
    final categoryTotals = <String, double>{};
    for (var exp in widget.expenses) {
      categoryTotals[exp.category] =
          (categoryTotals[exp.category] ?? 0) + exp.amount;
    }

    // Removed local formatter

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Slogan
          Text(
            "Understand your spending.",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),

          // AI Tip Card
          Card(
            elevation: 2,
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.lightbulb,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Tip',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _isLoadingTip
                            ? Text(
                                'Getting personalized tip...',
                                style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Text(
                                _aiTip ?? 'Track your expenses daily!',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 16),

          // Balance Card
          Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Balance',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyHelper.format(grandTotalIncome - totalExpenses),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.arrowUpRight,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Income',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyHelper.format(grandTotalIncome),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.arrowDownRight,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'expenses',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyHelper.format(totalExpenses),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  color: widget.isDark
                      ? const Color(0xFF0F172A)
                      : Colors.white, // slate-900
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.red],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.trendingDown,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This Month',
                          style: TextStyle(
                            color: widget.isDark
                                ? Colors.grey
                                : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          CurrencyHelper.format(monthTotal),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.green, Colors.teal],
                            ), // emerald equivalent
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.creditCard,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Sent',
                          style: TextStyle(
                            color: widget.isDark
                                ? Colors.grey
                                : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          CurrencyHelper.format(totalDigitalSpent),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

          const SizedBox(height: 16),

          // Spending Breakdown (Pie Chart)
          Card(
            color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnalyticsScreen(
                      user: widget.user,
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.pieChart,
                          color: widget.isDark
                              ? Colors.green.shade300
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Spending Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (widget.expenses.isEmpty)
                      const Center(child: Text('No expenses to show'))
                    else
                      SizedBox(
                        height: 120, // Reduced height
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 35,
                                    sections: categoryTotals.entries.map((
                                      entry,
                                    ) {
                                      final percentage =
                                          (entry.value / totalExpenses) * 100;
                                      final colors = _getCategoryGradients(
                                        entry.key,
                                      );
                                      return PieChartSectionData(
                                        gradient: LinearGradient(
                                          colors: colors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        value: entry.value,
                                        title:
                                            '${percentage.toStringAsFixed(0)}%',
                                        radius: 30, // Slightly bigger
                                        showTitle: percentage > 10,
                                        titleStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: categoryTotals.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getCategoryIcon(entry.key),
                                          size: 14,
                                          color: _getCategoryColor(entry.key),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: widget.isDark
                                                  ? Colors.grey.shade300
                                                  : Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          CurrencyHelper.format(entry.value),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

          const SizedBox(height: 80), // Bottom padding for FAB/Nav
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return LucideIcons.utensils;
      case 'transport':
        return LucideIcons.bus;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'bills':
        return LucideIcons.receipt;
      case 'entertainment':
        return LucideIcons.film;
      case 'health':
        return LucideIcons.heartPulse;
      case 'education':
        return LucideIcons.graduationCap;
      case 'groceries':
        return LucideIcons.shoppingCart;
      case 'rent':
        return LucideIcons.home;
      case 'utilities':
        return LucideIcons.zap;
      default:
        return LucideIcons.tag;
    }
  }

  Color _getCategoryColor(String category) {
    return _getCategoryGradients(category)[0];
  }

  List<Color> _getCategoryGradients(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return [const Color(0xFFF97316), const Color(0xFFFB923C)]; // Orange
      case 'transport':
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]; // Blue
      case 'shopping':
        return [const Color(0xFFEF4444), const Color(0xFFF87171)]; // Red
      case 'bills':
        return [const Color(0xFF6366F1), const Color(0xFF818CF8)]; // Indigo
      case 'entertainment':
        return [const Color(0xFFEC4899), const Color(0xFFF472B6)]; // Pink
      case 'health':
        return [const Color(0xFF14B8A6), const Color(0xFF2DD4BF)]; // Teal
      case 'education':
        return [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)]; // Violet
      case 'groceries':
        return [const Color(0xFF10B981), const Color(0xFF34D399)]; // Green
      case 'rent':
        return [const Color(0xFF78350F), const Color(0xFF92400E)]; // Brown
      case 'utilities':
        return [const Color(0xFF06B6D4), const Color(0xFF22D3EE)]; // Cyan
      case 'travel':
        return [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)]; // Sky
      case 'investments':
        return [const Color(0xFF84CC16), const Color(0xFFA3E635)]; // Lime
      case 'other':
        return [const Color(0xFF64748B), const Color(0xFF94A3B8)]; // Gray
      default:
        // Use a deterministic color pair based on hash
        final index = category.hashCode % Colors.primaries.length;
        final color = Colors.primaries[index];
        return [color, color.withValues(alpha: 0.7)];
    }
  }
}
