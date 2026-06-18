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
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/datasource/hot_axle_dummy_data.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_report_generator.dart';
import '../data/models/hot_axle_model.dart';
import 'hot_axle_alert_view.dart';
import 'hot_axle_coaches_view.dart';
import 'hot_axle_chart_view.dart';

class HotAxleDashboard extends StatefulWidget {
  const HotAxleDashboard({super.key});

  @override
  State<HotAxleDashboard> createState() => _HotAxleDashboardState();
}

class _HotAxleDashboardState extends State<HotAxleDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Unique IDs';
  String selectedStatus = 'All';
  String selectedViewType = 'Coaches';
  String lastUpdated = 'Never';
  bool isRefreshing = false;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Unique IDs'];

  List<HotAxleCoachModel> _allCoaches = [];
  List<HotAxleCoachModel> _filteredCoaches = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || coach.trainNo.contains(selectedTrainNumber);
        final matchesType = selectedCoachType == 'All Types' || coach.coachType == selectedCoachType;
        final matchesCoach = selectedCoachNumber == 'All Unique IDs' || coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || coach.status.toUpperCase() == selectedStatus.toUpperCase();
        
        return matchesTrain && matchesType && matchesCoach && matchesStatus;
      }).toList();
    });
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) setState(() => isRefreshing = true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      final List<HotAxleCoachModel> mockData = [
        HotAxleCoachModel(
          deviceId: "HA_DEV_100676",
          coachNumber: "100676",
          coachType: "LHB_AC_2TIER",
          owningRly: "SEC",
          trainNo: "12615",
          trainName: "Grand Trunk Express",
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          a11Temp: 45.2,
          a12Temp: 46.8,
          a21Temp: 82.5,
          a22Temp: 44.1,
          a31Temp: 45.9,
          a32Temp: 47.3,
          a41Temp: 44.8,
          a42Temp: 46.2,
          batteryPercentage: 88,
          signalStrength: -65,
        ),
        HotAxleCoachModel(
          deviceId: "HA_DEV_100677",
          coachNumber: "100677",
          coachType: "LHB_AC_3TIER",
          owningRly: "SEC",
          trainNo: "12615",
          trainName: "Grand Trunk Express",
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
          a11Temp: 40.2,
          a12Temp: 41.8,
          a21Temp: 42.5,
          a22Temp: 40.1,
          a31Temp: 41.9,
          a32Temp: 42.3,
          a41Temp: 41.8,
          a42Temp: 42.2,
          batteryPercentage: 92,
          signalStrength: -60,
        ),
      ];

      setState(() {
        isRefreshing = false;
        lastUpdated = DateFormat('dd/MM/yy HH:mm:ss').format(DateTime.now());
        _allCoaches = mockData;
        
        trainNumbers = ['All Trains', ...mockData.map((e) => e.trainNo).where((n) => n.isNotEmpty).toSet()];
        coachTypes = ['All Types', ...mockData.map((e) => e.coachType).toSet()];
        coachNumbers = ['All Unique IDs', ...mockData.map((e) => e.coachNumber).toSet()];
        
        _applyFilters();
      });
    }
  }

  void _sendAlerts() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert will be sent to:', style: GoogleFonts.poppins(fontSize: 13, color: ColorConstants.textSecondary)),
            const SizedBox(height: 12),
            _alertRecipient(Icons.person, 'Train Guard'),
            _alertRecipient(Icons.support_agent, 'Station Master'),
            _alertRecipient(Icons.security, 'RPF Control Room'),
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
                  content: Text('✅ Alert sent successfully', style: GoogleFonts.poppins(fontSize: 13)),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Send Now', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _alertRecipient(IconData icon, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ColorConstants.primary),
          const SizedBox(width: 8),
          Text(name, style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Unique IDs';
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
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last Updated: $lastUpdated',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      body: (isRefreshing && _allCoaches.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(child: _buildFiltersSection()),
                const SizedBox(height: 8),
                _buildSectionCard(child: _buildQuickActionsSection()),
                const SizedBox(height: 8),
                _buildSectionCard(child: _buildViewTypeSection()),
                const SizedBox(height: 8),
                if (selectedViewType == 'Coaches')
                  _buildSectionCard(child: HotAxleCoachesView(coaches: _filteredCoaches))
                else if (selectedViewType == 'Chart View')
                  _buildSectionCard(child: HotAxleChartView(coaches: _filteredCoaches))
                else if (selectedViewType == 'Alerts')
                    _buildSectionCard(child: const HotAxleAlertView()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: child,
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.filters,
              style: AppTextStyles.header2.copyWith(color: ColorConstants.primary),
            ),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Clear Filters',
                      style: GoogleFonts.poppins(
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
            Expanded(
              child: FilterDropdown(
                label: AppStrings.trainNumber,
                value: selectedTrainNumber,
                items: trainNumbers,
                onChanged: (value) {
                  setState(() => selectedTrainNumber = value!);
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Type',
                value: selectedCoachType,
                items: coachTypes,
                onChanged: (value) {
                  setState(() => selectedCoachType = value!);
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: AppStrings.uniqueId,
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (value) {
                  setState(() => selectedCoachNumber = value!);
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.good, isSelected: selectedStatus == 'Good', onTap: () { setState(() => selectedStatus = 'Good'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.warning, isSelected: selectedStatus == 'Warning', onTap: () { setState(() => selectedStatus = 'Warning'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.critical, isSelected: selectedStatus == 'Critical', onTap: () { setState(() => selectedStatus = 'Critical'); _applyFilters(); })),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: AppStrings.sendAlerts,
                svgIcon: AppIcons.alert,
                onTap: _sendAlerts,
                isPrimary: true,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.generateReport,
                svgIcon: AppIcons.report,
                onTap: () {
                  HotAxleReportGenerator.generate(context, _filteredCoaches);
                },
                isFullWidth: true,
              ),
            ),
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
                    : SvgPicture.asset(
                        AppIcons.refresh,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(ColorConstants.iconGrey, BlendMode.srcIn),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ViewTypeSelector(label: AppStrings.coachesView, svgIcon: AppIcons.coaches, isSelected: selectedViewType == 'Coaches', onTap: () => setState(() => selectedViewType = 'Coaches'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.chartView, svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Chart View', onTap: () => setState(() => selectedViewType = 'Chart View'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.alerts, svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
          ],
        ),
      ],
    );
  }
}