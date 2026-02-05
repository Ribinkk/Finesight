import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class GoalsScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const GoalsScreen({super.key, required this.user, required this.isDark});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> _goals = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.user == null) return;
    try {
      final data = await ApiService.getGoals(widget.user!.uid);
      if (mounted) {
        setState(() {
          _goals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addGoal() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    Color selectedColor = Colors.green;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            title: Text(
              'New Savings Goal',
              style: GoogleFonts.inter(
                color: widget.isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Amount',
                      prefixText: '₹ ',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Deadline',
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) => Theme(
                          data: widget.isDark
                              ? ThemeData.dark()
                              : ThemeData.light(),
                          child: child!,
                        ),
                      );
                      if (!context.mounted) return;
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text;
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (title.isEmpty || amount <= 0) return;

                  final newGoal = Goal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: widget.user!.uid,
                    title: title,
                    targetAmount: amount,
                    currentAmount: 0,
                    deadline: selectedDate,
                    color: selectedColor.toARGB32(),
                  );

                  try {
                    await ApiService.addGoal(newGoal);
                    if (!mounted) return;
                    _loadData();
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B6E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addFunds(Goal goal) async {
    final amountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Add Funds',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount to Add',
            prefixText: '₹ ',
            labelStyle: TextStyle(
              color: widget.isDark ? Colors.grey : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) return;

              final updatedGoal = Goal(
                id: goal.id,
                userId: goal.userId,
                title: goal.title,
                targetAmount: goal.targetAmount,
                currentAmount: goal.currentAmount + amount,
                deadline: goal.deadline,
                color: goal.color,
              );

              try {
                await ApiService.updateGoal(updatedGoal);
                if (!mounted) return;
                _loadData();
                if (ctx.mounted) Navigator.pop(ctx);

                if (updatedGoal.currentAmount >= updatedGoal.targetAmount) {
                  if (!context.mounted) return;
                  _confettiController.play();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal Reached! Congratulations! 🎉'),
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009B6E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(String id) async {
    try {
      await ApiService.deleteGoal(id, widget.user!.uid);
      setState(() {
        _goals.removeWhere((g) => g.id == id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
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
          'Savings Goals',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        backgroundColor: const Color(0xFF009B6E),
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Goal'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.target,
                        size: 64,
                        color: widget.isDark
                            ? Colors.white10
                            : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No savings goals yet',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: widget.isDark
                              ? Colors.white54
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final progress = (goal.currentAmount / goal.targetAmount)
                        .clamp(0.0, 1.0);
                    final daysLeft = goal.deadline
                        .difference(DateTime.now())
                        .inDays;

                    return Dismissible(
                      key: Key(goal.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteGoal(goal.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.trash2,
                          color: Colors.white,
                        ),
                      ),
                      child:
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: widget.isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        goal.title,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: widget.isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      if (progress >= 1.0)
                                        const Icon(
                                          LucideIcons.medal,
                                          color: Colors.amber,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}% Reached',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.grey
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: widget.isDark
                                          ? Colors.black26
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(goal.color),
                                              Color(
                                                goal.color,
                                              ).withValues(alpha: 0.7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            if (progress > 0)
                                              BoxShadow(
                                                color: Color(
                                                  goal.color,
                                                ).withValues(alpha: 0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Saved: ₹${goal.currentAmount.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: widget.isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Target: ₹${goal.targetAmount.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: widget.isDark
                                                  ? Colors.white38
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (progress < 1.0)
                                        ElevatedButton.icon(
                                          onPressed: () => _addFunds(goal),
                                          icon: const Icon(
                                            LucideIcons.plus,
                                            size: 16,
                                          ),
                                          label: const Text('Add Funds'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF009B6E,
                                            ).withValues(alpha: 0.1),
                                            foregroundColor: const Color(
                                              0xFF009B6E,
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    daysLeft < 0
                                        ? 'Ended'
                                        : '$daysLeft days left',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: daysLeft < 0
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().scale(
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                            delay: (100 * index).ms,
                          ),
                    );
                  },
                ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality:
                  BlastDirectionality.explosive, // radial value - 360 degrees
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
