import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/action_button.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/core/widgets/status_chip.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';
import 'data/models/fsds_model.dart';
import 'fsds_coaches_view.dart';
import 'fsds_chart_view.dart';
import 'fsds_alert_view.dart';

class FsdsDashboard extends StatefulWidget {
  final String? title;
  const FsdsDashboard({super.key, this.title});

  @override
  State<FsdsDashboard> createState() => _FsdsDashboardState();
}

class _FsdsDashboardState extends State<FsdsDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachNumber = 'All Coaches';
  String selectedStatus = 'All';
  String selectedViewType = 'Coaches';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachNumbers = ['All Coaches'];

  List<AcpCoachModel> _allCoaches = [];
  List<AcpCoachModel> _filteredCoaches = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _refreshData(isBackgroundRefresh: true);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachNumber = 'All Coaches';
      selectedStatus = 'All';
      coachNumbers = ['All Coaches'];
    });
    _refreshData();
  }

  Future<void> _loadTrains() async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters();
      if (response.success == true) {
        if (mounted) {
          setState(() {
            final data = response.data ?? [];
            final extracted = data.map((e) => e.trainNo).where((e) => e != null).cast<String>().toList();
            trainNumbers = ['All Trains', ...extracted];
          });
        }
      }
    } catch (e) {
      log('Error loading trains: $e');
    }
  }

  Future<void> _loadCoachNumbers(String trainNo) async {
    try {
      final response = await getIt<AcpRepository>().getAcpFilters(trainNo: trainNo);
      if (response.success == true) {
        if (mounted) {
          setState(() {
            final data = response.data ?? [];
            final extracted = data.map((e) => e.techCoachNo).where((e) => e != null).cast<String>().toList();
            coachNumbers = ['All Coaches', ...extracted];
            selectedCoachNumber = 'All Coaches';
          });
        }
      }
    } catch (e) {
      log('Error loading coach numbers: $e');
    }
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }
    
    if (trainNumbers.length <= 1 && selectedTrainNumber == 'All Trains') {
      _loadTrains();
    }

    try {
      var logs = <AcpLogData>[];
      if (selectedTrainNumber == 'All Trains' || selectedCoachNumber == 'All Coaches') {
        logs = await getIt<AcpRepository>().getAcpSummary();
      } else {
        logs = await getIt<AcpRepository>().getAcpFilteredLogs(
           trainNo: selectedTrainNumber,
           techCoachNo: selectedCoachNumber,
        );
      }

      final List<AcpCoachModel> coaches = [];
      
      for (var logEntry in logs) {
        final sensorId = logEntry.techCoachNo ?? 'Unknown';
        final coachName = logEntry.commCoachNo ?? 'Unknown';
        final countVal = int.tryParse(logEntry.acpStatus ?? '0') ?? 0;
        
        bool isRecent = false;
        bool isStale = true;
        if (logEntry.lastUpdated != null) {
          try {
            final lastUpdate = DateTime.parse(logEntry.lastUpdated!);
            final diff = DateTime.now().difference(lastUpdate).inMinutes;
            if (diff < 5 && countVal > 0) isRecent = true;
            if (diff < 10) isStale = false;
          } catch (_) {}
        }

        coaches.add(AcpCoachModel(
          coachNumber: coachName,
          status: logEntry.acpStatus ?? '0',
          totalCount: logEntry.totalCount ?? '0',
          updateTime: logEntry.lastUpdated ?? 'N/A',
          isChainPulled: countVal > 0,
          location: logEntry.trainLocation ?? 'N/A', 
          lastPull: logEntry.lastUpdated ?? 'N/A', 
          sensorId: sensorId,
          rawAssetName: logEntry.rawAssetName ?? '$coachName $sensorId',
          isOn: !isStale,
          isRecent: isRecent,
          trainNo: logEntry.trainNo ?? 'N/A',
          deviceId: logEntry.deviceId ?? 'N/A',
        ));
      }

      if (mounted) {
        setState(() {
          _allCoaches = coaches;
          _applyFilters();
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          if (!isBackgroundRefresh) isRefreshing = false;
        });
      }
    } catch (e) {
      log('Error refreshing data: $e');
      if (mounted && !isBackgroundRefresh) {
        setState(() => isRefreshing = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || 
                           coach.trainNo == selectedTrainNumber;
        final matchesCoach = selectedCoachNumber == 'All Coaches' || 
                           coach.sensorId == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || 
                             (selectedStatus == 'ON' && coach.isOn) ||
                             (selectedStatus == 'OFF' && !coach.isOn);
        return matchesTrain && matchesCoach && matchesStatus;
      }).toList();
    });
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
        title: Text(widget.title ?? AppStrings.fsdsMonitoring,
            style: AppTextStyles.header1),
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
      body: SingleChildScrollView(
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
              _buildSectionCard(
                child: _buildCurrentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (selectedViewType) {
      case 'Chart View':
        return const FsdsChartView();
      case 'Alerts':
        return const FsdsAlertsView();
      default:
        return FsdsCoachesView(coaches: _filteredCoaches);
    }
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
            Expanded(
              child: FilterDropdown(
                label: AppStrings.trainNumber,
                value: selectedTrainNumber,
                items: trainNumbers,
                onChanged: (v) {
                   if (v != null) {
                     setState(() => selectedTrainNumber = v);
                     if (v != 'All Trains') _loadCoachNumbers(v);
                     _refreshData();
                   }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: AppStrings.coachNumber,
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (v) {
                   if (v != null) {
                     setState(() => selectedCoachNumber = v);
                     _refreshData();
                   }
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
            Expanded(
              child: StatusChip(
                label: AppStrings.all,
                isSelected: selectedStatus == 'All',
                onTap: () => setState(() { selectedStatus = 'All'; _applyFilters(); }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.on,
                isSelected: selectedStatus == 'ON',
                onTap: () => setState(() { selectedStatus = 'ON'; _applyFilters(); }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.off,
                isSelected: selectedStatus == 'OFF',
                onTap: () => setState(() { selectedStatus = 'OFF'; _applyFilters(); }),
              ),
            ),
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
                onTap: () {},
                isPrimary: true,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.generateReport,
                svgIcon: AppIcons.report,
                onTap: () {},
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _refreshData(),
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

  Widget _buildViewTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.coachesView,
                svgIcon: AppIcons.coaches,
                isSelected: selectedViewType == 'Coaches',
                onTap: () => setState(() => selectedViewType = 'Coaches'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.chartView,
                svgIcon: AppIcons.graph,
                isSelected: selectedViewType == 'Chart View',
                onTap: () => setState(() => selectedViewType = 'Chart View'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.alerts,
                svgIcon: AppIcons.alert,
                isSelected: selectedViewType == 'Alerts',
                onTap: () => setState(() => selectedViewType = 'Alerts'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
