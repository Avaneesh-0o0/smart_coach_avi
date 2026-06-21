import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';
import 'dart:math' as math;

class OdourChartView extends StatefulWidget {
  final List<OdourCoachModel> records;
  const OdourChartView({super.key, required this.records});

  @override
  State<OdourChartView> createState() => _OdourChartViewState();
}

class _OdourChartViewState extends State<OdourChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = 'Time Series';
  String selectedMetric = 'Hygiene Score';
  DateTimeRange? customRange;

  final List<String> metrics = [
    'Hygiene Score',
    'VOC',
    'NH₃',
    'H₂S',
    'Smoke',
    'Temperature',
    'Humidity',
    'Door Activity'
  ];

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
    
    // Aggregate by coach and toilet position to show precise sensor readings
    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      final r = filtered[i];
      double val = 0;
      switch (selectedMetric) {
        case 'Hygiene Score': val = r.hygieneScore; break;
        case 'VOC': val = r.voc; break;
        case 'NH₃': val = r.nh3; break;
        case 'H₂S': val = r.h2s; break;
        case 'Smoke': val = r.smoke; break;
        case 'Temperature': val = r.temperature; break;
        case 'Humidity': val = r.humidity; break;
        case 'Door Activity': val = r.doorOpenEventsToday.toDouble(); break;
        default: val = r.hygieneScore; break;
      }
      spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
  }

  List<String> get _xLabels {
    return _filteredByPeriod.map((r) => '${r.coachNumber}\n${r.toiletPosition}').toList();
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
        _buildTopSummaryCards(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Analytics Graphs', style: AppTextStyles.header2)),
            _chartTypeToggle('Time Series'),
            const SizedBox(width: 8),
            _chartTypeToggle('Pie Chart'),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedChartType == 'Time Series') _buildMetricSelector(),
        if (selectedChartType == 'Time Series') const SizedBox(height: 12),
        selectedChartType == 'Pie Chart' ? _buildPieChart() : _buildBarChart(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMetric,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: ColorConstants.primary),
          items: metrics.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) setState(() => selectedMetric = newValue);
          },
        ),
      ),
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

    final maxVal = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final computedMaxY = (maxVal > 0 ? maxVal * 1.2 : 100).toDouble();

    // Calculate required width based on data points to ensure bars are spaced
    final chartWidth = math.max(MediaQuery.of(context).size.width - 48, spots.length * 60.0);

    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: chartWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 220,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: computedMaxY,
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: computedMaxY > 0 ? computedMaxY / 5 : 20,
                getDrawingHorizontalLine: (v) => FlLine(color: ColorConstants.divider, strokeWidth: 1)),
              titlesData: FlTitlesData(
                show: true, rightTitles: const AxisTitles(), topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 42,
                  getTitlesWidget: (v, m) {
                    final idx = v.toInt();
                    if (idx >= 0 && idx < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[idx], style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary), textAlign: TextAlign.center),
                      );
                    }
                    return const SizedBox.shrink();
                  })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                  getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)))),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: _getThresholdLine(),
              barGroups: spots.asMap().entries.map((e) {
                final isCritical = (selectedMetric == 'Hygiene Score' && e.value.y < 50) ||
                    (selectedMetric != 'Hygiene Score' && _getThresholdValue() != null && e.value.y > _getThresholdValue()!);
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(toY: e.value.y, color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFF34C700), width: 22,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))
                ]);
              }).toList(),
            )),
          ),
        ),
      ),
    );
  }

  double? _getThresholdValue() {
    switch(selectedMetric) {
      case 'VOC': return 500.0;
      case 'NH₃': return 1.0;
      case 'H₂S': return 0.1;
      case 'Smoke': return 10.0;
      case 'Hygiene Score': return 50.0;
      default: return null;
    }
  }

  ExtraLinesData _getThresholdLine() {
    final t = _getThresholdValue();
    if (t == null) return ExtraLinesData();
    return ExtraLinesData(horizontalLines: [
      HorizontalLine(y: t, color: Colors.redAccent, strokeWidth: 2, dashArray: [5, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 5, bottom: 5), style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold), labelResolver: (line) => 'Threshold: $t'))
    ]);
  }

  Widget _buildTopSummaryCards() {
    double sum = 0, highest = 0, lowest = 100;
    int doorEvents = 0;
    for (var r in widget.records) {
      sum += r.hygieneScore;
      if (r.hygieneScore > highest) highest = r.hygieneScore;
      if (r.hygieneScore < lowest) lowest = r.hygieneScore;
      doorEvents += r.doorOpenEventsToday;
    }
    double avg = widget.records.isEmpty ? 0 : sum / widget.records.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _summaryMetricCard('Avg Score', '${avg.toStringAsFixed(1)}%', Icons.analytics, ColorConstants.primary),
        _summaryMetricCard('Lowest Score', '${lowest.toStringAsFixed(1)}%', Icons.warning, const Color(0xFFFF3B30)),
        _summaryMetricCard('Highest Score', '${highest.toStringAsFixed(1)}%', Icons.check_circle, const Color(0xFF34C700)),
        _summaryMetricCard('Total Alerts', '$alertCount', Icons.notification_important, const Color(0xFFD32F2F)),
        _summaryMetricCard('Door Events', '$doorEvents', Icons.door_front_door, Colors.blueAccent),
        _summaryMetricCard('Active Devices', '$activeCount', Icons.sensors, const Color(0xFF34C700)),
      ],
    );
  }

  Widget _summaryMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2, // 2 columns
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMedium), border: Border.all(color: ColorConstants.divider)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall.copyWith(color: ColorConstants.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.header2.copyWith(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
