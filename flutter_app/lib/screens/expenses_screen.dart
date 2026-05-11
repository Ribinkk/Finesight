import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../utils/currency_helper.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'package:image_picker/image_picker.dart';
import '../services/scanner_service.dart';
// import 'package:lottie/lottie.dart';

class ExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) onAdd;
  final Function(Income) onAddIncome;
  final Function(String) onDelete;
  final Function(Expense)? onEdit; // New callback for editing
  final Expense? expenseToEdit; // New parameter for the expense to edit
  final bool isDark;
  final List<String> categories;
  final String? initialType;

  const ExpensesScreen({
    super.key,
    required this.expenses,
    required this.onAdd,
    required this.onAddIncome,
    required this.onDelete,
    this.onEdit,
    this.expenseToEdit,
    required this.isDark,
    required this.categories,
    this.initialType,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // Form State
  String _type = 'Expense';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Food';
  String? _selectedSubcategory;
  String _selectedAccount = 'Cash';

  // Data Lists
  final List<String> _accounts = ['Cash', 'Bank Account', 'Credit Card'];
  List<String> _categories = [];

  // Hierarchical Category Structure
  final Map<String, List<String>> _categoryHierarchy = {
    'Food': ['Restaurant', 'Coffee & Tea', 'Fast Food', 'Groceries', 'Snacks'],
    'Transport': [
      'Fuel',
      'Public Transit',
      'Taxi & Ride',
      'Parking',
      'Vehicle Maintenance',
    ],
    'Home': ['Rent', 'Utilities', 'Maintenance', 'Furniture', 'Decor'],
    'Shopping': ['Clothing', 'Electronics', 'Books', 'Gifts', 'General'],
    'Entertainment': ['Movies', 'Gaming', 'Music', 'Sports', 'Events'],
    'Health': ['Medical', 'Pharmacy', 'Gym', 'Wellness', 'Insurance'],
    'Education': ['Courses', 'Supplies', 'Books', 'Tuition'],
    'Finance': ['Investments', 'Insurance', 'Savings', 'Taxes', 'Fees'],
    'Travel': ['Hotels', 'Flights', 'Vacation', 'Transport'],
    'Personal': ['Haircare', 'Beauty', 'Spa', 'Clothing'],
    'Pets': ['Food', 'Vet', 'Supplies', 'Grooming'],
    'Bills': ['Phone', 'Internet', 'Streaming', 'Subscriptions'],
    'Family': ['Childcare', 'Activities', 'School', 'Toys'],
    'Charity': ['Donations', 'Religious', 'Causes'],
    'Other': ['Miscellaneous'],
  };

  // Category Colors - Main categories only
  final Map<String, Color> _categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Home': Colors.brown,
    'Shopping': Colors.purple,
    'Entertainment': Colors.pink,
    'Health': Colors.red,
    'Education': Colors.green,
    'Finance': Colors.indigo,
    'Travel': Colors.cyan,
    'Personal': Color(0xFFFF4081),
    'Pets': Color(0xFFFF9800),
    'Bills': Color(0xFF00BCD4),
    'Family': Color(0xFFFFEB3B),
    'Charity': Color(0xFF8BC34A),
    'Other': Colors.grey,
  };

  // Category Icons - Main categories only
  final Map<String, IconData> _categoryIcons = {
    'Food': LucideIcons.utensils,
    'Transport': LucideIcons.car,
    'Home': LucideIcons.home,
    'Shopping': LucideIcons.shoppingBag,
    'Entertainment': LucideIcons.film,
    'Health': LucideIcons.heartPulse,
    'Education': LucideIcons.graduationCap,
    'Finance': LucideIcons.trendingUp,
    'Travel': LucideIcons.plane,
    'Personal': LucideIcons.sparkles,
    'Pets': LucideIcons.footprints,
    'Bills': LucideIcons.receipt,
    'Family': LucideIcons.baby,
    'Charity': LucideIcons.heart,
    'Other': LucideIcons.circle,
  };

  // Available options for new categories
  final List<List<Color>> _availableGradients = [
    [const Color(0xFFEF4444), const Color(0xFFF87171)], // Red
    [const Color(0xFFEC4899), const Color(0xFFF472B6)], // Pink
    [const Color(0xFFD946EF), const Color(0xFFE879F9)], // Fuchsia
    [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)], // Violet
    [const Color(0xFF6366F1), const Color(0xFF818CF8)], // Indigo
    [const Color(0xFF3B82F6), const Color(0xFF60A5FA)], // Blue
    [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)], // Sky
    [const Color(0xFF06B6D4), const Color(0xFF22D3EE)], // Cyan
    [const Color(0xFF14B8A6), const Color(0xFF2DD4BF)], // Teal
    // Dynamic gradient will be added in build if needed,
    // but for now let's just use the ones defined.
    // Actually, I'll update the specific index in build if I want it truly dynamic.
    [
      const Color(0xFF00E5FF),
      const Color(0xFF00B8D4),
    ], // Cyan (Primary) fallback
    [const Color(0xFF22C55E), const Color(0xFF4ADE80)], // Green
    [const Color(0xFF84CC16), const Color(0xFFA3E635)], // Lime
    [const Color(0xFFEAB308), const Color(0xFFFACC15)], // Yellow
    [const Color(0xFFF59E0B), const Color(0xFFFBBF24)], // Amber
    [const Color(0xFFF97316), const Color(0xFFFB923C)], // Orange
    [const Color(0xFFF43F5E), const Color(0xFFFB7185)], // Rose
    [const Color(0xFF78350F), const Color(0xFF92400E)], // Brown
    [const Color(0xFF64748B), const Color(0xFF94A3B8)], // Slate
  ];

  final List<IconData> _availableIcons = [
    LucideIcons.star,
    LucideIcons.heart,
    LucideIcons.home,
    LucideIcons.music,
    LucideIcons.coffee,
    LucideIcons.gamepad2,
    LucideIcons.dumbbell,
    LucideIcons.book,
    LucideIcons.gift,
    LucideIcons.wifi,
    LucideIcons.smartphone,
    LucideIcons.tv,
    LucideIcons.briefcase,
    LucideIcons.dollarSign,
    LucideIcons.piggyBank,
    LucideIcons.shoppingCart,
  ];

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);

    // Check if we are editing an expense
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _type = 'Expense';
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description ?? '';
      _selectedDate = expense.date;
      _selectedTime = TimeOfDay.fromDateTime(expense.date);

      // Parse Category (Format: "Main - Sub" or "Main")
      if (expense.category.contains(' - ')) {
        final parts = expense.category.split(' - ');
        _selectedCategory = parts[0];
        if (parts.length > 1) {
          _selectedSubcategory = parts[1];
        }
      } else {
        _selectedCategory = expense.category;
      }

      // Map payment method
      if (expense.paymentMethod == 'UPI') {
        _selectedAccount = 'Bank Account';
      } else {
        if (_accounts.contains(expense.paymentMethod)) {
          _selectedAccount = expense.paymentMethod;
        } else {
          _selectedAccount = 'Cash'; // Default fallback
        }
      }
    } else {
      // Default initialization for new entry
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
      if (widget.initialType != null) {
        _type = widget.initialType!;
      }
    }
  }

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);
    final enteredDescription = _descriptionController.text;

    if (enteredTitle.isEmpty || enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid title and amount'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Map accounts to standardized payment methods for digital tracking
    String paymentMethod = _selectedAccount;
    if (_selectedAccount == 'Bank Account') {
      paymentMethod =
          'UPI'; // Standardize digital payments as 'UPI' for the Total Sent stat
    }

    if (_type == 'Expense') {
      // Format: "MainCategory - Subcategory" or just "MainCategory" if no sub
      final categoryLabel = _selectedSubcategory != null
          ? '$_selectedCategory - $_selectedSubcategory'
          : _selectedCategory;

      final expense = Expense(
        id:
            widget.expenseToEdit?.id ??
            DateTime.now().toString(), // Use existing ID if editing
        title: enteredTitle,
        amount: enteredAmount,
        category: categoryLabel,
        date: combinedDateTime,
        paymentMethod: paymentMethod,
        description: enteredDescription,
      );

      if (widget.expenseToEdit != null && widget.onEdit != null) {
        widget.onEdit!(expense);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense Updated!')));
      } else {
        widget.onAdd(expense);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense Added!')));
      }
    } else {
      widget.onAddIncome(
        Income(
          id: DateTime.now().toString(),
          source: enteredTitle,
          amount: enteredAmount,
          date: combinedDateTime,
          description: enteredDescription.isEmpty
              ? 'Income'
              : enteredDescription,
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Income Added!')));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  Future<void> _scanReceipt() async {
    final ImagePicker picker = ImagePicker();
    // Show modal to choose Camera or Gallery
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () async {
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx, image);
                }
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () async {
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx, image);
                }
              },
            ),
          ],
        ),
      ),
    );

    if (image != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Scanning Receipt...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );

      final scannedData = await ScannerService.scanReceipt(image);

      if (!mounted) return;
      Navigator.pop(context); // Close loader

      if (scannedData.isNotEmpty) {
        setState(() {
          if (scannedData['title'] != null) {
            _titleController.text = scannedData['title'];
          }
          if (scannedData['amount'] != null) {
            _amountController.text = scannedData['amount'].toString();
          }
          if (scannedData['category'] != null) {
            // Try to match category
            String cat = scannedData['category'];
            // Capitalize first letter
            if (cat.isNotEmpty) {
              cat = cat[0].toUpperCase() + cat.substring(1).toLowerCase();
            }

            // Check if cat exists in _categories or _categoryHierarchy keys
            if (_categories.contains(cat) ||
                _categoryHierarchy.containsKey(cat)) {
              _selectedCategory = cat;
            } else {
              // Fuzzy or basic mapping could go here, or default to Other
              _selectedCategory = "Other";
            }
          }
          if (scannedData['date'] != null) {
            try {
              _selectedDate = DateTime.parse(scannedData['date']);
            } catch (e) {
              /* ignore */
            }
          }
          if (scannedData['description'] != null) {
            _descriptionController.text = scannedData['description'];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Receipt Scanned! Data pre-filled.'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not extract data from receipt.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog(List<List<Color>> dynamicGradients) {
    final categoryController = TextEditingController();
    Color tempColor = _availableGradients.first[0];
    IconData tempIcon = _availableIcons.first;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              "New Category",
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
                    controller: categoryController,
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Category Name",
                      hintStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: widget.isDark
                          ? Colors.black12
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select Color",
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dynamicGradients.length,
                      itemBuilder: (ctx, index) {
                        final gradient = dynamicGradients[index];
                        final isSelected = tempColor == gradient[0];
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => tempColor = gradient[0]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: gradient[0].withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    LucideIcons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select Icon",
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableIcons.length,
                      itemBuilder: (ctx, index) {
                        final icon = _availableIcons[index];
                        return GestureDetector(
                          onTap: () => setDialogState(() => tempIcon = icon),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: tempIcon == icon
                                  ? Border.all(
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              icon,
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black87,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final newCategory = categoryController.text.trim();
                  if (newCategory.isNotEmpty) {
                    setState(() {
                      if (!_categories.contains(newCategory)) {
                        _categories = [..._categories, newCategory];
                        _categoryColors[newCategory] = tempColor;
                        _categoryIcons[newCategory] = tempIcon;
                        _selectedCategory = newCategory;

                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text("Category '$newCategory' Added!"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text("Category already exists!"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    });
                    Navigator.pop(dialogContext);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isExpense = _type == 'Expense';
    final primaryColor = Theme.of(context).primaryColor;

    // Update the Primary/Cyan gradient dynamically
    final dynamicGradients = List<List<Color>>.from(_availableGradients);
    dynamicGradients[9] = [primaryColor, primaryColor.withValues(alpha: 0.7)];

    Color activeColor = isExpense ? Colors.redAccent : primaryColor;
    Color bgColor = widget.isDark
        ? const Color(0xFF020617)
        : const Color(0xFFF5F7FA);
    Color cardColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = widget.isDark ? Colors.white : Colors.black;
    Color hintColor = widget.isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.expenseToEdit != null
              ? 'Update Transaction'
              : 'Add Transaction',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isExpense)
            TextButton.icon(
              onPressed: _scanReceipt,
              icon: Icon(LucideIcons.scanLine, size: 20, color: primaryColor),
              label: Text(
                "Scan Receipt",
                style: TextStyle(color: primaryColor),
              ),
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Toggle
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 'Income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isExpense
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: !isExpense
                              ? Border.all(color: Colors.green)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: !isExpense ? Colors.green : hintColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 'Expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isExpense
                              ? Colors.redAccent.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isExpense
                              ? Border.all(color: Colors.redAccent)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: isExpense ? Colors.redAccent : hintColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText:
                    '${CurrencyHelper.symbols[CurrencyHelper.selectedCurrency] ?? '₹'} ',
                prefixStyle: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  color: hintColor.withValues(alpha: 0.5),
                  fontSize: 32,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),

            // Title & Description
            TextField(
              controller: _titleController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _presentDatePicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            color: hintColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM d, y').format(_selectedDate),
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _presentTimePicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.clock, color: hintColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedAccount,
                    dropdownColor: cardColor,
                    decoration: InputDecoration(
                      labelText: 'Account',
                      labelStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    items: _accounts
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedAccount = val!),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _showAddCategoryDialog(dynamicGradients),
                    icon: const Icon(LucideIcons.plusCircle),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Categories - Main Categories
            if (isExpense) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddCategoryDialog(dynamicGradients),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text("Add New"),
                    style: TextButton.styleFrom(foregroundColor: activeColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main Categories Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categoryHierarchy.keys.map((category) {
                  final isSelected = _selectedCategory == category;
                  final color = _categoryColors[category] ?? Colors.grey;
                  final icon = _categoryIcons[category] ?? LucideIcons.circle;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _selectedSubcategory =
                            null; // Reset subcategory when changing main
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : (widget.isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: color, width: 2)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? color : textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? color : textColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Subcategories - shown only when a main category is selected
              if (_categoryHierarchy[_selectedCategory] != null) ...[
                Text(
                  "$_selectedCategory Subcategories",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categoryHierarchy[_selectedCategory]!.map((sub) {
                    final isSelected = _selectedSubcategory == sub;
                    final mainColor =
                        _categoryColors[_selectedCategory] ?? Colors.grey;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubcategory = sub;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? mainColor.withValues(alpha: 0.3)
                              : (widget.isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: mainColor, width: 1.5)
                              : Border.all(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                        ),
                        child: Text(
                          sub,
                          style: TextStyle(
                            color: isSelected ? mainColor : textColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 32),
            ],

            // Submit Button
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: primaryColor.withValues(alpha: 0.4),
              ),
              child: Text(
                isExpense ? 'Add Expense' : 'Add Income',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
