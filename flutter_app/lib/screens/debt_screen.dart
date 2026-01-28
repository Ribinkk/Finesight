import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/currency_helper.dart';

class DebtScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const DebtScreen({super.key, required this.user, required this.isDark});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Debt> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.user == null) return;
    try {
      final data = await ApiService.getDebts(widget.user!.uid);
      if (mounted) {
        setState(() {
          _debts = data;
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

  Future<void> _deleteDebt(String id) async {
    final backup = List<Debt>.from(_debts);
    setState(() {
      _debts.removeWhere((t) => t.id == id);
    });

    try {
      await ApiService.deleteDebt(id, widget.user!.uid);
    } catch (e) {
      setState(() => _debts = backup);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  void _showAddEditDialog({Debt? debt, String? initialType}) {
    final titleController = TextEditingController(text: debt?.title ?? '');
    final totalAmountController = TextEditingController(
      text: debt?.totalAmount.toString() ?? '',
    );
    final paidAmountController = TextEditingController(
      text: debt?.paidAmount.toString() ?? '0',
    );
    final descriptionController = TextEditingController(
      text: debt?.description ?? '',
    );

    DateTime selectedDate =
        debt?.dueDate ?? DateTime.now().add(const Duration(days: 30));
    String selectedType =
        debt?.type ?? initialType ?? 'Lent'; // 'Lent' or 'Borrowed'

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            title: Text(
              debt == null ? 'New Debt Record' : 'Edit Record',
              style: GoogleFonts.inter(
                color: widget.isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Type Selector
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? Colors.black26
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedType = 'Lent'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == 'Lent'
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'I Lent',
                                style: TextStyle(
                                  color: selectedType == 'Lent'
                                      ? Colors.white
                                      : (widget.isDark
                                            ? Colors.grey
                                            : Colors.grey.shade600),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedType = 'Borrowed'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == 'Borrowed'
                                    ? const Color(0xFFE11D48)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'I Borrowed',
                                style: TextStyle(
                                  color: selectedType == 'Borrowed'
                                      ? Colors.white
                                      : (widget.isDark
                                            ? Colors.grey
                                            : Colors.grey.shade600),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: _inputDecoration('Title (e.g. John Doe)'),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: totalAmountController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            'Total Amount',
                            prefix: '₹ ',
                          ),
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: paidAmountController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            'Paid So Far',
                            prefix: '₹ ',
                          ),
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Due Date',
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
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) => Theme(
                          data: widget.isDark
                              ? ThemeData.dark()
                              : ThemeData.light(),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: _inputDecoration('Notes (Optional)'),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
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
                  final total =
                      double.tryParse(totalAmountController.text) ?? 0;
                  final paid = double.tryParse(paidAmountController.text) ?? 0;

                  if (title.isEmpty || total <= 0) return;

                  final newItem = Debt(
                    id:
                        debt?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: widget.user!.uid,
                    title: title,
                    totalAmount: total,
                    paidAmount: paid,
                    dueDate: selectedDate,
                    type: selectedType,
                    description: descriptionController.text,
                  );

                  try {
                    if (debt == null) {
                      await ApiService.addDebt(newItem);
                    } else {
                      await ApiService.updateDebt(newItem);
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
                  backgroundColor: selectedType == 'Lent'
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE11D48),
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

  InputDecoration _inputDecoration(String label, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: widget.isDark ? Colors.grey : Colors.grey.shade600,
      ),
      prefixText: prefix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyHelper.format(amount),
            style: GoogleFonts.outfit(
              color: widget.isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(String type) {
    final filtered = _debts.where((d) => d.type == type).toList();
    final color = type == 'Lent'
        ? const Color(0xFF10B981)
        : const Color(0xFFE11D48);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.banknote,
              size: 64,
              color: widget.isDark ? Colors.white10 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'Lent' ? 'No money lent yet' : 'Debt free!',
              style: TextStyle(
                color: widget.isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final progress = (item.paidAmount / item.totalAmount).clamp(0.0, 1.0);
        final remaining = item.totalAmount - item.paidAmount;

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteDebt(item.id),
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
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: InkWell(
              onTap: () => _showAddEditDialog(debt: item),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due ${DateFormat('MMM d').format(item.dueDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark
                                    ? Colors.grey
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyHelper.format(item.totalAmount),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            if (remaining > 0)
                              Text(
                                '${CurrencyHelper.format(remaining)} left',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            else
                              Text(
                                'Settled',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: widget.isDark
                            ? Colors.black26
                            : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remaining <= 0 ? Colors.green : color,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLent = _debts
        .where((d) => d.type == 'Lent')
        .fold(0.0, (sum, d) => sum + (d.totalAmount - d.paidAmount));
    final totalBorrowed = _debts
        .where((d) => d.type == 'Borrowed')
        .fold(0.0, (sum, d) => sum + (d.totalAmount - d.paidAmount));

    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Debts & Loans',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: widget.isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF009B6E),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Lent (Assets)'),
            Tab(text: 'Borrowed (Liabilities)'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(
          initialType: _tabController.index == 0 ? 'Lent' : 'Borrowed',
        ),
        backgroundColor: const Color(0xFF009B6E),
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Record'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Owed to You',
                          totalLent,
                          const Color(0xFF10B981),
                          LucideIcons.arrowUpRight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'You Owe',
                          totalBorrowed,
                          const Color(0xFFE11D48),
                          LucideIcons.arrowDownLeft,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDebtList('Lent'),
                      _buildDebtList('Borrowed'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
