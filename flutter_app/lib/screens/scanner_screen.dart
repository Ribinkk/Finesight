import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/scanner_service.dart';
import '../services/api_service.dart';
import '../models/expense.dart';

class ScannerScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const ScannerScreen({super.key, required this.user, required this.isDark});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _scan() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (!mounted) return;
      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ), // Using white on top of translucent black overlay or similar loader logic
              const SizedBox(height: 16),
              const Text(
                'Analyzing Receipt...',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );

      try {
        final data = await ScannerService.scanReceipt(image);
        if (!mounted) return;
        Navigator.pop(context); // Pop loader

        if (data.isNotEmpty) {
          _showConfirmationDialog(data);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not match receipt data.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {}
    }
  }

  void _showConfirmationDialog(Map<String, dynamic> data) {
    final titleController = TextEditingController(
      text: data['title'] ?? 'Receipt Expense',
    );
    final amountController = TextEditingController(
      text: data['amount']?.toString() ?? '',
    );
    String selectedCategory = data['category'] != null
        ? (data['category'] as String).substring(0, 1).toUpperCase() +
              (data['category'] as String).substring(1)
        : 'Food';

    // Ensure category is valid (basic list)
    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Entertainment',
      'Health',
      'Education',
      'Groceries',
      'Rent',
      'Travel',
      'Other',
    ];
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Other';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Confirm Expense',
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
                    color: widget.isDark ? Colors.grey : Colors.black54,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.isDark ? Colors.grey : Colors.black12,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ', // Assuming $ for now
                  labelStyle: TextStyle(
                    color: widget.isDark ? Colors.grey : Colors.black54,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.isDark ? Colors.grey : Colors.black12,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                dropdownColor: widget.isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedCategory = val;
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                    color: widget.isDark ? Colors.grey : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  amountController.text.isEmpty) {
                return;
              }

              final expense = Expense(
                id: DateTime.now().toString(),
                // userId removed as it is not in the model
                title: titleController.text,
                amount: double.tryParse(amountController.text) ?? 0.0,
                date: data['date'] != null
                    ? DateTime.parse(data['date'])
                    : DateTime.now(),
                category: selectedCategory,
                description: data['description'] ?? 'Scanned receipt',
                paymentMethod: 'Card',
              );

              try {
                await ApiService.addExpense(expense, widget.user?.uid ?? '');
                if (mounted && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Expense Added!'),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Receipt Scanner',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.scanLine,
                size: 64,
                color: widget.isDark ? Colors.white54 : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Scan & Save',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Instantly capture expense details from your receipts using AI.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isDark
                      ? Colors.grey[400]
                      : Colors.blueGrey[500],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            FloatingActionButton.extended(
              onPressed: _scan,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(LucideIcons.camera),
              label: const Text(
                'Start Scanning',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              elevation: 4,
              highlightElevation: 8,
            ),
          ],
        ),
      ),
    );
  }
}
