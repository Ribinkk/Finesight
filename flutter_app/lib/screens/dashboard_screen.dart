import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/income.dart';

class DashboardScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<Payment> payments;
  final List<Income> incomes;
  final bool isDark;

  const DashboardScreen({
    super.key,
    required this.expenses,
    required this.payments,
    required this.incomes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpenses = expenses.fold(0.0, (sum, exp) => sum + exp.amount);
    
    final now = DateTime.now();
    final thisMonthExpenses = expenses.where((exp) {
      return exp.date.month == now.month && exp.date.year == now.year;
    });
    final monthTotal = thisMonthExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

    final successfulPayments = payments.where((p) => p.status == 'success').toList();
    final totalPayments = successfulPayments.fold(0.0, (sum, p) => sum + p.amount);
    
    final totalIncomes = incomes.fold(0.0, (sum, inc) => sum + inc.amount);
    final grandTotalIncome = totalPayments + totalIncomes;

    // Calculate Category Totals
    final categoryTotals = <String, double>{};
    for (var exp in expenses) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0) + exp.amount;
    }

    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3Categories = topCategories.take(3).toList();
    
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

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
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Balance Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                      ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.wallet, color: isDark ? Colors.green.shade200 : Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Available Balance',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.green.shade200 : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                     currencyFormatter.format(grandTotalIncome - totalExpenses),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: isDark ? Colors.green.shade800 : Colors.green.shade400),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                               children: [
                                 Icon(LucideIcons.arrowUpRight, color: Colors.white, size: 16),
                                 const SizedBox(width: 4),
                                 Text('Income', style: TextStyle(color: Colors.white)),
                               ],
                             ),
                            Text(
                              currencyFormatter.format(grandTotalIncome),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                                 Icon(LucideIcons.arrowDownRight, color: Colors.white, size: 16),
                                 const SizedBox(width: 4),
                                 Text('Expenses', style: TextStyle(color: Colors.white)),
                               ],
                             ),
                            Text(
                              currencyFormatter.format(totalExpenses),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                   color: isDark ? const Color(0xFF0F172A) : Colors.white, // slate-900
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.trendingDown, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text('This Month', style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600)),
                        Text(currencyFormatter.format(monthTotal), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                   color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.green, Colors.teal]), // emerald equivalent
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text('Payments', style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600)),
                        Text('${successfulPayments.length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Spending Breakdown (Pie Chart)
          Card(
             color: isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(LucideIcons.pieChart, color: isDark ? Colors.green.shade300 : Colors.green),
                      const SizedBox(width: 8),
                      Text('Spending Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (expenses.isEmpty)
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
                                  sections: categoryTotals.entries.map((entry) {
                                    final percentage = (entry.value / totalExpenses) * 100;
                                    final index = categoryTotals.keys.toList().indexOf(entry.key);
                                    return PieChartSectionData(
                                      color: _getCategoryColor(entry.key),
                                      value: entry.value,
                                      title: '${percentage.toStringAsFixed(0)}%',
                                      radius: 25, // Slightly bigger
                                      titleStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  centerSpaceRadius: 35, // Bigger center
                                  sectionsSpace: 2,
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
                                  final index = categoryTotals.keys.toList().indexOf(entry.key);
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
                                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                           currencyFormatter.format(entry.value),
                                           style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
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


          const SizedBox(height: 80), // Bottom padding for FAB/Nav
        ],
      ),
    );
  }


  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return LucideIcons.utensils;
      case 'transport': return LucideIcons.bus;
      case 'shopping': return LucideIcons.shoppingBag;
      case 'bills': return LucideIcons.receipt;
      case 'entertainment': return LucideIcons.film;
      case 'health': return LucideIcons.heartPulse;
      case 'education': return LucideIcons.graduationCap;
      case 'groceries': return LucideIcons.shoppingCart;
      case 'rent': return LucideIcons.home;
      case 'utilities': return LucideIcons.zap;
      default: return LucideIcons.tag;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'shopping': return Colors.red;
      case 'bills': return Colors.indigo;
      case 'entertainment': return Colors.pink;
      case 'health': return Colors.teal;
      case 'education': return Colors.greenAccent;
      case 'groceries': return Colors.green;
      case 'rent': return Colors.brown;
      case 'utilities': return Colors.teal;
      case 'travel': return Colors.lightBlue;
      case 'investments': return Colors.cyan;
      case 'other': return Colors.grey;
      default: 
        // Deterministic random color for unknown categories
        return Colors.primaries[category.hashCode % Colors.primaries.length];
    }
  }
}
