import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/expense.dart';

class AIScreen extends StatelessWidget {
  final List<Expense> expenses;
  final bool isDark;

  const AIScreen({super.key, required this.expenses, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bot,
            size: 64,
            color: isDark ? Colors.green.shade200 : Colors.green.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'AI Financial Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
