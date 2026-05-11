import 'package:flutter/material.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';

import 'recurring_screen.dart';
import 'split_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart'; // Import SettingsScreen

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onLogout;
  final List<String> categories;
  final Function(String) onAddCategory;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.categories,
    required this.onAddCategory,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Currency is now handled in Settings (globally) or here if we want local override.
  // For now, removing local currency state as it didn't do anything globally.

  void _showManageCategoriesDialog() {
    final categoryController = TextEditingController();
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text(
              'Manage Categories',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          LucideIcons.plus,
                          color: Theme.of(context).primaryColor,
                        ),
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
                      color: isDark ? Colors.white : Colors.black,
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
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                backgroundColor: isDark
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.5)
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withAlpha(50),
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
                child: Text(
                  'Close',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showExportDialog() async {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

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
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Export Data',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  LucideIcons.fileSpreadsheet,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  'Export to CSV',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
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
                    color: isDark ? Colors.white : Colors.black87,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
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
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            widget.user?.email ?? 'No email',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Feature Section
          _buildSettingsTile(
            context,
            icon: LucideIcons.repeat,
            title: 'Subscriptions',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecurringScreen(
                  user: widget.user,
                  isDark: isDark,
                  categories: widget.categories,
                ),
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.list,
            title: 'Manage Categories',
            isDark: isDark,
            onTap: _showManageCategoriesDialog,
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.download,
            title: 'Export Data',
            isDark: isDark,
            onTap: _showExportDialog,
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.users,
            title: 'Split Expenses',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SplitScreen(user: widget.user, isDark: isDark),
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.target,
            title: 'Savings Goals',
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalsScreen(user: widget.user, isDark: isDark),
              ),
            ),
          ),

          // Settings Shortcut
          _buildSettingsTile(
            context,
            icon: LucideIcons.settings,
            title: 'App Settings',
            isDark: isDark,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(user: widget.user),
              ),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Removed Navigator.pop as this is a tab, not a modal
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
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? Colors.grey : Colors.grey.shade400,
            ),
      ),
    );
  }
}
