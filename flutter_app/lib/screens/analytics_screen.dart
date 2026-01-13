import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF009B6E),
          unselectedLabelColor: widget.isDark ? Colors.white54 : Colors.grey,
          indicatorColor: const Color(0xFF009B6E),
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildCategoryView(), _buildTrendView()],
            ),
    );
  }

  Widget _buildCategoryView() {
    if (_categoryTotals.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    final total = _categoryTotals.values.fold(
      0.0,
      (sum, val) => sum + (val as num).toDouble(),
    );
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    int i = 0;
    _categoryTotals.forEach((key, value) {
      final amount = (value as num).toDouble();
      final percent = (amount / total) * 100;
      final color = colors[i % colors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percent.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ..._categoryTotals.entries.map((e) {
            final amt = (e.value as num).toDouble();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E2028) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:
                          colors[_categoryTotals.keys.toList().indexOf(e.key) %
                              colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.key,
                      style: GoogleFonts.inter(
                        color: widget.isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '₹${amt.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      color: widget.isDark ? Colors.white70 : Colors.black87,
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

  Widget _buildTrendView() {
    if (_monthlyTrends.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    // Sort keys maybe? assuming 'YYYY-M' format.
    final keys = _monthlyTrends.keys.toList()..sort();
    List<BarChartGroupData> barGroups = [];
    double maxVal = 0;

    for (int i = 0; i < keys.length; i++) {
      final val = (_monthlyTrends[keys[i]] as num).toDouble();
      if (val > maxVal) maxVal = val;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val,
              color: const Color(0xFF009B6E),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        if (val.toInt() < 0 || val.toInt() >= keys.length) {
                          return const Text('');
                        }
                        // Parse 'YYYY-M' to 'MMM'
                        final parts = keys[val.toInt()].split('-');
                        // Quick mapping
                        final m = int.parse(parts[1]);
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[m - 1],
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.white54
                                  : Colors.grey,
                              fontSize: 10,
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
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 5,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: widget.isDark
                        ? Colors.white10
                        : Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Monthly Spending Trends',
            style: GoogleFonts.inter(
              color: widget.isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
