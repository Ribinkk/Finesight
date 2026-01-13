import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class ScannerService {
  static Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      String fullText = recognizedText.text;

      // Basic regex for amount (e.g. 120.00, $120.00, 1,200.00)
      // Looking for the largest number reasonably, or specific keywords like "Total"
      double? amount;

      final totalRegex = RegExp(
        r'(total|amount|due|grand total)[\s:]*[$₹]?\s*([0-9.,]+)',
        caseSensitive: false,
      );

      // Try to find "Total: 123.45"
      final totalMatch = totalRegex.firstMatch(fullText);
      if (totalMatch != null) {
        String amtStr = totalMatch.group(2)!.replaceAll(',', '');
        amount = double.tryParse(amtStr);
      }

      // If no explicit total, maybe just look for numbers? Too risky.
      // Let's stick to simple extraction.

      // Date extraction (YYYY-MM-DD, DD/MM/YYYY, etc.)
      DateTime? date;
      final dateRegex = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
      final dateMatch = dateRegex.firstMatch(fullText);
      if (dateMatch != null) {
        String dateStr = dateMatch.group(1)!;
        // Try parsing common formats
        try {
          if (dateStr.contains('/')) {
            if (dateStr.split('/')[2].length == 4) {
              date = DateFormat('dd/MM/yyyy').parse(dateStr);
            } else {
              date = DateFormat('dd/MM/yy').parse(dateStr);
            }
          } else if (dateStr.contains('-')) {
            date = DateTime.tryParse(dateStr); // ISO
          }
        } catch (e) {
          // ignore
        }
      }

      return {
        'amount': amount,
        'date': date,
        'title':
            'Scanned Receipt', // Maybe extract Merchant name (usually first line)
        'rawText': fullText,
      };
    } catch (e) {
      return {};
    } finally {
      textRecognizer.close();
    }
  }
}
