import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';


class FullTankHistory extends StatefulWidget {
  final String coachNumber;
  final int ppPercentage;
  final int nppPercentage;
  final String ppStatus;
  final String nppStatus;

  const FullTankHistory({
    super.key,
    required this.coachNumber,
    required this.ppPercentage,
    required this.nppPercentage,
    required this.ppStatus,
    required this.nppStatus,
  });

  @override
  State<FullTankHistory> createState() => _FullTankHistoryState();
}

class _FullTankHistoryState extends State<FullTankHistory> {
  bool isPPSelected = true;
  String selectedPeriod = 'Live';

  int get _currentPercentage =>
      isPPSelected ? widget.ppPercentage : widget.nppPercentage;

  String get _currentStatus =>
      isPPSelected ? widget.ppStatus : widget.nppStatus;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return ColorConstants.statusGood;
      case 'warning':
        return ColorConstants.statusWarning;
      case 'critical':
        return ColorConstants.statusCritical;
      default:
        return ColorConstants.iconGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.coachNumber} Tanks History',
          style: AppTextStyles.header1,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTankTabs(),
              const SizedBox(height: 20),

              _buildCurrentLevelCard(),
              const SizedBox(height: 20),

              _buildPeriodFilter(),
              const SizedBox(height: 20),

              _buildLineChart(),
              const SizedBox(height: 24),

              _buildStatsCards(),
              const SizedBox(height: 24),

              _buildLastUpdatedBySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTankTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isPPSelected = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isPPSelected ? ColorConstants.primary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    'PP Tank',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isPPSelected
                          ? ColorConstants.white
                          : ColorConstants.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isPPSelected = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isPPSelected ? ColorConstants.primary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    'NPP Tank',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: !isPPSelected
                          ? ColorConstants.white
                          : ColorConstants.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    final statusColor = _getStatusColor(_currentStatus);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${isPPSelected ? "PP" : "NPP"} Current Level: $_currentPercentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _currentStatus,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _currentPercentage / 100,
                    minHeight: 14,
                    backgroundColor: ColorConstants.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ColorConstants.divider,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Last Updated: 10:46 AM',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.coachNumber} | Capacity 1000L',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Live', '1 Day', '7 Days', '30 Days'];
    return Row(
      children: periods.map((period) {
        final isSelected = selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => selectedPeriod = period),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ColorConstants.white : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color:
                      isSelected ? ColorConstants.primary : ColorConstants.divider,
                  width: 1.5,
                ),
              ),
              child: Text(
                period,
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
        );
      }).toList(),
    );
  }

  Widget _buildLineChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
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
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    const labels = [
                      '09:00 AM',
                      '11:00 AM',
                      '08:00 PM',
                      '10:00 PM'
                    ];
                    if (value.toInt() >= 0 &&
                        value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[value.toInt()],
                          style: AppTextStyles.bodySmall
                              .copyWith(fontSize: 9),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 3,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 5),
                  FlSpot(0.5, 15),
                  FlSpot(1, 22),
                  FlSpot(1.5, 30),
                  FlSpot(2, 48),
                  FlSpot(2.5, 58),
                  FlSpot(2.7, 55),
                  FlSpot(3, 95),
                ],
                isCurved: true,
                color: Colors.green,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: index == 0
                        ? Colors.red
                        : Colors.green,
                    strokeWidth: 0,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.withValues(alpha: 0.3),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatItem('Lowest Level', '10%', ColorConstants.statusCritical),
            const SizedBox(width: 12),
            _buildStatItem(
                'Highest Level', '100%', ColorConstants.primary),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatItem(
                'Avg Consumed', '18%', ColorConstants.statusGood),
            const SizedBox(width: 12),
            _buildStatItem('Refilled', '2 times', ColorConstants.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedBySection() {
    final historyData = [
      {'date': 'Yesterday, 10:45 AM', 'level': 'Level 60%'},
      {'date': '08/02/2026, 12:45 PM', 'level': 'Level 20%'},
      {'date': '07/02/2026, 09:45 AM', 'level': 'Level 23%'},
      {'date': '06/02/2026, 06:45 PM', 'level': 'Level 59%'},
      {'date': '05/02/2026, 04:45 PM', 'level': 'Level 55%'},
      {'date': '04/02/2026, 03:45 PM', 'level': 'Level 45%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last Updated By', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Column(
            children: [
              // Table Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date & Time',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Refilled  By',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Table Rows
              ...historyData.map((entry) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: ColorConstants.divider, width: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry['date']!, style: AppTextStyles.bodyMedium),
                        Text(entry['level']!, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              'View all',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: ColorConstants.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
