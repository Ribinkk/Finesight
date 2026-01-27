import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../data/subscription_data.dart'; // Import new data

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
                  // Quick Select Logos
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: SubscriptionData.services.map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 16),
                          child: InkWell(
                            onTap: () {
                              // Show Plan Selection for this service
                              showDialog(
                                context: context,
                                builder: (innerContext) => AlertDialog(
                                  backgroundColor: widget.isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  title: Text(
                                    'Select ${service.name} Plan',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: service.plans
                                        .map(
                                          (plan) => ListTile(
                                            title: Text(
                                              plan.name,
                                              style: TextStyle(
                                                color: widget.isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${plan.description} - ₹${plan.price}',
                                              style: TextStyle(
                                                color: widget.isDark
                                                    ? Colors.grey
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            onTap: () {
                                              setDialogState(() {
                                                titleController.text =
                                                    service.name;
                                                amountController.text = plan
                                                    .price
                                                    .toString();
                                                selectedFrequency =
                                                    plan.frequency;
                                                selectedCategory =
                                                    'Entertainment'; // Default for subs
                                              });
                                              Navigator.pop(innerContext);
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: service.color.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: service.logoUrl.endsWith('.svg')
                                      ? (service.logoUrl.startsWith('http')
                                            ? SvgPicture.network(
                                                service.logoUrl,
                                                width: 32,
                                                height: 32,
                                                placeholderBuilder:
                                                    (
                                                      BuildContext context,
                                                    ) => Center(
                                                      child: Text(
                                                        service.name[0],
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  service.color,
                                                            ),
                                                      ),
                                                    ),
                                              )
                                            : SvgPicture.asset(
                                                service.logoUrl,
                                                width: 32,
                                                height: 32,
                                              ))
                                      : (service.logoUrl.startsWith('http')
                                            ? Image.network(
                                                service.logoUrl,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Center(
                                                        child: Text(
                                                          service.name[0],
                                                          style:
                                                              GoogleFonts.outfit(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: service
                                                                    .color,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Image.asset(
                                                service.logoUrl,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Center(
                                                        child: Text(
                                                          service.name[0],
                                                          style:
                                                              GoogleFonts.outfit(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: service
                                                                    .color,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                              )),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  service.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: widget.isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

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
          : Column(
              children: [
                if (_transactions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF009B6E), Color(0xFF00C853)],
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
                          'Total Monthly Cost',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_transactions.fold(0.0, (sum, t) {
                            switch (t.frequency) {
                              case 'Daily':
                                return sum + (t.amount * 30);
                              case 'Weekly':
                                return sum + (t.amount * 4);
                              case 'Yearly':
                                return sum + (t.amount / 12);
                              default:
                                return sum + t.amount;
                            }
                          }).toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.calendar,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_transactions.length} Active Subscriptions',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: _transactions.isEmpty
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                child: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.white,
                                ),
                              ),
                              child: Card(
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
                                    width: 48,
                                    height: 48,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: SubscriptionData.getColor(
                                          item.title,
                                        ).withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        final logoUrl =
                                            SubscriptionData.getLogoUrl(
                                              item.title,
                                            );
                                        if (logoUrl != null) {
                                          if (logoUrl.endsWith('.svg')) {
                                            return logoUrl.startsWith('http')
                                                ? SvgPicture.network(
                                                    logoUrl,
                                                    width: 32,
                                                    height: 32,
                                                    placeholderBuilder:
                                                        (
                                                          BuildContext context,
                                                        ) => Icon(
                                                          LucideIcons.refreshCw,
                                                          color:
                                                              SubscriptionData.getColor(
                                                                item.title,
                                                              ),
                                                        ),
                                                  )
                                                : SvgPicture.asset(
                                                    logoUrl,
                                                    width: 32,
                                                    height: 32,
                                                  );
                                          }
                                          return logoUrl.startsWith('http')
                                              ? Image.network(
                                                  logoUrl,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Icon(
                                                        LucideIcons.refreshCw,
                                                        color:
                                                            SubscriptionData.getColor(
                                                              item.title,
                                                            ),
                                                      ),
                                                )
                                              : Image.asset(
                                                  logoUrl,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Icon(
                                                        LucideIcons.refreshCw,
                                                        color:
                                                            SubscriptionData.getColor(
                                                              item.title,
                                                            ),
                                                      ),
                                                );
                                        }
                                        return Icon(
                                          LucideIcons.refreshCw,
                                          color: SubscriptionData.getColor(
                                            item.title,
                                          ),
                                        );
                                      },
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              ? Colors.red.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Colors.blue.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
