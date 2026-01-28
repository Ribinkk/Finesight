import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../utils/currency_helper.dart';

enum ChartType { pie, bar, line }

class AnalyticsScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const AnalyticsScreen({super.key, required this.user, required this.isDark});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _categoryTotals = {};
  Map<String, dynamic> _monthlyTrends = {};
  ChartType _selectedChartType = ChartType.pie;

  // Modern Color Palette
  final List<Color> _chartColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFF97316), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.user?.uid ?? '';
      final data = await ApiService.getAnalytics(userId);
      setState(() {
        _categoryTotals = data['categoryTotals'] ?? {};
        _monthlyTrends = data['monthlyTrends'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.blueGrey[900],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1E293B)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF0F172A), // Dark accents
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: widget.isDark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Categories'),
                  Tab(text: 'Trends'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildCategoryAnalysis(), _buildTrendAnalysis()],
            ),
    );
  }

  Widget _buildCategoryAnalysis() {
    if (_categoryTotals.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Chart Type Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChartTypeBtn(ChartType.pie, LucideIcons.pieChart),
                _buildChartTypeBtn(ChartType.bar, LucideIcons.barChart),
                // _buildChartTypeBtn(ChartType.line, LucideIcons.lineChart), // Less useful for categories
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Chart Card
          Container(
            height: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _selectedChartType == ChartType.pie
                ? _buildPieChart()
                : _buildCategoryBarChart(),
          ),

          const SizedBox(height: 24),

          // Breakdown List
          ..._categoryTotals.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final key = entry.value.key;
            final amount = (entry.value.value as num).toDouble();
            final color = _chartColors[index % _chartColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconForCategory(key),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: widget.isDark
                                ? Colors.white
                                : Colors.blueGrey[900],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyHelper.format(amount),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.white
                          : Colors.blueGrey[900],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    if (_monthlyTrends.isEmpty) {
      return _buildEmptyState();
    }

    final keys = _monthlyTrends.keys.toList()..sort();
    double maxVal = 0;
    for (var k in keys) {
      final val = (_monthlyTrends[k] as num).toDouble();
      if (val > maxVal) maxVal = val;
    }

    // Default to Line chart for trends as it shows velocity better
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 400,
            padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 5 == 0 ? 1 : maxVal / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: widget.isDark
                        ? Colors.white10
                        : Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < 0 || value.toInt() >= keys.length) {
                          return const SizedBox();
                        }
                        final parts = keys[value.toInt()].split('-');
                        final months = [
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
                        final mIndex = int.parse(parts[1]) - 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[mIndex],
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxVal / 5 == 0 ? 1 : maxVal / 5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          CurrencyHelper.formatCompact(value),
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (keys.length - 1).toDouble(),
                minY: 0,
                maxY: maxVal * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(keys.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (_monthlyTrends[keys[index]] as num).toDouble(),
                      );
                    }),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF10B981),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.3),
                          const Color(0xFF10B981).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _categoryTotals.values.fold(
      0.0,
      (sum, val) => sum + (val as num).toDouble(),
    );

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: _categoryTotals.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final value = (entry.value.value as num).toDouble();
          final color = _chartColors[index % _chartColors.length];
          final percent = (value / total) * 100;

          return PieChartSectionData(
            color: color,
            value: value,
            title: '${percent.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryBarChart() {
    final entries = _categoryTotals.entries.toList();
    double maxVal = 0;
    for (var e in entries) {
      if ((e.value as num).toDouble() > maxVal) {
        maxVal = (e.value as num).toDouble();
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${entries[group.x.toInt()].key}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: CurrencyHelper.format(rod.toY),
                    style: const TextStyle(color: Colors.yellowAccent),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) return const SizedBox();
                // Show first letter of category as label
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    entries[value.toInt()].key.substring(0, 3), // First 3 chars
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final value = (entry.value.value as num).toDouble();
          final color = _chartColors[index % _chartColors.length];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal * 1.1,
                  color: widget.isDark ? Colors.white10 : Colors.grey.shade100,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.barChart2,
            size: 64,
            color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No data to analyze yet',
            style: GoogleFonts.inter(
              color: widget.isDark ? Colors.white54 : Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeBtn(ChartType type, IconData icon) {
    final isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.white
              : widget.isDark
              ? Colors.grey
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
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
      case 'travel':
        return LucideIcons.plane;
      default:
        return LucideIcons.tag;
    }
  }
}
