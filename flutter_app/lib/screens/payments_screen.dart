import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/payment.dart';
import '../models/user_model.dart';
import 'recurring_screen.dart';
import 'debt_screen.dart';
import '../models/expense.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentsScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;
  final List<Payment> payments;
  final List<Expense> expenses;
  final Function(Payment) onAdd;
  final Function(Expense) onAddExpense;
  final List<String> categories;
  final double currentBalance;

  const PaymentsScreen({
    super.key,
    required this.user,
    required this.isDark,
    required this.payments,
    required this.expenses,
    required this.onAdd,
    required this.onAddExpense,
    required this.categories,
    required this.currentBalance,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: widget.isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: Text(
            'Finesight AI',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          backgroundColor: widget.isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          foregroundColor: widget.isDark ? Colors.white : Colors.black,
          elevation: 0,
          bottom: TabBar(
            labelColor: widget.isDark ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF3B82F6),
            tabs: const [
              Tab(text: 'Wallet'),
              Tab(text: 'Bills'),
              Tab(text: 'Loans'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WalletView(
              isDark: widget.isDark,
              payments: widget.payments,
              expenses: widget.expenses,
              onAdd: widget.onAdd,
              onAddExpense: widget.onAddExpense,
              currentBalance: widget.currentBalance,
            ),
            RecurringScreen(
              user: widget.user,
              isDark: widget.isDark,
              categories: widget.categories,
            ),
            DebtScreen(user: widget.user, isDark: widget.isDark),
          ],
        ),
      ),
    );
  }
}

class WalletView extends StatefulWidget {
  final bool isDark;
  final List<Payment> payments;
  final List<Expense> expenses;
  final Function(Payment) onAdd;
  final Function(Expense) onAddExpense;
  final double currentBalance;

  const WalletView({
    super.key,
    required this.isDark,
    required this.payments,
    required this.expenses,
    required this.onAdd,
    required this.onAddExpense,
    required this.currentBalance,
  });

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final List<Map<String, dynamic>> _savedCards = [
    {'type': 'Visa', 'last4': '4242', 'holder': 'John Doe'},
  ];
  final List<Map<String, dynamic>> _savedBanks = [
    {'bank': 'HDFC Bank', 'last4': '1234', 'holder': 'John Doe'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Add New Card',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Card Number',
                filled: true,
                fillColor: widget.isDark
                    ? Colors.black12
                    : Colors.grey.shade100,
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'MM/YY',
                      filled: true,
                      fillColor: widget.isDark
                          ? Colors.black12
                          : Colors.grey.shade100,
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'CVC',
                      filled: true,
                      fillColor: widget.isDark
                          ? Colors.black12
                          : Colors.grey.shade100,
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => _savedCards.add({
                  'type': 'MasterCard',
                  'last4': '8888',
                  'holder': 'User',
                }),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Card'),
          ),
        ],
      ),
    );
  }

  void _showAddBankDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Add Bank Account',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Account Number',
                filled: true,
                fillColor: widget.isDark
                    ? Colors.black12
                    : Colors.grey.shade100,
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'IFSC Code',
                filled: true,
                fillColor: widget.isDark
                    ? Colors.black12
                    : Colors.grey.shade100,
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => _savedBanks.add({
                  'bank': 'SBI',
                  'last4': '9999',
                  'holder': 'User',
                }),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Account'),
          ),
        ],
      ),
    );
  }

  void _scanQR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Scan QR to Pay')),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                Navigator.of(context).pop();
                _showUPIPaymentDialog(code ?? "Unknown Merchant");
              }
            },
          ),
        ),
      ),
    );
  }

  void _showUPIPaymentDialog(String merchantData) {
    final amountController = TextEditingController(
      text: '100',
    ); // Default amount of 100
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      child: const Icon(LucideIcons.user, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paying to',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            merchantData.split('?').first, // Clean up URL/URI
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter Amount',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0',
                    border: InputBorder.none,
                    helperText:
                        'Available Balance: ₹${widget.currentBalance.toStringAsFixed(2)}',
                    helperStyle: TextStyle(
                      color: widget.currentBalance > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                StatefulBuilder(
                  builder: (context, setBtnState) {
                    if (isProcessing) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () async {
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        if (amount <= 0) return;

                        setModalState(() => isProcessing = true);
                        setBtnState(() {});

                        // Simulate UPI network delay
                        await Future.delayed(const Duration(seconds: 2));

                        widget.onAddExpense(
                          Expense(
                            id: DateTime.now().toString(),
                            title:
                                'QR Payment: ${merchantData.split('?').first}',
                            amount: amount,
                            category: 'Other',
                            date: DateTime.now(),
                            paymentMethod: 'UPI',
                            description: 'UPI Payment via QR',
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Close bottom sheet
                          _showSuccessAnimation();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Payment',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Scaffold(
        backgroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/success_check.json',
                width: 250,
                height: 250,
                repeat: false,
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Finesight',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final upiSpends = widget.expenses
        .where((e) => e.paymentMethod.toUpperCase() == 'UPI')
        .toList();

    final historyItems = [
      ...widget.payments.map(
        (p) => {
          'title': p.purpose,
          'amount': p.amount,
          'date': p.date,
          'status': p.status,
          'isExpense': false,
        },
      ),
      ...upiSpends.map(
        (e) => {
          'title': e.title,
          'amount': e.amount,
          'date': e.date,
          'status': 'success',
          'isExpense': true,
        },
      ),
    ];

    historyItems.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQR,
        backgroundColor: Colors.green,
        icon: const Icon(LucideIcons.qrCode, color: Colors.white),
        label: const Text(
          'Scan QR & Pay',
          style: TextStyle(color: Colors.white),
        ),
      ).animate().scale(delay: 500.ms),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._savedCards.map(
            (card) => Card(
              elevation: 1,
              color: widget.isDark
                  ? Colors.blueGrey.shade900
                  : Colors.blue.shade50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  LucideIcons.creditCard,
                  color: widget.isDark ? Colors.blue.shade200 : Colors.blue,
                ),
                title: Text('${card['type']} ending in ${card['last4']}'),
                subtitle: Text(card['holder']),
                trailing: const Icon(LucideIcons.moreVertical, size: 16),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddCardDialog,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Add Debit / Credit Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isDark ? Colors.grey[800] : Colors.white,
              foregroundColor: Colors.blue,
              elevation: 0,
              side: const BorderSide(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          ..._savedBanks.map(
            (bank) => Card(
              elevation: 1,
              color: widget.isDark
                  ? Colors.green.shade900
                  : Colors.green.shade50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  LucideIcons.landmark,
                  color: widget.isDark ? Colors.green.shade200 : Colors.green,
                ),
                title: Text(bank['bank']),
                subtitle: Text('Acct: ****${bank['last4']}'),
                trailing: const Icon(LucideIcons.moreVertical, size: 16),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddBankDialog,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Add Bank Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isDark ? Colors.grey[800] : Colors.white,
              foregroundColor: Colors.green,
              elevation: 0,
              side: const BorderSide(color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Payment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (historyItems.isEmpty)
            Text(
              "No payments yet",
              style: TextStyle(
                color: widget.isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ...historyItems.map(
            (item) => Card(
              elevation: 2,
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item['status'] == 'success'
                      ? (item['isExpense'] == true
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1))
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    item['status'] == 'success'
                        ? (item['isExpense'] == true
                              ? LucideIcons.arrowUpRight
                              : LucideIcons.check)
                        : LucideIcons.x,
                    color: item['status'] == 'success'
                        ? (item['isExpense'] == true
                              ? Colors.orange
                              : Colors.green)
                        : Colors.red,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM d, y').format(item['date'] as DateTime),
                  style: TextStyle(
                    color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
                trailing: Text(
                  '${item['isExpense'] == true ? "- " : ""}${currencyFormatter.format(item['amount'])}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: item['isExpense'] == true
                        ? Colors.redAccent
                        : (widget.isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),
      ),
    );
  }
}
