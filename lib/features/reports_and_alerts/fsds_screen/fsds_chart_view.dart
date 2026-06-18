import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'data/models/fsds_model.dart';

class FsdsChartView extends StatefulWidget {
  final List<FsdsAssetModel> assets;
  const FsdsChartView({super.key, required this.assets});

  @override
  State<FsdsChartView> createState() => _FsdsChartViewState();
}

class _FsdsChartViewState extends State<FsdsChartView> {
  String selectedPeriod = 'Live';
  String selectedChartType = AppStrings.pieChart;
  DateTimeRange? customRange;

  List<FsdsAssetModel> get filteredAssets {
    if (selectedPeriod == 'Live') return widget.assets;
    DateTime now = DateTime.now();
    DateTime? startDate;
    if (selectedPeriod == '7 Days') startDate = now.subtract(const Duration(days: 7));
    else if (selectedPeriod == '30 Days') startDate = now.subtract(const Duration(days: 30));
    else if (selectedPeriod == 'Custom' && customRange != null) startDate = customRange!.start;
    
    if (startDate == null) return widget.assets;
    return widget.assets.where((a) {
      try {
        final updateTime = DateTime.parse(a.timestamp);
        return updateTime.isAfter(startDate!);
      } catch (_) { return false; }
    }).toList();
  }

  int get bypassOnCount => filteredAssets.where((a) => a.isBypassOn).length;
  int get bypassOffCount => filteredAssets.where((a) => !a.isBypassOn).length;
  int get total => filteredAssets.length;

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now(),
    );
    if (range != null) setState(() { customRange = range; selectedPeriod = 'Custom'; });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) return const SizedBox.shrink();
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
            Expanded(child: Text('FSDS Bypass Status', style: AppTextStyles.header2)),
            _chartTypeToggle(AppStrings.pieChart),
          ],
        ),
        const SizedBox(height: 16),
        selectedChartType == AppStrings.pieChart ? _buildPieChart() : _buildStatusBarChart(),
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
    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text('No Data', style: GoogleFonts.poppins(fontSize: 16, color: ColorConstants.textTertiary)),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(PieChartData(sectionsSpace: 3, centerSpaceRadius: 56, sections: [
                PieChartSectionData(value: bypassOnCount.toDouble(), color: Colors.orange, radius: 60, showTitle: false),
                PieChartSectionData(value: bypassOffCount.toDouble(), color: Colors.green, radius: 60, showTitle: false),
              ])),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$total', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                Text('Total', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(Colors.orange, 'Bypass ON ($bypassOnCount)'), const SizedBox(width: 20),
          _legend(Colors.green, 'Bypass OFF ($bypassOffCount)'),
        ]),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6), Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
  ]);

  Widget _buildStatusBarChart() {
    if (total == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        children: [
          _buildBinaryBar('Bypass ON', bypassOnCount, total, Colors.orange),
          const SizedBox(height: 12),
          _buildBinaryBar('Bypass OFF', bypassOffCount, total, Colors.green),
        ],
      ),
    );
  }

  Widget _buildBinaryBar(String label, int count, int total, Color color) {
    final fraction = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text('$count / $total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: ColorConstants.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Devices', style: AppTextStyles.bodyMedium),
          Text('$total', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        _buildStatRow('Bypass ON', '$bypassOnCount', Colors.orange),
        const SizedBox(height: 8),
        _buildStatRow('Bypass OFF', '$bypassOffCount', Colors.green),
        const SizedBox(height: 8),
        _buildStatRow('Active Alerts', '${filteredAssets.where((a) => a.isAlertActive).length}', Colors.red),
      ]),
    );
  }

  Widget _buildStatRow(String l, String v, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Text(l, style: AppTextStyles.bodyMedium)]),
    Text(v, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
  ]);
}
