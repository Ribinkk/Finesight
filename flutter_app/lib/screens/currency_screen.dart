import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/currency_helper.dart';
import '../models/user_model.dart';

class CurrencyScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const CurrencyScreen({super.key, required this.user, required this.isDark});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  void _onSelect(String code) {
    setState(() {
      CurrencyHelper.selectedCurrency = code;
    });
    // Ideally persist to Prefs here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Currency changed to $code')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Currency Converter',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: CurrencyHelper.rates.keys.map((code) {
          final isSelected = CurrencyHelper.selectedCurrency == code;
          return Card(
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: Color(0xFF009B6E), width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              onTap: () => _onSelect(code),
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF009B6E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  CurrencyHelper.symbols[code]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009B6E),
                  ),
                ),
              ),
              title: Text(
                code,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      LucideIcons.checkCircle,
                      color: Color(0xFF009B6E),
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
