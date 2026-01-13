import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'recurring_screen.dart';
import 'split_screen.dart';
import 'goals_screen.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';

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
        title: Text(
          'Select Currency',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies
              .map(
                (currency) => ListTile(
                  title: Text(
                    currency,
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                    Navigator.of(ctx).pop();
                  },
                  trailing: _selectedCurrency == currency
                      ? const Icon(
                          LucideIcons.check,
                          color: Colors.green,
                          size: 20,
                        )
                      : null,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showManageCategoriesDialog() {
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: widget.isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            title: Text(
              'Manage Categories',
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'New Category',
                      labelStyle: TextStyle(
                        color: widget.isDark
                            ? Colors.grey
                            : Colors.grey.shade600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: widget.isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(LucideIcons.plus, color: Colors.green),
                        onPressed: () {
                          if (categoryController.text.trim().isNotEmpty) {
                            widget.onAddCategory(
                              categoryController.text.trim(),
                            );
                            categoryController.clear();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.categories
                            .map(
                              (cat) => Chip(
                                label: Text(
                                  cat,
                                  style: TextStyle(
                                    color: widget.isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                backgroundColor: widget.isDark
                                    ? Colors.green.shade900.withValues(
                                        alpha: 0.5,
                                      )
                                    : Colors.green.shade50,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showExportDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final expenses = await ApiService.getExpenses(widget.user!.uid);
      if (mounted) Navigator.pop(context); // Close loading

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: widget.isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          title: Text(
            'Export Data',
            style: TextStyle(
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  LucideIcons.fileSpreadsheet,
                  color: Colors.green,
                ),
                title: Text(
                  'Export to CSV',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ExportService.exportToCSV(expenses);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exported CSV successfully'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.fileText, color: Colors.red),
                title: Text(
                  'Export to PDF',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ExportService.exportToPDF(expenses);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : Colors.green.shade50,
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
                activeThumbColor: Colors.green,
              ),
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.bell,
              title: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeThumbColor: Colors.green,
              ),
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.repeat,
              title: 'Subscriptions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecurringScreen(
                    user: widget.user,
                    isDark: widget.isDark,
                    categories: widget.categories,
                  ),
                ),
              ),
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.currency,
              title: 'Currency',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCurrency,
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: widget.isDark ? Colors.grey : Colors.grey.shade400,
                  ),
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
              icon: LucideIcons.download,
              title: 'Export Data',
              onTap: _showExportDialog,
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.users,
              title: 'Split Expenses',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SplitScreen(user: widget.user, isDark: widget.isDark),
                ),
              ),
            ),
            _buildSettingsTile(
              context,
              icon: LucideIcons.target,
              title: 'Savings Goals',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GoalsScreen(user: widget.user, isDark: widget.isDark),
                ),
              ),
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

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.isDark ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
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
        trailing:
            trailing ??
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: widget.isDark ? Colors.grey : Colors.grey.shade400,
            ),
      ),
    );
  }
}
