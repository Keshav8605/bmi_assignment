import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import '../viewmodels/user_viewmodel.dart';

class PdfService {
  Future<pw.Document> _generateReport(UserModel user, UserViewModel userVM) async {
    final pdf = pw.Document();

    final bmiVal = userVM.bmiValue;
    final category = userVM.bmiCategory;
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(now),
            pw.SizedBox(height: 24),
            _buildProfileSection(user, bmiVal, category),
            pw.SizedBox(height: 32),
            _buildHistoryTable(user),
            pw.SizedBox(height: 32),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(DateTime date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'VERO — BMI REPORT',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated: ${date.day}/${date.month}/${date.year}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _buildProfileSection(UserModel user, double bmi, String category) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Profile Overview', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Gender', user.gender),
              _buildInfoColumn('Height', '${user.height.toStringAsFixed(1)} cm'),
              _buildInfoColumn('Weight', '${user.weight.toStringAsFixed(1)} kg'),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Current BMI', bmi.toStringAsFixed(1)),
              _buildInfoColumn('Category', category, isHighlight: true),
              _buildInfoColumn(
                'Target Weight',
                user.targetWeight != null
                    ? '${user.targetWeight!.toStringAsFixed(1)} kg'
                    : 'Not set',
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoColumn(String label, String value, {bool isHighlight = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: isHighlight ? PdfColors.blue800 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildHistoryTable(UserModel user) {
    if (user.history.isEmpty) {
      return pw.Text('No history records found.', style: const pw.TextStyle(color: PdfColors.grey700));
    }

    final sortedHistory = List.of(user.history)
      ..sort((a, b) => b.date.compareTo(a.date));

    final heightInMeters = user.height / 100;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Weight & BMI History', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Weight (kg)', 'BMI'],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
          },
          data: sortedHistory.map((record) {
            final bmi = record.weight / (heightInMeters * heightInMeters);
            return [
              '${record.date.day}/${record.date.month}/${record.date.year}',
              record.weight.toStringAsFixed(1),
              bmi.toStringAsFixed(1),
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Text(
          'Vero Health App — Confidentially generated for user',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  Future<File> _savePdf(UserModel user, UserViewModel userVM) async {
    final pdf = await _generateReport(user, userVM);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Vero_Health_Report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<String?> downloadReport(UserModel user, UserViewModel userVM) async {
    try {
      final pdf = await _generateReport(user, userVM);
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final filePath = '${directory.path}/Vero_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }

  Future<void> shareReport(UserModel user, UserViewModel userVM) async {
    try {
      final file = await _savePdf(user, userVM);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is my latest Vero Health & BMI Report. Stay healthy! 🚀',
        subject: 'Vero Health Report',
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }
}
