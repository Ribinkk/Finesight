import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../utils/currency_helper.dart';

class AIScreen extends StatelessWidget {
  final List<Expense> expenses;
  final bool isDark;

  const AIScreen({super.key, required this.expenses, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Basic Analysis
    final double totalSpent = expenses.fold(0, (sum, e) => sum + e.amount);
    // insights mock

    // Insights Mock
    final insights = [
      {
        'icon': LucideIcons.trendingUp,
        'title': 'Spending Trend',
        'desc':
            'You are projected to spend ${CurrencyHelper.format(totalSpent * 1.1)} this month, 10% higher than average.',
        'color': Colors.orange,
      },
      {
        'icon': LucideIcons.coffee,
        'title': 'Habit Alert',
        'desc':
            'Frequent coffee visits detected. Consider a subscription to save ~${CurrencyHelper.format(500)}/mo.',
        'color': Colors.blue,
      },
      {
        'icon': LucideIcons.piggyBank,
        'title': 'Savings Opportunity',
        'desc':
            'Reducing dining out by 20% could help you reach your "New Car" goal 1 month earlier.',
        'color': Colors.green,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                color: const Color(0xFF009B6E),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Forecast Chart
          Text(
            'Spending Forecast',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 3.5),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: const Color(0xFF009B6E),
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF009B6E).withValues(alpha: 0.2),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(5, 6), FlSpot(6, 6.5), FlSpot(7, 7)],
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dashArray: [5, 5],
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),

          const SizedBox(height: 24),

          // Insights List
          Text(
            'Recommendations',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...insights.asMap().entries.map((entry) {
            final i = entry.value;
            return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (i['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        i['icon'] as IconData,
                        color: i['color'] as Color,
                      ),
                    ),
                    title: Text(
                      i['title'] as String,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        i['desc'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .slideX(begin: 0.2, end: 0, delay: (200 * entry.key).ms)
                .fadeIn();
          }),
        ],
      ),
    );
  }
}
