import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/datasource/acp_dummy_data.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';

class AcpReportGenerator {
  static Future<void> generate(BuildContext context, List<AcpCoachModel> coaches) async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 3, 12),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 3, 5),
        end: DateTime(2026, 3, 12),
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );

    if (range == null) return;
    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: ColorConstants.primary),
              const SizedBox(height: 16),
              Text('Generating Report...', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                '${_fmt(range.start)} → ${_fmt(range.end)}',
                style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final file = await _buildExcel(coaches, range);
      if (context.mounted) Navigator.pop(context); // close loading

      if (!context.mounted) return;
      _showSuccess(context, file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<File> _buildExcel(List<AcpCoachModel> coaches, DateTimeRange range) async {
    final excel = Excel.createExcel();

    // ─── Sheet 1: Summary ────────────────────────────────────────────────────
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');

    _header(summary, 0, 0, 'ACP Monitoring Report — ${AcpDummyData.trainName}');
    _header(summary, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _header(summary, 2, 0, 'Generated: ${_fmt(DateTime(2026, 3, 12))} | Last Updated: 10:46 AM');
    _blankRow(summary, 3);

    // Column headers
    final headers = ['Coach No.', 'Sensor ID', 'Status', 'Last Update', 'Location', 'Train Speed', 'Reset Done?', 'Chain Pulled Count'];
    for (var i = 0; i < headers.length; i++) {
      _colHeader(summary, 4, i, headers[i]);
    }

    // Data rows
    for (var r = 0; r < coaches.length; r++) {
      final c = coaches[r];
      final row = 5 + r;
      _cell(summary, row, 0, c.coachNumber);
      _cell(summary, row, 1, c.sensorId);
      _cell(summary, row, 2, c.status, color: c.isOn ? '2E7D32' : 'D32F2F');
      _cell(summary, row, 3, c.updateTime);
      _cell(summary, row, 4, c.location);
      _cell(summary, row, 5, c.trainSpeed);
      _cell(summary, row, 6, c.reset);
      _cell(summary, row, 7, c.isChainPulled ? '1' : '0');
    }

    // Totals
    final totalRow = 5 + coaches.length + 1;
    _colHeader(summary, totalRow, 0, 'Total Coaches');
    _cell(summary, totalRow, 1, '${coaches.length}');
    _colHeader(summary, totalRow + 1, 0, 'ON Count');
    _cell(summary, totalRow + 1, 1, '${coaches.where((c) => c.isOn).length}');
    _colHeader(summary, totalRow + 2, 0, 'OFF Count');
    _cell(summary, totalRow + 2, 1, '${coaches.where((c) => !c.isOn).length}', color: 'D32F2F');

    // ─── Sheet 2: Chain Pull History ──────────────────────────────────────────
    final histSheet = excel['Chain Pull History'];
    _header(histSheet, 0, 0, 'Chain Pull History — ${AcpDummyData.trainName}');
    _header(histSheet, 1, 0, 'Period: ${_fmt(range.start)}  →  ${_fmt(range.end)}');
    _blankRow(histSheet, 2);

    final histHeaders = ['Coach No.', 'Sensor ID', 'Pull Date/Time', 'Train Speed', 'Location', 'Reset Status'];
    for (var i = 0; i < histHeaders.length; i++) {
      _colHeader(histSheet, 3, i, histHeaders[i]);
    }

    int histRow = 4;
    for (final coach in coaches.where((c) => c.isChainPulled || c.coachNumber == 'Coach 4')) {
      final entries = AcpDummyData.getHistory(coach.coachNumber, 'Custom', from: range.start, to: range.end);
      for (final entry in entries) {
        _cell(histSheet, histRow, 0, coach.coachNumber);
        _cell(histSheet, histRow, 1, entry.sensorId);
        _cell(histSheet, histRow, 2, entry.lastPull);
        _cell(histSheet, histRow, 3, entry.trainSpeed);
        _cell(histSheet, histRow, 4, entry.location);
        _cell(histSheet, histRow, 5, entry.reset, color: entry.reset == 'Not done' ? 'D32F2F' : '2E7D32');
        histRow++;
      }
    }

    // ─── Sheet 3: Date-wise Summary ──────────────────────────────────────────
    final dateSheet = excel['Date-wise Summary'];
    _header(dateSheet, 0, 0, 'Date-wise Coach Status Summary');
    _blankRow(dateSheet, 1);

    final dateHeaders = ['Date', 'Total Coaches', 'ON', 'OFF', 'Incidents'];
    for (var i = 0; i < dateHeaders.length; i++) {
      _colHeader(dateSheet, 2, i, dateHeaders[i]);
    }

    final days = range.end.difference(range.start).inDays + 1;
    for (var d = 0; d < days; d++) {
      final date = range.start.add(Duration(days: d));
      final isToday = date.day == 12 && date.month == 3;
      final offCount = isToday ? 4 : (d % 3 == 0 ? 2 : (d % 5 == 0 ? 1 : 0));
      final onCount = 20 - offCount;
      _cell(dateSheet, 3 + d, 0, _fmt(date));
      _cell(dateSheet, 3 + d, 1, '20');
      _cell(dateSheet, 3 + d, 2, '$onCount', color: '2E7D32');
      _cell(dateSheet, 3 + d, 3, '$offCount', color: offCount > 0 ? 'D32F2F' : null);
      _cell(dateSheet, 3 + d, 4, '$offCount');
    }

    // Set column widths
    for (final sheet in [summary, histSheet, dateSheet]) {
      sheet.setColumnWidth(0, 18);
      sheet.setColumnWidth(1, 16);
      sheet.setColumnWidth(2, 18);
      sheet.setColumnWidth(3, 16);
      sheet.setColumnWidth(4, 16);
      sheet.setColumnWidth(5, 16);
      sheet.setColumnWidth(6, 14);
      sheet.setColumnWidth(7, 20);
    }

    // Save
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'ACP_Report_${_fmt(range.start)}_to_${_fmt(range.end)}.xlsx'.replaceAll('/', '-');
    final file = File('${dir.path}/$fileName');
    final bytes = excel.encode()!;
    await file.writeAsBytes(bytes);
    return file;
  }

  static void _header(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: ExcelColor.fromHexString('#1565C0'),
    );
  }

  static void _colHeader(Sheet sheet, int row, int col, String text) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1565C0'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 11,
    );
  }

  static void _cell(Sheet sheet, int row, int col, String text, {String? color}) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    if (color != null) {
      cell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#$color'),
        bold: true,
        fontSize: 11,
      );
    } else {
      cell.cellStyle = CellStyle(fontSize: 11);
    }
  }

  static void _blankRow(Sheet sheet, int row) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('');
  }

  static String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static void _showSuccess(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text('Report Ready', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Excel report generated successfully.', style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 8),
            Text('Includes:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            _reportFeature('Coach Status Summary'),
            _reportFeature('Chain Pull History'),
            _reportFeature('Date-wise Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Text(path.split('/').last, style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: ColorConstants.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () {
              Navigator.pop(context);
              OpenFile.open(path);
            },
            child: Text('Open File', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static Widget _reportFeature(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        const Icon(Icons.check, size: 14, color: Color(0xFF2E7D32)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    ),
  );
}