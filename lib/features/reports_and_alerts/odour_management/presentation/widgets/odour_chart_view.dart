import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';

class OdourChartView extends StatefulWidget {
  final List<OdourCoachModel> records;
  const OdourChartView({super.key, required this.records});

  @override
  State<OdourChartView> createState() => _OdourChartViewState();
}

class _OdourChartViewState extends State<OdourChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = 'Time Series';
  DateTimeRange? customRange;

  int get alertCount => widget.records.where((r) => r.hasAlert).length;
  int get activeCount => widget.records.where((r) => r.isActive).length;
  int get total => widget.records.length;

  List<OdourCoachModel> get _filteredByPeriod {
    if (selectedPeriod == 'Live') return widget.records;
    final now = DateTime.now();
    DateTime? start;
    if (selectedPeriod == '7 Days') start = now.subtract(const Duration(days: 7));
    else if (selectedPeriod == '30 Days') start = now.subtract(const Duration(days: 30));
    else if (selectedPeriod == 'Custom' && customRange != null) start = customRange!.start;
    if (start == null) return widget.records;
    return widget.records.where((r) {
      try { return DateTime.parse(r.timestamp).isAfter(start!); }
      catch (_) { return false; }
    }).toList();
  }

  List<FlSpot> get _timeSeriesData {
    final filtered = _filteredByPeriod;
    if (filtered.isEmpty) return [const FlSpot(0, 0)];
    final coachMap = <String, double>{};
    for (final r in filtered) {
      coachMap[r.coachNumber] = (coachMap[r.coachNumber] ?? 0) + r.reading.toDouble();
    }
    final entries = coachMap.entries.toList();
    return entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
  }

  List<String> get _xLabels {
    return _filteredByPeriod.map((r) => r.coachNumber).toSet().toList();
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now(),
    );
    if (range != null) setState(() { customRange = range; selectedPeriod = 'Custom'; });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '7 Days', '30 Days', 'Custom'],
          onChanged: (v) async => v == 'Custom' ? await _pickCustomRange() : setState(() { selectedPeriod = v; customRange = null; }),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Odour Readings by Coach', style: AppTextStyles.header2)),
            _chartTypeToggle('Time Series'),
            const SizedBox(width: 8),
            _chartTypeToggle('Pie Chart'),
          ],
        ),
        const SizedBox(height: 16),
        selectedChartType == 'Pie Chart' ? _buildPieChart() : _buildBarChart(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _chartTypeToggle(String label) {
    final isSelected = selectedChartType == label;
    return GestureDetector(
      onTap: () => setState(() => selectedChartType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primary.withValues(alpha: 0.08) : ColorConstants.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: isSelected ? ColorConstants.primary : ColorConstants.divider, width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary)),
      ),
    );
  }

  Widget _buildPieChart() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(PieChartData(sectionsSpace: 3, centerSpaceRadius: 56, sections: [
                PieChartSectionData(value: activeCount.toDouble(), color: const Color(0xFF34C700), radius: 60, showTitle: false),
                PieChartSectionData(value: alertCount.toDouble(), color: const Color(0xFFFF3B30), radius: 60, showTitle: false),
                PieChartSectionData(value: (total - activeCount - alertCount).toDouble(), color: Colors.grey, radius: 60, showTitle: false),
              ])),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                Text('Sensors', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(const Color(0xFF34C700), 'Active ($activeCount)'),
          const SizedBox(width: 16),
          _legend(const Color(0xFFFF3B30), 'Alert ($alertCount)'),
          const SizedBox(width: 16),
          _legend(Colors.grey, 'Inactive (${total - activeCount - alertCount})'),
        ]),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6), Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
  ]);

  Widget _buildBarChart() {
    final spots = _timeSeriesData;
    final labels = _xLabels;
    if (spots.isEmpty) return const Center(child: Text('No data'));

    return Container(
      padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12, left: 12),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: SizedBox(
        height: 220,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2).clamp(100, 500),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50,
            getDrawingHorizontalLine: (v) => FlLine(color: ColorConstants.divider, strokeWidth: 1)),
          titlesData: FlTitlesData(
            show: true, rightTitles: const AxisTitles(), topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 30,
              getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(labels[idx], style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                  );
                }
                return const SizedBox.shrink();
              })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35,
              getTitlesWidget: (v, m) => Text('${v.toInt()}', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)))),
          ),
          borderData: FlBorderData(show: false),
          barGroups: spots.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
            BarChartRodData(toY: e.value.y, color: e.value.y > 70 ? const Color(0xFFD32F2F) : const Color(0xFF34C700), width: 22,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))
          ])).toList(),
        )),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Sensors', style: AppTextStyles.bodyMedium),
          Text('$total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        _buildStatRow('Active', '$activeCount', const Color(0xFF34C700)),
        const SizedBox(height: 8),
        _buildStatRow('Alert ( > 70 ppm)', '$alertCount', const Color(0xFFFF3B30)),
        const SizedBox(height: 8),
        _buildStatRow('Inactive', '${total - activeCount - alertCount}', Colors.grey),
      ]),
    );
  }

  Widget _buildStatRow(String l, String v, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Text(l, style: AppTextStyles.bodyMedium)]),
    Text(v, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
  ]);
}
