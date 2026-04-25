import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';


class FsdsChartView extends StatefulWidget {
  const FsdsChartView({super.key});

  @override
  State<FsdsChartView> createState() => _FsdsChartViewState();
}

class _FsdsChartViewState extends State<FsdsChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = 'Pie Chart';

  final int totalCoaches = 20;
  final int onCount = 16;
  final int offCount = 4;

  final List<MapEntry<String, bool>> barData = const [
    MapEntry('C1', true),
    MapEntry('C2', true),
    MapEntry('C3', true),
    MapEntry('C4', false),
    MapEntry('C5', true),
    MapEntry('C6', true),
    MapEntry('C7', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['Live', '7 Days', '30 Days', 'Custom'],
          onChanged: (value) => setState(() => selectedPeriod = value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child:
                  Text(AppStrings.fsdsTrend, style: AppTextStyles.header2),
            ),
            _buildChartTypeToggle(AppStrings.pieChart),
            const SizedBox(width: 8),
            _buildChartTypeToggle(AppStrings.barChart),
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

  Widget _buildChartTypeToggle(String label) {
    final isSelected = selectedChartType == label;
    return GestureDetector(
      onTap: () => setState(() => selectedChartType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: ColorConstants.white,
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
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: onCount.toDouble(),
              color: const Color(0xFF34C700),
              radius: 60,
              showTitle: false,
            ),
            PieChartSectionData(
              value: offCount.toDouble(),
              color: const Color(0xFFFF3B30),
              radius: 60,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }

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
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.2,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value > 1.0) return const SizedBox.shrink();
                    return Text(
                      value.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget:
                    Text('No. of coaches', style: AppTextStyles.bodySmall),
                axisNameSize: 24,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < barData.length) {
                      final entry = barData[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          entry.key,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: entry.key == 'C2'
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: entry.key == 'C2'
                                ? ColorConstants.primary
                                : ColorConstants.textPrimary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.2,
              getDrawingHorizontalLine: (value) => FlLine(
                color: ColorConstants.divider,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barData.asMap().entries.map((entry) {
              final index = entry.key;
              final isOn = entry.value.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: isOn ? 0.95 : 0.05,
                    color: isOn
                        ? const Color(0xFF34C700)
                        : const Color(0xFFFF3B30),
                    width: 28,
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
              Text('No. of Coaches', style: AppTextStyles.bodyMedium),
              Text(
                '$totalCoaches',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow('ON', '$onCount', const Color(0xFF34C700)),
          const SizedBox(height: 8),
          _buildStatRow('OFF', offCount.toString().padLeft(2, '0'),
              const Color(0xFFFF3B30)),
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
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value,
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
