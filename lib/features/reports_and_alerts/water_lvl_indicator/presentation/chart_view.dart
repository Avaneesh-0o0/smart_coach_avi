import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  String selectedPeriod = 'Live';
  String selectedPeriod2 = 'Live';
  bool showNPP = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeriodFilter(
          selectedPeriod,
          ['Live', '7 Days', '30 Days', 'Custom'],
          (val) => setState(() => selectedPeriod = val),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Water Level Chart', style: AppTextStyles.header3),
            Row(
              children: [
                _buildChipToggle('PP', !showNPP, () {
                  setState(() => showNPP = false);
                }),
                const SizedBox(width: 8),
                _buildChipToggle('NPP', showNPP, () {
                  setState(() => showNPP = true);
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildBarChart(),
        const SizedBox(height: 20),

        _buildStatsSummary(),
        const SizedBox(height: 24),

        _buildPeriodFilter(
          selectedPeriod2,
          ['Live', '7 Days', '30 Days', 'Custom'],
          (val) => setState(() => selectedPeriod2 = val),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Water Level Chart', style: AppTextStyles.header3),
            Row(
              children: [
                _buildChipToggle('PP', !showNPP, () {
                  setState(() => showNPP = false);
                }),
                const SizedBox(width: 8),
                _buildChipToggle('NPP', showNPP, () {
                  setState(() => showNPP = true);
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildDonutChart(),
        const SizedBox(height: 20),

        _buildStatsSummary(),
      ],
    );
  }

  Widget _buildPeriodFilter(
      String selected, List<String> periods, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = selected == period;
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index < periods.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => onChanged(period),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorConstants.white : ColorConstants.cardBackground,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color: isSelected ? ColorConstants.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? ColorConstants.primary
                          : ColorConstants.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChipToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorConstants.primary : ColorConstants.divider,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final barColors = [
      Colors.green,
      ColorConstants.statusWarning,
      Colors.green,
      Colors.green,
      Colors.green,
      ColorConstants.statusCritical,
      Colors.green,
    ];
    final barValues = [85.0, 30.0, 78.0, 82.0, 90.0, 20.0, 88.0];

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
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: ColorConstants.divider,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  'No. of coaches',
                  style: AppTextStyles.bodySmall,
                ),
                axisNameSize: 22,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final labels = ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7'];
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Text(
                        labels[value.toInt()],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: value.toInt() == 1
                              ? ColorConstants.statusCritical
                              : ColorConstants.textTertiary,
                          fontWeight: value.toInt() == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
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
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: barValues[index],
                    color: barColors[index],
                    width: 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
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
              Text(
                'No. of Coaches',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '22',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow(Colors.green, 'Good', '16'),
          const SizedBox(height: 4),
          _buildStatRow(ColorConstants.statusWarning, 'Warning', '03'),
          const SizedBox(height: 4),
          _buildStatRow(ColorConstants.statusCritical, 'Critical', '03'),
        ],
      ),
    );
  }

  Widget _buildStatRow(Color dotColor, String label, String count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          count,
          style:
              AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDonutChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(
                value: 16,
                color: Colors.green,
                radius: 55,
                title: '',
              ),
              PieChartSectionData(
                value: 3,
                color: ColorConstants.statusCritical,
                radius: 55,
                title: '',
              ),
              PieChartSectionData(
                value: 3,
                color: ColorConstants.statusWarning,
                radius: 55,
                title: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
