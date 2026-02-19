import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<Payment> payments;
  final bool isDark;
  final Function(Expense)? onEditExpense;
  final Function(String)? onDeleteExpense;

  const HistoryScreen({
    super.key,
    required this.expenses,
    required this.payments,
    required this.isDark,
    this.onEditExpense,
    this.onDeleteExpense,
  });

  @override
  Widget build(BuildContext context) {
    final combinedTransactions = _buildCombinedTransactions(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF020617) : const Color(0xFFF5F7FA),
        ),
        child: combinedTransactions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 64,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transaction history',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transactions will appear here',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children:
                    [
                          // Header
                          Row(
                            children: [
                              Icon(
                                LucideIcons.history,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Transaction History',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${combinedTransactions.length} transactions',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Transactions List
                          ...combinedTransactions.map((transaction) {
                            return _buildTransactionCard(context, transaction);
                          }),

                          const SizedBox(
                            height: 80,
                          ), // Bottom padding for nav bar
                        ]
                        .animate(interval: 50.ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.1),
              ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildCombinedTransactions(BuildContext context) {
    final List<Map<String, dynamic>> combinedTransactions = [];

    // Add expenses
    for (var expense in expenses) {
      combinedTransactions.add({
        'type': 'expense',
        'data': expense, // Store full object for editing
        'date': expense.date,
        'title': expense.title,
        'category': expense.category,
        'amount': expense.amount,
        'description': expense.description,
        'paymentMethod': expense.paymentMethod,
        'icon': _getCategoryIcon(expense.category),
        'color': _getCategoryColor(context, expense.category),
      });
    }

    // Add payments
    for (var payment in payments) {
      combinedTransactions.add({
        'type': 'payment',
        'data': payment,
        'date': payment.date,
        'title': payment.purpose,
        'category': payment.status == 'success' ? 'Successful' : 'Failed',
        'amount': payment.amount,
        'description': payment.razorpayOrderId ?? '',
        'paymentMethod': 'Razorpay',
        'icon': payment.status == 'success'
            ? LucideIcons.checkCircle
            : LucideIcons.xCircle,
        'color': payment.status == 'success'
            ? Theme.of(context).primaryColor
            : Colors.red,
      });
    }

    // Sort by date (newest first)
    combinedTransactions.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return combinedTransactions;
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final isExpense = transaction['type'] == 'expense';
    final date = transaction['date'] as DateTime;
    final title = transaction['title'] as String;
    final category = transaction['category'] as String;
    final amount = transaction['amount'] as double;
    final icon = transaction['icon'] as IconData;
    final color = transaction['color'] as Color;
    final description = transaction['description'] as String?;
    final paymentMethod = transaction['paymentMethod'] as String?;

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () {
        debugPrint(
          'Transaction tapped: ${transaction['title']} (${transaction['type']})',
        );
        if (transaction['type'] == 'expense' && onEditExpense != null) {
          debugPrint(
            'Opening edit/delete modal for expense: ${transaction['data'].id}',
          );
          showModalBottomSheet(
            context: context,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      LucideIcons.edit3,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      'Edit Transaction',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      debugPrint(
                        'Edit option selected for: ${transaction['data'].id}',
                      );
                      Navigator.pop(ctx);
                      onEditExpense!(transaction['data'] as Expense);
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.trash2, color: Colors.red),
                    title: Text(
                      'Delete Transaction',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      debugPrint(
                        'Delete option selected for: ${transaction['data'].id}',
                      );
                      Navigator.pop(ctx);
                      showDialog(
                        context: context,
                        builder: (alertCtx) => AlertDialog(
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          title: Text(
                            'Delete Transaction?',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete this transaction?',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(alertCtx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                debugPrint(
                                  'Confirmed delete for: ${transaction['data'].id}',
                                );
                                Navigator.pop(alertCtx);
                                if (onDeleteExpense != null) {
                                  onDeleteExpense!(
                                    (transaction['data'] as Expense).id,
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (transaction['type'] == 'payment') {
          debugPrint('Tapped payment, showing read-only message');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payments cannot be edited or deleted yet.'),
            ),
          );
        } else {
          debugPrint('Tapped unhandled type or onEditExpense is null');
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? (isExpense
                      ? Colors.red.shade900.withValues(alpha: 0.2)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.2))
                : (isExpense
                      ? Colors.red.shade50
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? (isExpense
                        ? Colors.red.shade800.withValues(alpha: 0.3)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.3))
                  : (isExpense
                        ? Colors.red.shade100
                        : Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.2)),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isExpense
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isExpense ? 'Expense' : 'Payment',
                                style: GoogleFonts.inter(
                                  color: isExpense
                                      ? Colors.red
                                      : Theme.of(context).primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _getCategoryIcon(category),
                              size: 14,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                category,
                                style: GoogleFonts.inter(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense ? '-' : '+'}${currencyFormatter.format(amount)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: isExpense
                              ? Colors.red
                              : Theme.of(context).primaryColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, y').format(date),
                        style: GoogleFonts.inter(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Additional details
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        size: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: GoogleFonts.inter(
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.creditCard,
                      size: 14,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      paymentMethod,
                      style: GoogleFonts.inter(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
      case 'successful':
        return LucideIcons.checkCircle;
      case 'failed':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.tag;
    }
  }

  Color _getCategoryColor(BuildContext context, String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.red;
      case 'bills':
        return Colors.indigo;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.teal;
      case 'education':
        return Colors.greenAccent;
      case 'groceries':
        return Theme.of(context).primaryColor;
      case 'rent':
        return Colors.brown;
      case 'utilities':
        return Colors.teal;
      case 'travel':
        return Colors.lightBlue;
      case 'investments':
        return Colors.cyan;
      case 'other':
        return Colors.grey;
      default:
        return Colors.primaries[category.hashCode % Colors.primaries.length];
    }
  }
}
