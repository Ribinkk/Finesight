import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';

class ExportScreen extends StatelessWidget {
  final UserModel? user;
  final bool isDark;

  const ExportScreen({super.key, required this.user, required this.isDark});

  Future<void> _exportCSV(BuildContext context) async {
    if (user == null) return;
    try {
      final expenses = await ApiService.getExpenses(user!.uid);
      await ExportService.exportToCSV(expenses);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV Exported Successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export Failed: $e')));
      }
    }
  }

  Future<void> _exportPDF(BuildContext context) async {
    if (user == null) return;
    try {
      final expenses = await ApiService.getExpenses(user!.uid);
      await ExportService.exportToPDF(expenses);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Exported Successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Export Data',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.downloadCloud,
              size: 80,
              color: isDark ? Colors.white10 : Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Download Your Data',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Save your expenses to analyze externally.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            _buildExportButton(
              label: 'Export CSV',
              icon: LucideIcons.fileSpreadsheet,
              color: Colors.green,
              onTap: () => _exportCSV(context),
            ),
            const SizedBox(height: 16),
            _buildExportButton(
              label: 'Export PDF',
              icon: LucideIcons.fileText,
              color: Colors.red,
              onTap: () => _exportPDF(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
