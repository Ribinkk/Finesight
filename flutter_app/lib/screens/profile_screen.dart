import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/budget.dart';
import '../services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onLogout;
  final Function() onThemeToggle;
  final bool isDark;
  final List<String> categories;
  final Function(String) onAddCategory;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onThemeToggle,
    required this.isDark,
    required this.categories,
    required this.onAddCategory,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedCurrency = 'INR';

  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'AUD', 'CAD'];

  void _showCurrencyPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text('Select Currency', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies.map((currency) => ListTile(
            title: Text(currency, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87)),
            onTap: () {
              setState(() {
                _selectedCurrency = currency;
              });
              Navigator.of(ctx).pop();
            },
            trailing: _selectedCurrency == currency ? const Icon(LucideIcons.check, color: Colors.green, size: 20) : null,
          )).toList(),
        ),
      ),
    );
  }

  void _showManageCategoriesDialog() {
    final _categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text('Manage Categories', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
            content: SizedBox(
               width: double.maxFinite,
               child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'New Category',
                      labelStyle: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade600),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                      suffixIcon: IconButton(
                        icon: const Icon(LucideIcons.plus, color: Colors.green),
                        onPressed: () {
                           if (_categoryController.text.trim().isNotEmpty) {
                             widget.onAddCategory(_categoryController.text.trim());
                             _categoryController.clear();
                             setState(() {}); 
                           }
                        },
                      ),
                    ),
                    style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.categories.map((cat) => Chip(
                          label: Text(cat, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87)),
                          backgroundColor: widget.isDark ? Colors.green.shade900.withOpacity(0.5) : Colors.green.shade50,
                          side: BorderSide.none,
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showBudgetGoalsDialog() {
    final userId = widget.user?.uid ?? '';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return FutureBuilder<List<Budget>>(
            future: ApiService.getBudgets(userId),
            builder: (context, snapshot) {
              final budgets = snapshot.data ?? [];
              final budgetMap = <String, double>{};
              for (var b in budgets) {
                budgetMap[b.category] = b.limit;
              }
              
              return AlertDialog(
                backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                title: Row(
                  children: [
                    Icon(LucideIcons.target, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text('Set Budget Goals', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: widget.categories.length,
                          itemBuilder: (context, index) {
                            final category = widget.categories[index];
                            final currentLimit = budgetMap[category];
                            
                            return _BudgetCategoryTile(
                              category: category,
                              currentLimit: currentLimit,
                              isDark: widget.isDark,
                              onSave: (limit) async {
                                final now = DateTime.now();
                                final budget = Budget(
                                  id: const Uuid().v4(),
                                  category: category,
                                  limit: limit,
                                  month: now.month,
                                  year: now.year,
                                );
                                try {
                                  await ApiService.setBudget(budget, userId);
                                  setDialogState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Budget set for $category')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to set budget: $e')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Done', style: TextStyle(color: Colors.green)),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF020617) : Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.user?.pictureUrl != null
                  ? NetworkImage(widget.user!.pictureUrl.toString())
                  : null,
              child: widget.user?.pictureUrl == null
                  ? const Icon(LucideIcons.user, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.user?.name ?? 'Guest User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              widget.user?.email ?? 'No email',
              style: TextStyle(
                color: widget.isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            
            // Settings Section
            _buildSettingsTile(
              context,
              icon: widget.isDark ? LucideIcons.sun : LucideIcons.moon,
              title: 'Dark Mode',
              trailing: Switch(
                value: widget.isDark,
                onChanged: (_) => widget.onThemeToggle(),
                activeColor: Colors.green,
              ),
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.bell,
              title: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (_) {}, // Mock
                activeColor: Colors.green,
              ),
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.currency,
              title: 'Currency',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCurrency, style: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  Icon(LucideIcons.chevronRight, size: 20, color: widget.isDark ? Colors.grey : Colors.grey.shade400),
                ],
              ),
              onTap: _showCurrencyPicker,
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.list,
              title: 'Manage Categories',
              onTap: _showManageCategoriesDialog,
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.target,
              title: 'Set Budget Goals',
              onTap: _showBudgetGoalsDialog,
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.helpCircle,
              title: 'Help & Support',
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Close Profile Screen first
                widget.onLogout();
              },
              icon: const Icon(LucideIcons.logOut),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: widget.isDark ? Colors.transparent : Colors.grey.shade200)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: widget.isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing: trailing ?? Icon(LucideIcons.chevronRight, size: 20, color: widget.isDark ? Colors.grey : Colors.grey.shade400),
      ),
    );
  }
}

class _BudgetCategoryTile extends StatefulWidget {
  final String category;
  final double? currentLimit;
  final bool isDark;
  final Future<void> Function(double) onSave;

  const _BudgetCategoryTile({
    required this.category,
    required this.currentLimit,
    required this.isDark,
    required this.onSave,
  });

  @override
  State<_BudgetCategoryTile> createState() => _BudgetCategoryTileState();
}

class _BudgetCategoryTileState extends State<_BudgetCategoryTile> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentLimit?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              widget.category,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: widget.isDark ? Colors.grey : Colors.grey.shade600),
                hintText: 'Limit',
                hintStyle: TextStyle(color: widget.isDark ? Colors.grey.shade600 : Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(LucideIcons.save, color: Colors.green),
                  onPressed: () async {
                    final value = double.tryParse(_controller.text);
                    if (value != null && value > 0) {
                      setState(() => _isSaving = true);
                      await widget.onSave(value);
                      setState(() => _isSaving = false);
                    }
                  },
                ),
        ],
      ),
    );
  }
}
