import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/split_expense.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class SplitScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const SplitScreen({super.key, required this.user, required this.isDark});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  List<SplitExpense> _splits = [];
  bool _isLoading = true;

  // Mock friends for now
  final List<String> _friends = ['Alice', 'Bob', 'Charlie', 'David'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.user == null) return;
    try {
      final data = await ApiService.getSplitExpenses(widget.user!.uid);
      if (mounted) {
        setState(() {
          _splits = data;
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

  Future<void> _addSplit() async {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String payer = 'You';
    Map<String, bool> selectedFriends = {
      for (var f in _friends) f: true,
    }; // Default split all

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          int splitCount =
              selectedFriends.values.where((v) => v).length + 1; // +1 for You
          double amount = double.tryParse(amountController.text) ?? 0;
          double splitAmount = splitCount > 0 ? amount / splitCount : 0;

          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            title: Text(
              'New Split Expense',
              style: GoogleFonts.inter(
                color: widget.isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
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
                    onChanged: (_) => setDialogState(() {}),
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
                  Text(
                    'Paid by',
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  DropdownButton<String>(
                    value: payer,
                    dropdownColor: widget.isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    isExpanded: true,
                    items: ['You', ..._friends]
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(
                              f,
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setDialogState(() => payer = val!),
                    underline: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Split with',
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  ..._friends.map(
                    (f) => CheckboxListTile(
                      title: Text(
                        f,
                        style: TextStyle(
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      value: selectedFriends[f],
                      onChanged: (val) =>
                          setDialogState(() => selectedFriends[f] = val!),
                      activeColor: const Color(0xFF009B6E),
                      checkColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Per person: ₹${splitAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF009B6E),
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
                  final desc = descController.text;
                  final amt = double.tryParse(amountController.text) ?? 0;
                  if (desc.isEmpty || amt <= 0) return;

                  // Create splits
                  List<SplitPerson> splitPeople = [];
                  selectedFriends.forEach((name, isIncluded) {
                    if (isIncluded) {
                      splitPeople.add(
                        SplitPerson(
                          personName: name,
                          amountOwed: splitAmount,
                          isPaid: false,
                        ),
                      );
                    }
                  });
                  // If 'You' are included implicitly? For now assuming 'You' pay and others owe, OR 'Others' pay and you owe.
                  // Simplified: if Payer is You, others owe you. If Payer is X, You owe X (and others owe X).

                  // For this MVP, let's track what OTHERS owe YOU if you pay.
                  // If someone else pays, you owe them.

                  final newSplit = SplitExpense(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: widget.user!.uid,
                    description: desc,
                    totalAmount: amt,
                    payer: payer,
                    splits: splitPeople,
                    date: DateTime.now(),
                  );

                  try {
                    await ApiService.addSplitExpense(newSplit);
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

  Future<void> _deleteSplit(String id) async {
    try {
      await ApiService.deleteSplitExpense(id, widget.user!.uid);
      if (!mounted) return;
      setState(() {
        _splits.removeWhere((s) => s.id == id);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
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
          'Split Expenses',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSplit,
        backgroundColor: const Color(0xFF009B6E),
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Split'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _splits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 64,
                    color: widget.isDark
                        ? Colors.white10
                        : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No split expenses',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track shared bills with friends',
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
              itemCount: _splits.length,
              itemBuilder: (context, index) {
                final split = _splits[index];
                final youPaid = split.payer == 'You';

                return Dismissible(
                  key: Key(split.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteSplit(split.id),
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
                            child: ExpansionTile(
                              shape: Border(),
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: youPaid
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  youPaid
                                      ? LucideIcons.arrowUpRight
                                      : LucideIcons.arrowDownLeft,
                                  color: youPaid ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text(
                                split.description,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                youPaid
                                    ? 'You paid ₹${split.totalAmount}'
                                    : '${split.payer} paid ₹${split.totalAmount}',
                                style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    youPaid ? 'You lent' : 'You owe',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.isDark
                                          ? Colors.white54
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  Text(
                                    '₹${(split.totalAmount / (split.splits.length + 1)).toStringAsFixed(0)}', // Approx
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: youPaid
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: split.splits
                                        .map(
                                          (s) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                s.personName,
                                                style: TextStyle(
                                                  color: widget.isDark
                                                      ? Colors.white70
                                                      : Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'owes ₹${s.amountOwed.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: s.isPaid
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
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
