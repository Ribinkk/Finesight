import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../utils/currency_helper.dart';

class SpendingAnalysisScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Income> incomes;
  final bool isDark;

  const SpendingAnalysisScreen({
    super.key,
    required this.expenses,
    required this.incomes,
    required this.isDark,
  });

  @override
  State<SpendingAnalysisScreen> createState() => _SpendingAnalysisScreenState();
}

class _SpendingAnalysisScreenState extends State<SpendingAnalysisScreen> {
  String? _selectedCategory;

  // Computed data
  late final double _totalExpenses;
  late final double _totalIncome;
  late final Map<String, double> _categoryTotals;
  late final Map<String, int> _categoryCounts;
  late final List<MapEntry<String, double>> _sortedCategories;
  late final Map<String, List<Expense>> _categoryExpenses;
  late final double _monthTotal;
  late final double _lastMonthTotal;
  late final double _dailyAvg;
  late final Map<int, double> _dailySpending;
  late final List<Expense> _topExpenses;

  @override
  void initState() {
    super.initState();
    _computeData();
  }

  void _computeData() {
    final now = DateTime.now();
    _totalExpenses = widget.expenses.fold(0.0, (s, e) => s + e.amount);
    _totalIncome = widget.incomes.fold(0.0, (s, i) => s + i.amount);

    _categoryTotals = <String, double>{};
    _categoryCounts = <String, int>{};
    _categoryExpenses = <String, List<Expense>>{};
    for (var e in widget.expenses) {
      _categoryTotals[e.category] = (_categoryTotals[e.category] ?? 0) + e.amount;
      _categoryCounts[e.category] = (_categoryCounts[e.category] ?? 0) + 1;
      _categoryExpenses.putIfAbsent(e.category, () => []).add(e);
    }
    _sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final thisMonth = widget.expenses.where((e) => e.date.month == now.month && e.date.year == now.year);
    _monthTotal = thisMonth.fold(0.0, (s, e) => s + e.amount);

    final lastMonth = widget.expenses.where((e) {
      final lm = DateTime(now.year, now.month - 1);
      return e.date.month == lm.month && e.date.year == lm.year;
    });
    _lastMonthTotal = lastMonth.fold(0.0, (s, e) => s + e.amount);

    final daysInMonth = now.day;
    _dailyAvg = daysInMonth > 0 ? _monthTotal / daysInMonth : 0;

    _dailySpending = <int, double>{};
    for (var e in thisMonth) {
      _dailySpending[e.date.day] = (_dailySpending[e.date.day] ?? 0) + e.amount;
    }

    _topExpenses = List<Expense>.from(widget.expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Spending Analysis', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.blueGrey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Row
            _buildSummaryRow(primary),
            const SizedBox(height: 20),

            // Month comparison
            _buildMonthComparison(primary),
            const SizedBox(height: 20),

            // Daily spending chart
            _buildDailyChart(primary),
            const SizedBox(height: 20),

            // Category breakdown
            _buildCategoryBreakdown(primary),
            const SizedBox(height: 20),

            // Top expenses
            _buildTopExpenses(),
            const SizedBox(height: 20),

            // Category drill-down
            if (_selectedCategory != null) ...[
              _buildCategoryDrillDown(),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(Color primary) {
    final savingsRate = _totalIncome > 0
        ? ((_totalIncome - _totalExpenses) / _totalIncome * 100)
        : 0.0;

    return Row(
      children: [
        Expanded(child: _summaryCard('Daily Avg', CurrencyHelper.format(_dailyAvg), LucideIcons.calendar, const [Color(0xFF6366F1), Color(0xFF818CF8)])),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Savings', '${savingsRate.toStringAsFixed(0)}%', LucideIcons.piggyBank, [primary, primary.withValues(alpha: 0.7)])),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Txns', '${widget.expenses.length}', LucideIcons.receipt, const [Color(0xFFF97316), Color(0xFFFB923C)])),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _summaryCard(String label, String value, IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMonthComparison(Color primary) {
    final change = _lastMonthTotal > 0
        ? ((_monthTotal - _lastMonthTotal) / _lastMonthTotal * 100)
        : 0.0;
    final isUp = change >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Month-over-Month', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(CurrencyHelper.format(_monthTotal), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Month', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(CurrencyHelper.format(_lastMonthTotal), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white70 : Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isUp ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isUp ? LucideIcons.trendingUp : LucideIcons.trendingDown, size: 14, color: isUp ? Colors.red : Colors.green),
                    const SizedBox(width: 4),
                    Text('${change.abs().toStringAsFixed(1)}%', style: TextStyle(color: isUp ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildDailyChart(Color primary) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    double maxVal = 0;
    for (var v in _dailySpending.values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1000;

    final chartMaxY = maxVal * 1.3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.barChart2, color: primary, size: 20),
              const SizedBox(width: 8),
              Text('Daily Spending', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: widget.isDark ? Colors.white : Colors.black87)),
            ],
          ),
          Text(DateFormat('MMMM yyyy').format(now), style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          if (_dailySpending.isEmpty)
            SizedBox(
              height: 180,
              child: Center(
                child: Text('No spending data this month', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey[800]!,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      getTooltipItem: (group, gi, rod, ri) {
                        final day = group.x + 1;
                        final amount = _dailySpending[day] ?? 0;
                        if (amount == 0) return null;
                        return BarTooltipItem(
                          'Day $day\n${CurrencyHelper.format(amount)}',
                          GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            CurrencyHelper.formatCompact(value),
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          );
                        },
                        interval: chartMaxY / 4,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt() + 1;
                          if (day % 5 == 0 || day == 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('$day', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500)),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: chartMaxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(daysInMonth, (i) {
                    final day = i + 1;
                    final val = _dailySpending[day] ?? 0;
                    final isToday = day == now.day;
                    final hasData = val > 0;
                    final barWidth = daysInMonth > 28 ? 5.0 : 7.0;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: hasData ? val : 0,
                          width: barWidth,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          gradient: hasData
                              ? LinearGradient(
                                  colors: isToday
                                      ? [const Color(0xFF6366F1), const Color(0xFF818CF8)]
                                      : [primary, primary.withValues(alpha: 0.7)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : null,
                          color: hasData ? null : Colors.transparent,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: chartMaxY,
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.grey.shade100,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildCategoryBreakdown(Color primary) {
    if (_sortedCategories.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          ..._sortedCategories.map((entry) {
            final pct = _totalExpenses > 0 ? (entry.value / _totalExpenses) : 0.0;
            final count = _categoryCounts[entry.key] ?? 0;
            final colors = _getCategoryGradient(entry.key);
            final isSelected = _selectedCategory == entry.key;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = isSelected ? null : entry.key;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors[0].withValues(alpha: 0.1)
                      : (widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected ? Border.all(color: colors[0].withValues(alpha: 0.4), width: 1.5) : null,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [colors[0].withValues(alpha: 0.2), colors[1].withValues(alpha: 0.1)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_getCategoryIcon(entry.key), color: colors[0], size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black87)),
                              Text('$count transactions', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(CurrencyHelper.format(entry.value), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black87)),
                            Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: colors[0], fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Icon(isSelected ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: widget.isDark ? Colors.white10 : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(colors[0]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildTopExpenses() {
    final top = _topExpenses.take(5).toList();
    if (top.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.flame, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text('Top Expenses', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: widget.isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 14),
          ...top.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final colors = _getCategoryGradient(e.category);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: widget.isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis),
                        Text('${e.category} • ${DateFormat('MMM d').format(e.date)}', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(CurrencyHelper.format(e.amount), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade400)),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1);
  }

  Widget _buildCategoryDrillDown() {
    final cat = _selectedCategory!;
    final expenses = _categoryExpenses[cat] ?? [];
    final sorted = List<Expense>.from(expenses)..sort((a, b) => b.date.compareTo(a.date));
    final colors = _getCategoryGradient(cat);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[0].withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getCategoryIcon(cat), color: colors[0], size: 20),
              const SizedBox(width: 8),
              Text('$cat Details', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: widget.isDark ? Colors.white : Colors.black87)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = null),
                child: Icon(LucideIcons.x, size: 18, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 24),
          ...sorted.take(10).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: widget.isDark ? Colors.white : Colors.black87)),
                          Text(DateFormat('MMM d, yyyy').format(e.date), style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(CurrencyHelper.format(e.amount), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: widget.isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              )),
          if (sorted.length > 10) Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('+ ${sorted.length - 10} more', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'food': return const [Color(0xFFF97316), Color(0xFFFB923C)];
      case 'transport': return const [Color(0xFF3B82F6), Color(0xFF60A5FA)];
      case 'shopping': return const [Color(0xFFEF4444), Color(0xFFF87171)];
      case 'bills': return const [Color(0xFF6366F1), Color(0xFF818CF8)];
      case 'entertainment': return const [Color(0xFFEC4899), Color(0xFFF472B6)];
      case 'health': return const [Color(0xFF14B8A6), Color(0xFF2DD4BF)];
      case 'education': return const [Color(0xFF8B5CF6), Color(0xFFA78BFA)];
      case 'groceries': return const [Color(0xFF10B981), Color(0xFF34D399)];
      case 'rent': return const [Color(0xFF78350F), Color(0xFF92400E)];
      case 'utilities': return const [Color(0xFF06B6D4), Color(0xFF22D3EE)];
      case 'travel': return const [Color(0xFF0EA5E9), Color(0xFF38BDF8)];
      default: return const [Color(0xFF64748B), Color(0xFF94A3B8)];
    }
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
      case 'travel': return LucideIcons.plane;
      default: return LucideIcons.tag;
    }
  }
}
