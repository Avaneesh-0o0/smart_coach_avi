import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/acp_model.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';

class AcpChartView extends StatefulWidget {
  final List<AcpCoachModel> coaches;
  const AcpChartView({super.key, required this.coaches});

  @override
  State<AcpChartView> createState() => _AcpChartViewState();
}

class _AcpChartViewState extends State<AcpChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = AppStrings.pieChart;
  DateTimeRange? customRange;

  int get onCount => widget.coaches.where((c) => c.isOn).length;
  int get offCount => widget.coaches.where((c) => !c.isOn).length;
  int get total => widget.coaches.length;

  List<MapEntry<String, bool>> get barData => widget.coaches.map((c) => MapEntry(c.coachNumber, c.isOn)).toList();

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 3, 12),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 12),
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        customRange = range;
        selectedPeriod = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.coaches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 64, color: ColorConstants.textTertiary),
              const SizedBox(height: 16),
              Text('No data available for chart', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '7 Days', '30 Days', 'Custom'],
          onChanged: (value) async {
            if (value == 'Custom') {
              await _pickCustomRange();
            } else {
              setState(() {
                selectedPeriod = value;
                customRange = null;
              });
            }
          },
        ),

        // Show selected custom range
        if (selectedPeriod == 'Custom' && customRange != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstants.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_fmt(customRange!.start)}  →  ${_fmt(customRange!.end)}',
              style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text(AppStrings.alarmChainTrend, style: AppTextStyles.header2)),
            _chartTypeToggle(AppStrings.pieChart),
            const SizedBox(width: 8),
            _chartTypeToggle(AppStrings.barChart),
          ],
        ),
        const SizedBox(height: 16),

        if (selectedChartType == AppStrings.pieChart)
          _buildPieChart()
        else
          _buildBarChart(),

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
          border: Border.all(
            color: isSelected ? ColorConstants.primary : ColorConstants.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
          ),
        ),
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
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 56,
                  sections: [
                    PieChartSectionData(
                      value: (onCount == 0 && offCount == 0) ? 1 : onCount.toDouble(),
                      color: (onCount == 0 && offCount == 0) ? ColorConstants.divider : const Color(0xFF34C700),
                      radius: 60,
                      showTitle: false,
                    ),
                    if (onCount > 0 || offCount > 0)
                      PieChartSectionData(
                        value: offCount.toDouble(),
                        color: const Color(0xFFFF3B30),
                        radius: 60,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
                  Text('Total', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xFF34C700), 'ON ($onCount)'),
            const SizedBox(width: 20),
            _legend(const Color(0xFFFF3B30), 'OFF ($offCount)'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
    ],
  );

  Widget _buildBarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final entry = barData[group.x];
                  return BarTooltipItem(
                    '${entry.key}\n${entry.value ? "ON" : "OFF"}',
                    GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.5,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value > 1.0 || value < 0) return const SizedBox.shrink();
                    final labels = {0.0: 'OFF', 1.0: 'ON'};
                    return Text(labels[value] ?? '', style: AppTextStyles.bodySmall);
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Coach', style: AppTextStyles.bodySmall),
                ),
                axisNameSize: 22,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= barData.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        barData[index].key,
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: ColorConstants.textPrimary),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.5,
              getDrawingHorizontalLine: (_) => FlLine(color: ColorConstants.divider, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barData.asMap().entries.map((entry) {
              final isOn = entry.value.value;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: isOn ? 1.0 : 0.15,
                    color: isOn ? const Color(0xFF34C700) : const Color(0xFFFF3B30),
                    width: 22,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final onPct = total > 0 ? (onCount / total * 100).toStringAsFixed(1) : '0';
    final offPct = total > 0 ? (offCount / total * 100).toStringAsFixed(1) : '0';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Coaches', style: AppTextStyles.bodyMedium),
              Text('$total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow('ON', '$onCount  ($onPct%)', const Color(0xFF34C700)),
          const SizedBox(height: 8),
          _buildStatRow('OFF', '$offCount  ($offPct%)', const Color(0xFFFF3B30)),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? onCount / total : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFFF3B30),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34C700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}