import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
// import 'dart:io'; // Disabled for Web compatibility
// import 'package:path_provider/path_provider.dart'; // Disabled for Web compatibility
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<void> exportToCSV(List<Expense> expenses) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Date",
      "Title",
      "Category",
      "Amount",
      "Payment Method",
      "Description",
    ]);

    // Data
    for (var expense in expenses) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(expense.date),
        expense.title,
        expense.category,
        expense.amount,
        expense.paymentMethod,
        expense.description ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      // Web Download
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "expenses_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv",
        )
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      debugPrint("Mobile export not supported in this web-optimized build.");
    }
  }

  static Future<void> exportToPDF(List<Expense> expenses) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Expense Report',
                  style: pw.TextStyle(font: boldFont, fontSize: 24),
                ),
                pw.Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.now()),
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ["Date", "Title", "Category", "Amount", "Method"],
            data: expenses
                .map(
                  (e) => [
                    DateFormat('MMM dd').format(e.date),
                    e.title,
                    e.category,
                    e.amount.toStringAsFixed(2),
                    e.paymentMethod,
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF00E5FF),
            ),
            cellStyle: pw.TextStyle(font: font, fontSize: 10),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total: ',
                style: pw.TextStyle(font: boldFont, fontSize: 14),
              ),
              pw.Text(
                expenses
                    .fold(0.0, (sum, e) => sum + e.amount)
                    .toStringAsFixed(2),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Printing.sharePdf works well on web too, it opens the print dialog or pdf viewer
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'expense_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
