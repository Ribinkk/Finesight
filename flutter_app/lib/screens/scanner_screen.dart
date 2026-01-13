import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';

class ScannerScreen extends StatefulWidget {
  final UserModel? user;
  final bool isDark;

  const ScannerScreen({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _scan() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
     if (image != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt Processed! (Simulated)')));
      // Logic to return data could go here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF020617) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Receipt Scanner', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.scanLine, size: 80, color: widget.isDark ? Colors.white10 : Colors.grey.shade300),
            const SizedBox(height: 24),
            Text('Scan Receipts', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 12),
             Text('Capture receipts and automatically\nextract expense details.', textAlign: TextAlign.center, style: TextStyle(color: widget.isDark ? Colors.white60 : Colors.grey.shade600)),
             const SizedBox(height: 32),
             FloatingActionButton.extended(
               onPressed: _scan,
               backgroundColor: const Color(0xFF009B6E),
               foregroundColor: Colors.white,
               icon: const Icon(LucideIcons.camera),
               label: const Text('Start Scanning'),
             )
          ],
        ),
      ),
    );
  }
}
