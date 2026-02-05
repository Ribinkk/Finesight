import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class BudgetScreen extends StatefulWidget {
  final UserModel? user;
  final List<String> categories;
  final bool isDark;

  const BudgetScreen({
    super.key,
    required this.user,
    required this.categories,
    required this.isDark,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgets = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;
  final int _currentMonth = DateTime.now().month;
  final int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.user?.uid ?? '';
      final budgets = await ApiService.getBudgets(
        userId,
        month: _currentMonth,
        year: _currentYear,
      );
      final expenses = await ApiService.getExpenses(userId);

      // Filter expenses for current month/year
      final currentMonthExpenses = expenses
          .where(
            (e) => e.date.month == _currentMonth && e.date.year == _currentYear,
          )
          .toList();

      setState(() {
        _budgets = budgets;
        _expenses = currentMonthExpenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  Future<void> _setBudget(String category, double limit) async {
    try {
      final userId = widget.user?.uid ?? '';
      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // client-side ID gen
        userId: userId,
        category: category,
        limit: limit,
        month: _currentMonth,
        year: _currentYear,
      );

      await ApiService.setBudget(budget);
      if (mounted) {
        _loadData(); // Reload to refresh view
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set budget: $e')));
      }
    }
  }

  void _showSetBudgetDialog({
    Budget? existingBudget,
    String? categoryPreselect,
  }) {
    final limitController = TextEditingController(
      text: existingBudget != null
          ? existingBudget.limit.toStringAsFixed(0)
          : '',
    );
    String selectedCategory =
        existingBudget?.category ??
        categoryPreselect ??
        widget.categories.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E2028) : Colors.white,
        title: Text(
          existingBudget != null ? 'Edit Budget' : 'Set Budget',
          style: GoogleFonts.inter(
            color: widget.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (existingBudget == null)
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                dropdownColor: widget.isDark
                    ? const Color(0xFF2C2E36)
                    : Colors.white,
                items: widget.categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Monthly Limit',
                prefixText: '₹ ',
                labelStyle: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(limitController.text);
              if (limit != null && limit > 0) {
                _setBudget(selectedCategory, limit);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009B6E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total layout
    double totalBudget = _budgets.fold(0, (sum, item) => sum + item.limit);
    double totalSpent = _expenses.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Monthly Budgets',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF009B6E), Color(0xFF00E5A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF009B6E).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Budget (${_getMonthName(_currentMonth)})',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${totalBudget.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: totalBudget > 0
                                ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                                : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    totalSpent > totalBudget
                                        ? const Color(0xFFFF5252)
                                        : Colors.white,
                                    totalSpent > totalBudget
                                        ? const Color(0xFFFF1744)
                                        : Colors.white.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  if (totalSpent > 0)
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ₹${totalSpent.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Remaining: ₹${(totalBudget - totalSpent).toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category Budgets',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showSetBudgetDialog(),
                        icon: const Icon(LucideIcons.plusCircle),
                        color: const Color(0xFF009B6E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Budget List
                  ...widget.categories.map((category) {
                    final budget = _budgets.firstWhere(
                      (b) => b.category == category,
                      orElse: () => Budget(
                        id: '',
                        userId: '',
                        category: category,
                        limit: 0,
                        month: _currentMonth,
                        year: _currentYear,
                      ),
                    );

                    if (budget.limit == 0) {
                      return const SizedBox.shrink(); // Hide unset budgets from list or show as 'set budget' placeholder?
                    }

                    final spent = _expenses
                        .where((e) => e.category == category)
                        .fold(0.0, (sum, e) => sum + e.amount);
                    final progress = (spent / budget.limit).clamp(0.0, 1.0);
                    final isOverBudget = spent > budget.limit;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF1E2028)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOverBudget
                              ? const Color(0xFFE74C3C).withValues(alpha: 0.5)
                              : widget.isDark
                              ? Colors.white10
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.edit2,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () => _showSetBudgetDialog(
                                  existingBudget: budget,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 10,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isOverBudget
                                          ? const Color(0xFFE74C3C)
                                          : progress > 0.8
                                          ? const Color(0xFFFF9F43)
                                          : const Color(0xFF009B6E),
                                      isOverBudget
                                          ? const Color(0xFFC0392B)
                                          : progress > 0.8
                                          ? const Color(0xFFFF6B6B)
                                          : const Color(0xFF00E5A7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${spent.toStringAsFixed(0)} spent',
                                style: GoogleFonts.inter(
                                  color: isOverBudget
                                      ? const Color(0xFFE74C3C)
                                      : Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: isOverBudget
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                'of ₹${budget.limit.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  color: widget.isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // Add new budget button if listing categories with no budget
                  OutlinedButton.icon(
                    onPressed: () => _showSetBudgetDialog(),
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add Category Budget'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.isDark
                          ? Colors.white70
                          : Colors.black54,
                      side: BorderSide(
                        color: widget.isDark ? Colors.white24 : Colors.black12,
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
