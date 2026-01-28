import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
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
  final bool isDark;
  final List<String> categories;

  const ExpensesScreen({
    super.key,
    required this.expenses,
    required this.onAdd,
    required this.onAddIncome,
    required this.onDelete,
    required this.isDark,
    required this.categories,
    this.initialType,
  });

  final String? initialType;

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
  String? _selectedSubcategory; // New: for subcategory selection
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
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
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
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
    if (widget.initialType != null) {
      _type = widget.initialType!;
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

      widget.onAdd(
        Expense(
          id: DateTime.now().toString(),
          title: enteredTitle,
          amount: enteredAmount,
          category: categoryLabel,
          date: combinedDateTime,
          paymentMethod: paymentMethod,
          description: enteredDescription,
        ),
      );
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
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$_type Added!')));
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

  void _showAddAccountDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add Account Feature Coming Soon!")),
    );
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
              const CircularProgressIndicator(color: Colors.green),
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
          const SnackBar(
            content: Text('Receipt Scanned! Data pre-filled.'),
            backgroundColor: Colors.green,
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

  void _showAddCategoryDialog() {
    final categoryController = TextEditingController();
    Color tempColor = _availableColors.first;
    IconData tempIcon = _availableIcons.first;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            title: Text(
              "New Category",
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
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
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableColors.length,
                      itemBuilder: (ctx, index) {
                        final color = _availableColors[index];
                        return GestureDetector(
                          onTap: () => setDialogState(() => tempColor = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: tempColor == color
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: tempColor == color
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
                    // Update Parent State
                    setState(() {
                      if (!_categories.contains(newCategory)) {
                        _categories = [..._categories, newCategory];
                        _categoryColors[newCategory] = tempColor;
                        _categoryIcons[newCategory] = tempIcon;
                        _selectedCategory = newCategory;

                        ScaffoldMessenger.of(this.context).showSnackBar(
                          // Use parent context
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
          'Add Transaction',
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
              icon: const Icon(LucideIcons.scanLine, size: 20),
              label: const Text("Scan Receipt"),
              style: TextButton.styleFrom(foregroundColor: textColor),
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
                prefixText: '₹ ',
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
                    onPressed: _showAddAccountDialog,
                    icon: const Icon(LucideIcons.plus),
                    color: activeColor,
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
                    onPressed: _showAddCategoryDialog,
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
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: activeColor.withValues(alpha: 0.4),
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
