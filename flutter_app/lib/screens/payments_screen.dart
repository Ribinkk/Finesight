import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/payment.dart';

class PaymentsScreen extends StatefulWidget {
  final List<Payment> payments;
  final Function(Payment) onAdd;
  final bool isDark;

  const PaymentsScreen({
    super.key,
    required this.payments,
    required this.onAdd,
    required this.isDark,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Razorpay _razorpay;

  // Mock Payment Methods State
  final List<Map<String, dynamic>> _savedCards = [
    {'type': 'Visa', 'last4': '4242', 'holder': 'John Doe'},
  ];
  final List<Map<String, dynamic>> _savedBanks = [
    {'bank': 'HDFC Bank', 'last4': '1234', 'holder': 'John Doe'},
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    widget.onAdd(
      Payment(
        id: DateTime.now().toString(),
        amount: 1000,
        status: 'success',
        date: DateTime.now(),
        purpose: 'QR Payment',
        razorpayOrderId: response.paymentId ?? 'unknown_id',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.code} - ${response.message}"),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_YourKeyIdHere',
      'amount': 100000,
      'name': 'Expense Tracker',
      'description': 'QR Code Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
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
          appBar: AppBar(title: const Text('Scan QR Code')),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                debugPrint('Barcode found! $code');
                Navigator.of(context).pop(); // Close scanner
                // Trigger Payment Flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("QR Scanned: $code. Initiating Payment..."),
                  ),
                );
                _openCheckout();
              }
            },
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Payment Methods Section
          Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Cards List
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              elevation: 0,
              side: const BorderSide(color: Colors.blue),
            ),
          ),

          const SizedBox(height: 16),

          // Banks List
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
              backgroundColor: Colors.white,
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
          if (widget.payments.isEmpty)
            Text(
              "No payments yet",
              style: TextStyle(
                color: widget.isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ...widget.payments.map(
            (payment) => Card(
              elevation: 2,
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: payment.status == 'success'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    payment.status == 'success'
                        ? LucideIcons.check
                        : LucideIcons.x,
                    color: payment.status == 'success'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  payment.purpose,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM d, y').format(payment.date),
                  style: TextStyle(
                    color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
                trailing: Text(
                  currencyFormatter.format(payment.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
