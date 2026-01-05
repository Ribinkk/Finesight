import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/income.dart';

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
  String _selectedAccount = 'Cash';

  // Data Lists
  final List<String> _accounts = ['Cash', 'Bank Account', 'Credit Card'];
  List<String> _categories = [];
  
  // Category Maps
  Map<String, Color> _categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Utilities': Colors.teal,
    'Entertainment': Colors.pink,
    'Shopping': Colors.purple,
    'Health': Colors.red,
    'Education': Colors.green,
    'Groceries': Colors.lightGreen,
    'Rent': Colors.brown,
    'Investments': Colors.indigo,
    'Travel': Colors.cyan,
    'Other': Colors.grey,
  };

  Map<String, IconData> _categoryIcons = {
    'Food': LucideIcons.utensils,
    'Transport': LucideIcons.car,
    'Utilities': LucideIcons.zap,
    'Entertainment': LucideIcons.film,
    'Shopping': LucideIcons.shoppingBag,
    'Health': LucideIcons.heartPulse,
    'Education': LucideIcons.graduationCap,
    'Groceries': LucideIcons.shoppingCart,
    'Rent': LucideIcons.home,
    'Investments': LucideIcons.trendingUp,
    'Travel': LucideIcons.plane,
    'Other': LucideIcons.circle,
  };

  // Available options for new categories
  final List<Color> _availableColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  final List<IconData> _availableIcons = [
    LucideIcons.star, LucideIcons.heart, LucideIcons.home, LucideIcons.music,
    LucideIcons.coffee, LucideIcons.gamepad2, LucideIcons.dumbbell, LucideIcons.book,
    LucideIcons.gift, LucideIcons.wifi, LucideIcons.smartphone, LucideIcons.tv,
    LucideIcons.briefcase, LucideIcons.dollarSign, LucideIcons.piggyBank, LucideIcons.shoppingCart,
  ];

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
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

    if (_type == 'Expense') {
      widget.onAdd(
        Expense(
          id: DateTime.now().toString(),
          title: enteredTitle,
          amount: enteredAmount,
          category: _selectedCategory,
          date: combinedDateTime,
          paymentMethod: _selectedAccount,
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
          description: enteredDescription.isEmpty ? 'Income' : enteredDescription,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_type Added Successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
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
      }
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
      }
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  void _showAddAccountDialog() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add Account Feature Coming Soon!")));
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
            backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text("New Category", style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: categoryController,
                    style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Category Name",
                      hintStyle: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade400),
                      filled: true,
                      fillColor: widget.isDark ? Colors.black12 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Select Color", style: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade600, fontSize: 12)),
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
                              border: tempColor == color ? Border.all(color: Colors.white, width: 3) : null,
                            ),
                            child: tempColor == color ? const Icon(LucideIcons.check, color: Colors.white, size: 20) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Select Icon", style: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade600, fontSize: 12)),
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
                              color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: tempIcon == icon ? Border.all(color: widget.isDark ? Colors.white : Colors.black, width: 2) : null,
                            ),
                            child: Icon(icon, color: widget.isDark ? Colors.white : Colors.black87, size: 20),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  final newCategory = categoryController.text.trim();
                  if (newCategory.isNotEmpty) {
                    // Update Parent State
                    this.setState(() {
                      if (!_categories.contains(newCategory)) {
                        _categories = [..._categories, newCategory];
                        _categoryColors[newCategory] = tempColor;
                        _categoryIcons[newCategory] = tempIcon;
                        _selectedCategory = newCategory;
                        
                        ScaffoldMessenger.of(this.context).showSnackBar( // Use parent context
                           SnackBar(content: Text("Category '$newCategory' Added!"), duration: const Duration(seconds: 1)),
                        );
                      } else {
                         ScaffoldMessenger.of(this.context).showSnackBar(
                           const SnackBar(content: Text("Category already exists!"), backgroundColor: Colors.orange),
                        );
                      }
                    });
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text("Add"),
              )
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isExpense = _type == 'Expense';
    Color activeColor = isExpense ? Colors.redAccent : Colors.green;
    Color bgColor = widget.isDark ? const Color(0xFF020617) : const Color(0xFFF5F7FA);
    Color cardColor = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = widget.isDark ? Colors.white : Colors.black;
    Color hintColor = widget.isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Add Transaction', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                          color: !isExpense ? Colors.green.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: !isExpense ? Border.all(color: Colors.green) : null,
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
                          color: isExpense ? Colors.redAccent.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isExpense ? Border.all(color: Colors.redAccent) : null,
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
              style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
                hintText: '0',
                hintStyle: TextStyle(color: hintColor.withOpacity(0.5), fontSize: 32),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                           Icon(LucideIcons.calendar, color: hintColor, size: 20),
                           const SizedBox(width: 8),
                           Text(DateFormat('MMM d, y').format(_selectedDate), style: TextStyle(color: textColor)),
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
                           Text(_selectedTime.format(context), style: TextStyle(color: textColor)),
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
                     value: _selectedAccount,
                     dropdownColor: cardColor,
                     decoration: InputDecoration(
                       labelText: 'Account',
                        labelStyle: TextStyle(color: hintColor),
                       filled: true,
                       fillColor: cardColor,
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                     ),
                     style: TextStyle(color: textColor),
                     items: _accounts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                 )
               ],
             ),
             const SizedBox(height: 32),

             // Categories
             if (isExpense) ...[
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Categories", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                   TextButton.icon(
                     onPressed: _showAddCategoryDialog,
                     icon: const Icon(LucideIcons.plus, size: 16),
                     label: const Text("Add New"),
                     style: TextButton.styleFrom(foregroundColor: activeColor),
                   )
                 ],
               ),
               const SizedBox(height: 16),
               Wrap(
                 spacing: 12,
                 runSpacing: 12,
                 children: _categories.map((category) {
                   bool isSelected = _selectedCategory == category;
                   Color catColor = _categoryColors[category] ?? Colors.grey;
                   IconData catIcon = _categoryIcons[category] ?? LucideIcons.circle;
                   
                   return GestureDetector(
                     onTap: () => setState(() => _selectedCategory = category),
                     child: Container(
                       width: 100, // Fixed width for consistent grid
                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                       decoration: BoxDecoration(
                         color: isSelected ? catColor : catColor.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(16),
                         border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                         boxShadow: isSelected ? [BoxShadow(color: catColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
                       ),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(
                             catIcon,
                             color: isSelected ? Colors.white : catColor,
                             size: 24,
                           ),
                           const SizedBox(height: 8),
                           Text(
                             category,
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                             style: TextStyle(
                               color: isSelected ? Colors.white : textColor,
                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                               fontSize: 12,
                             ),
                           ),
                         ],
                       ),
                     ),
                   );
                 }).toList(),
               ),
               const SizedBox(height: 32),
             ],

             // Submit Button
             ElevatedButton(
               onPressed: _submitData,
               style: ElevatedButton.styleFrom(
                 backgroundColor: activeColor,
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(vertical: 18),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 elevation: 8,
                 shadowColor: activeColor.withOpacity(0.4),
               ),
               child: Text(
                 isExpense ? 'Add Expense' : 'Add Income',
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
               ),
             ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
