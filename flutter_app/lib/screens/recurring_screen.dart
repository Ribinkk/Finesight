import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class RecurringScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;
  final List<String> categories;

  const RecurringScreen({
    super.key,
    required this.user,
    required this.isDark,
    required this.categories,
  });

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  List<RecurringTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.user == null) return;
    try {
      final data = await ApiService.getRecurringTransactions(widget.user!.uid);
      if (mounted) {
        setState(() {
          _transactions = data;
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

  Future<void> _deleteTransaction(String id) async {
    // Optimistic update
    final backup = List<RecurringTransaction>.from(_transactions);
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });

    try {
      await ApiService.deleteRecurringTransaction(id, widget.user!.uid);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Subscription removed')));
      }
    } catch (e) {
      // Revert
      setState(() => _transactions = backup);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  void _showAddEditDialog({RecurringTransaction? transaction}) {
    final titleController = TextEditingController(
      text: transaction?.title ?? '',
    );
    final amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );
    String selectedCategory =
        transaction?.category ??
        (widget.categories.isNotEmpty ? widget.categories.first : 'Other');
    String selectedFrequency = transaction?.frequency ?? 'Monthly';
    DateTime selectedDate = transaction?.nextDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            title: Text(
              transaction == null ? 'New Subscription' : 'Edit Subscription',
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
                      labelText: 'Title',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.isDark
                              ? Colors.white24
                              : Colors.grey.shade300,
                        ),
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
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.isDark
                              ? Colors.white24
                              : Colors.grey.shade300,
                        ),
                      ),
                      prefixText: '₹ ',
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: widget.isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.isDark
                              ? Colors.white24
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                    items: widget.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedFrequency,
                    dropdownColor: widget.isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.isDark
                              ? Colors.white24
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                    items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedFrequency = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Next Payment',
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, y').format(selectedDate),
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
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
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
                      side: BorderSide(
                        color: widget.isDark
                            ? Colors.white24
                            : Colors.grey.shade300,
                      ),
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

                  final newItem = RecurringTransaction(
                    id:
                        transaction?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: widget.user!.uid,
                    title: title,
                    amount: amount,
                    category: selectedCategory,
                    frequency: selectedFrequency,
                    nextDate: selectedDate,
                    isActive: true,
                  );

                  try {
                    if (transaction == null) {
                      await ApiService.addRecurringTransaction(newItem);
                    } else {
                      await ApiService.updateRecurringTransaction(newItem);
                    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Subscriptions',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF009B6E),
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Subscription'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.repeat,
                    size: 64,
                    color: widget.isDark
                        ? Colors.white10
                        : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subscriptions yet',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your monthly bills automatically',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: widget.isDark
                          ? Colors.white24
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final item = _transactions[index];
                final daysLeft = item.nextDate
                    .difference(DateTime.now())
                    .inDays;

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteTransaction(item.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(LucideIcons.trash2, color: Colors.white),
                  ),
                  child:
                      Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: widget.isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: widget.isDark
                                    ? Colors.transparent
                                    : Colors.grey.shade200,
                              ),
                            ),
                            elevation: 0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF009B6E,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.refreshCw,
                                  color: Color(0xFF009B6E),
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.frequency} • ${item.category}',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white54
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: daysLeft <= 3
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      daysLeft < 0
                                          ? 'Overdue'
                                          : (daysLeft == 0
                                                ? 'Due Today'
                                                : '$daysLeft days left'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: daysLeft <= 3
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${item.amount.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              onTap: () =>
                                  _showAddEditDialog(transaction: item),
                            ),
                          )
                          .animate()
                          .fade(duration: 400.ms)
                          .slideX(begin: 0.2, end: 0, delay: (100 * index).ms),
                );
              },
            ),
    );
  }
}
