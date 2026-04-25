import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/action_button.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/core/widgets/status_chip.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/datasource/hot_axle_dummy_data.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_report_generator.dart';
import '../data/models/hot_axle_model.dart';
import 'hot_axle_alert_view.dart';
import 'hot_axle_coaches_view.dart';

class HotAxleDashboard extends StatefulWidget {
  const HotAxleDashboard({super.key});

  @override
  State<HotAxleDashboard> createState() => _HotAxleDashboardState();
}

class _HotAxleDashboardState extends State<HotAxleDashboard> {
  String selectedTrainNumber = '12615/6 Grand Tr...';
  String selectedCoachNumber = 'All Coaches';
  String selectedStatus = 'All';
  String selectedViewType = 'Hot Axle';
  String lastUpdated = '10:46 AM';
  bool isRefreshing = false;

  final List<String> trainNumbers = ['12615/6 Grand Tr...'];
  final List<String> coachNumbers = [
    'All Coaches',
    ...List.generate(20, (i) => 'Coach ${i + 1}'),
  ];

  late List<HotAxleCoachModel> _allCoaches = HotAxleDummyData.generateCoaches();
  late List<HotAxleCoachModel> _filteredCoaches = List.from(_allCoaches);

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesCoach = selectedCoachNumber == 'All Coaches' ||
            coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' ||
            coach.status.toLowerCase() == selectedStatus.toLowerCase();
        return matchesCoach && matchesStatus;
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter applied: ${_filteredCoaches.length} coach(es) found', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: ColorConstants.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    final now = TimeOfDay.now();
    setState(() {
      isRefreshing = false;
      lastUpdated = now.format(context);
      _allCoaches = HotAxleDummyData.generateCoaches();
      _filteredCoaches = List.from(_allCoaches);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data refreshed at ${now.format(context)}', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _sendAlerts() {
    final criticalCoaches = _allCoaches.where((c) => c.status == 'Critical').map((c) => c.coachNumber).join(', ');
    final warningCoaches  = _allCoaches.where((c) => c.status == 'Warning').map((c) => c.coachNumber).join(', ');
    final totalIssueAxles = _allCoaches.fold(0, (sum, c) => sum + c.axlesIssue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Hot Axle Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert will be sent to:', style: GoogleFonts.poppins(fontSize: 13, color: ColorConstants.textSecondary)),
            const SizedBox(height: 10),
            _alertRow(Icons.person,       'Train Guard - Ramesh Kumar'),
            _alertRow(Icons.support_agent,'Station Master - Ujjain'),
            _alertRow(Icons.security,     'RPF Control Room'),
            _alertRow(Icons.engineering,  'Maintenance Team'),
            const SizedBox(height: 12),
            if (criticalCoaches.isNotEmpty) ...[
              _statusBanner('Critical: $criticalCoaches', const Color(0xFFD32F2F)),
              const SizedBox(height: 6),
            ],
            if (warningCoaches.isNotEmpty) ...[
              _statusBanner('Warning: $warningCoaches', const Color(0xFFBE8B22)),
              const SizedBox(height: 6),
            ],
            _statusBanner('Total axles with issues: $totalIssueAxles', ColorConstants.textSecondary),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: ColorConstants.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.primary),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert sent to 4 recipients', style: GoogleFonts.poppins(fontSize: 13)),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text('Send Now', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _alertRow(IconData icon, String name) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Icon(icon, size: 16, color: ColorConstants.primary),
      const SizedBox(width: 8),
      Text(name, style: GoogleFonts.poppins(fontSize: 13)),
    ]),
  );

  Widget _statusBanner(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
  );

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = trainNumbers.first;
      selectedCoachNumber = 'All Coaches';
      selectedStatus = 'All';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(AppStrings.hotAxleMonitoring, style: AppTextStyles.header1),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(8)),
                child: Text('Last Updated: $lastUpdated', style: AppTextStyles.bodySmall),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(child: _buildFilters()),
              const SizedBox(height: 8),
              _card(child: _buildQuickActions()),
              const SizedBox(height: 8),
              _card(child: _buildViewType()),
              const SizedBox(height: 8),
              _card(child: selectedViewType == 'Alerts'
                  ? const HotAxleAlertView()
                  : HotAxleCoachesView(coaches: _filteredCoaches)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
    decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
    child: child,
  );

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.filters, style: AppTextStyles.header2.copyWith(color: ColorConstants.primary)),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Clear Filters',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: FilterDropdown(label: AppStrings.trainNumber, value: selectedTrainNumber, items: trainNumbers, onChanged: (v) { setState(() => selectedTrainNumber = v!); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: AppStrings.coachNumber, value: selectedCoachNumber, items: coachNumbers, onChanged: (v) { setState(() => selectedCoachNumber = v!); _applyFilters(); })),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all,      isSelected: selectedStatus == 'All',      onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.good,     isSelected: selectedStatus == 'Good',     onTap: () { setState(() => selectedStatus = 'Good'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.warning,  isSelected: selectedStatus == 'Warning',  onTap: () { setState(() => selectedStatus = 'Warning'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.critical, isSelected: selectedStatus == 'Critical', onTap: () { setState(() => selectedStatus = 'Critical'); _applyFilters(); })),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ActionButton(label: AppStrings.sendAlerts,    svgIcon: AppIcons.alert,  onTap: _sendAlerts, isPrimary: true, isFullWidth: true)),
            const SizedBox(width: 8),
            Expanded(child: ActionButton(label: AppStrings.generateReport, svgIcon: AppIcons.report, onTap: () => HotAxleReportGenerator.generate(context, _filteredCoaches), isFullWidth: true)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isRefreshing ? () {} : _refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: ColorConstants.divider),
                ),
                child: isRefreshing 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary))
                    : const Icon(Icons.refresh, size: 18, color: ColorConstants.iconGrey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ViewTypeSelector(label: AppStrings.hotAxle, svgIcon: AppIcons.axelGrey, isSelected: selectedViewType == 'Hot Axle', onTap: () => setState(() => selectedViewType = 'Hot Axle'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.alerts,  svgIcon: AppIcons.alert,    isSelected: selectedViewType == 'Alerts',   onTap: () => setState(() => selectedViewType = 'Alerts'))),
          ],
        ),
      ],
    );
  }
}