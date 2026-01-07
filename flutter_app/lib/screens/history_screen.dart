import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/payment.dart';

class HistoryScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Payment> payments;
  final bool isDark;
  final Future<void> Function()? onRefresh;

  const HistoryScreen({
    super.key,
    required this.expenses,
    required this.payments,
    required this.isDark,
    this.onRefresh,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _filterType = 'All'; // All, Expenses, Payments
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> get _filteredTransactions {
    var transactions = _buildCombinedTransactions();
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((t) {
        final title = (t['title'] as String).toLowerCase();
        final category = (t['category'] as String).toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) ||
               category.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply type filter
    if (_filterType == 'Expenses') {
      transactions = transactions.where((t) => t['type'] == 'expense').toList();
    } else if (_filterType == 'Payments') {
      transactions = transactions.where((t) => t['type'] == 'payment').toList();
    }
    
    // Apply date range filter
    if (_startDate != null) {
      transactions = transactions.where((t) {
        final date = t['date'] as DateTime;
        return date.isAfter(_startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }
    if (_endDate != null) {
      transactions = transactions.where((t) {
        final date = t['date'] as DateTime;
        return date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        color: Colors.green,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF020617) : const Color(0xFFF5F7FA),
          ),
          child: Column(
            children: [
              // Search & Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade600),
                        prefixIcon: Icon(LucideIcons.search, color: widget.isDark ? Colors.grey : Colors.grey.shade600),
                        filled: true,
                        fillColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Expenses'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Payments'),
                          const SizedBox(width: 8),
                          _buildDateFilterChip(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transactions List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.fileText,
                              size: 64,
                              color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'Try a different search term'
                                  : 'Your transactions will appear here',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTransactions.length + 2, // +2 for header and footer
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Header
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.history,
                                      color: widget.isDark ? Colors.blue.shade300 : Colors.blue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Transaction History',
                                      style: GoogleFonts.inter(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: widget.isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${filteredTransactions.length} transactions',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }
                          if (index == filteredTransactions.length + 1) {
                            return const SizedBox(height: 80); // Bottom padding
                          }
                          return _buildTransactionCard(filteredTransactions[index - 1]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    return GestureDetector(
      onTap: () => setState(() => _filterType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.green 
              : (widget.isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected 
                ? Colors.white 
                : (widget.isDark ? Colors.grey : Colors.grey.shade700),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterChip() {
    final hasDateFilter = _startDate != null || _endDate != null;
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
        );
        if (picked != null) {
          setState(() {
            _startDate = picked.start;
            _endDate = picked.end;
          });
        }
      },
      onLongPress: () {
        // Clear date filter on long press
        setState(() {
          _startDate = null;
          _endDate = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: hasDateFilter 
              ? Colors.blue 
              : (widget.isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 16,
              color: hasDateFilter 
                  ? Colors.white 
                  : (widget.isDark ? Colors.grey : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              hasDateFilter 
                  ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                  : 'Date Range',
              style: GoogleFonts.inter(
                color: hasDateFilter 
                    ? Colors.white 
                    : (widget.isDark ? Colors.grey : Colors.grey.shade700),
                fontWeight: hasDateFilter ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasDateFilter) ...[
              const SizedBox(width: 6),
              Icon(LucideIcons.x, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildCombinedTransactions() {
    final List<Map<String, dynamic>> combinedTransactions = [];
    
    // Add expenses
    for (var expense in widget.expenses) {
      combinedTransactions.add({
        'type': 'expense',
        'date': expense.date,
        'title': expense.title,
        'category': expense.category,
        'amount': expense.amount,
        'description': expense.description,
        'paymentMethod': expense.paymentMethod,
        'icon': _getCategoryIcon(expense.category),
        'color': _getCategoryColor(expense.category),
      });
    }
    
    // Add payments
    for (var payment in widget.payments) {
      combinedTransactions.add({
        'type': 'payment',
        'date': payment.date,
        'title': payment.purpose,
        'category': payment.status == 'success' ? 'Successful' : 'Failed',
        'amount': payment.amount,
        'description': payment.razorpayOrderId ?? '',
        'paymentMethod': 'Razorpay',
        'icon': payment.status == 'success' ? LucideIcons.checkCircle : LucideIcons.xCircle,
        'color': payment.status == 'success' ? Colors.green : Colors.red,
      });
    }
    
    // Sort by date (newest first)
    combinedTransactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    return combinedTransactions;
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isExpense = transaction['type'] == 'expense';
    final date = transaction['date'] as DateTime;
    final title = transaction['title'] as String;
    final category = transaction['category'] as String;
    final amount = transaction['amount'] as double;
    final icon = transaction['icon'] as IconData;
    final color = transaction['color'] as Color;
    final description = transaction['description'] as String?;
    final paymentMethod = transaction['paymentMethod'] as String?;
    
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark 
              ? (isExpense ? Colors.red.shade900.withOpacity(0.2) : Colors.green.shade900.withOpacity(0.2))
              : (isExpense ? Colors.red.shade50 : Colors.green.shade50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? (isExpense ? Colors.red.shade800.withOpacity(0.3) : Colors.green.shade800.withOpacity(0.3))
                : (isExpense ? Colors.red.shade100 : Colors.green.shade100),
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
                    color: color.withOpacity(0.2),
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
                          color: widget.isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isExpense 
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isExpense ? 'Expense' : 'Payment',
                              style: GoogleFonts.inter(
                                color: isExpense ? Colors.red : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getCategoryIcon(category),
                            size: 14,
                            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              category,
                              style: GoogleFonts.inter(
                                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                        color: isExpense ? Colors.red : Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, y').format(date),
                      style: GoogleFonts.inter(
                        color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                  color: widget.isDark 
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 14,
                      color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: GoogleFonts.inter(
                          color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
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
                    color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    paymentMethod,
                    style: GoogleFonts.inter(
                      color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
      case 'successful': return LucideIcons.checkCircle;
      case 'failed': return LucideIcons.xCircle;
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
        return Colors.primaries[category.hashCode % Colors.primaries.length];
    }
  }
}
