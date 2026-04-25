import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/action_button.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/core/widgets/status_chip.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/data/models/water_tank_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/presentation/widgets/coach_detail_dialog.dart';
import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/presentation/widgets/water_tank_card.dart';

import 'alerts.dart';
import 'chart_view.dart';

class WaterLevelScreen extends StatefulWidget {
  const WaterLevelScreen({super.key});

  @override
  State<WaterLevelScreen> createState() => _WaterLevelScreenState();
}

class _WaterLevelScreenState extends State<WaterLevelScreen> {
  String selectedTrainNumber = '12615/6 Grand Tr...';
  String selectedCoachNumber = 'All Coach';
  String selectedStatus = 'All';
  String selectedViewType = 'Water Tanks';

  final List<String> trainNumbers = [
    '12615/6 Grand Tr...',
    '12617/8 Express',
    '12619/0 Special',
  ];

  final List<String> coachNumbers = [
    'All Coach',
    'Coach 1',
    'Coach 2',
    'Coach 3',
  ];

  List<WaterTankModel> waterTanks = [
    WaterTankModel(
      coachNumber: 'Coach 1',
      ppPercentage: 100,
      nppPercentage: 95,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 2',
      ppPercentage: 48,
      nppPercentage: 45,
      ppStatus: 'Critical',
      nppStatus: 'Critical',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 3',
      ppPercentage: 85,
      nppPercentage: 98,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 4',
      ppPercentage: 32,
      nppPercentage: 85,
      ppStatus: 'Warning',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 5',
      ppPercentage: 85,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 6',
      ppPercentage: 85,
      nppPercentage: 35,
      ppStatus: 'Critical',
      nppStatus: 'Warning',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 7',
      ppPercentage: 52,
      nppPercentage: 85,
      ppStatus: 'Critical',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 8',
      ppPercentage: 85,
      nppPercentage: 100,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 9',
      ppPercentage: 85,
      nppPercentage: 18,
      ppStatus: 'Good',
      nppStatus: 'Warning',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 10',
      ppPercentage: 85,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 11',
      ppPercentage: 34,
      nppPercentage: 85,
      ppStatus: 'Warning',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 12',
      ppPercentage: 85,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 13',
      ppPercentage: 85,
      nppPercentage: 58,
      ppStatus: 'Good',
      nppStatus: 'Critical',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 14',
      ppPercentage: 100,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 15',
      ppPercentage: 85,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 16',
      ppPercentage: 85,
      nppPercentage: 100,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 17',
      ppPercentage: 85,
      nppPercentage: 28,
      ppStatus: 'Good',
      nppStatus: 'Warning',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 18',
      ppPercentage: 85,
      nppPercentage: 60,
      ppStatus: 'Good',
      nppStatus: 'Critical',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 19',
      ppPercentage: 85,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 20',
      ppPercentage: 85,
      nppPercentage: 85,
      ppStatus: 'Good',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 21',
      ppPercentage: 55,
      nppPercentage: 85,
      ppStatus: 'Critical',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    WaterTankModel(
      coachNumber: 'Coach 22',
      ppPercentage: 30,
      nppPercentage: 85,
      ppStatus: 'Warning',
      nppStatus: 'Good',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = trainNumbers.first;
      selectedCoachNumber = 'All Coach';
      selectedStatus = 'All';
    });
  }

  Future<void> _refreshData() async {
    // Mock refresh logic
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
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
          icon: const Icon(
            Icons.arrow_back,
            color: ColorConstants.textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 4,
        title: Text(
          AppStrings.waterLevelIndicator,
          style: AppTextStyles.header1,
        ),
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
                  'Last Updated: 10:46 AM',
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

              if (selectedViewType == 'Water Tanks')
                _buildSectionCard(child: _buildWaterTanksSection())
              else if (selectedViewType == 'Chart View')
                _buildSectionCard(child: const ChartView())
              else if (selectedViewType == 'Alerts')
                _buildSectionCard(child: const AlertsView()),
            ],
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
                onChanged: (value) {
                  setState(() {
                    selectedTrainNumber = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: AppStrings.coachNumber,
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (value) {
                  setState(() {
                    selectedCoachNumber = value!;
                  });
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
                onTap: () {
                  setState(() {
                    selectedStatus = 'All';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.good,
                isSelected: selectedStatus == 'Good',
                onTap: () {
                  setState(() {
                    selectedStatus = 'Good';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.warning,
                isSelected: selectedStatus == 'Warning',
                onTap: () {
                  setState(() {
                    selectedStatus = 'Warning';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.critical,
                isSelected: selectedStatus == 'Critical',
                onTap: () {
                  setState(() {
                    selectedStatus = 'Critical';
                  });
                },
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
              onTap: _refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: ColorConstants.divider),
                ),
                child: const Icon(Icons.refresh, size: 18, color: ColorConstants.iconGrey),
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
                label: AppStrings.waterTanks,
                svgIcon: AppIcons.waterDrop,
                isSelected: selectedViewType == 'Water Tanks',
                onTap: () {
                  setState(() {
                    selectedViewType = 'Water Tanks';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.chartView,
                svgIcon: AppIcons.graph,
                isSelected: selectedViewType == 'Chart View',
                onTap: () {
                  setState(() {
                    selectedViewType = 'Chart View';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.alerts,
                svgIcon: AppIcons.alert,
                isSelected: selectedViewType == 'Alerts',
                onTap: () {
                  setState(() {
                    selectedViewType = 'Alerts';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterTanksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.waterTanksTitle,
              style: AppTextStyles.header2,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: ColorConstants.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.train,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '22 Coaches',
                    style: AppTextStyles.badge,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = (constraints.maxWidth - 12) / 2;
            final cardHeight = screenWidth < 360 ? cardWidth * 1.35 : cardWidth * 1.2;
            final aspectRatio = cardWidth / cardHeight;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: aspectRatio,
              ),
          itemCount: waterTanks.length,
          itemBuilder: (context, index) {
            final tank = waterTanks[index];
            return WaterTankCard(
              coachNumber: tank.coachNumber,
              ppPercentage: tank.ppPercentage,
              nppPercentage: tank.nppPercentage,
              ppStatus: tank.ppStatus,
              nppStatus: tank.nppStatus,
              lastUpdated: tank.getFormattedLastUpdated(),
              onEyeIconTap: () {
                showDialog(
                  context: context,
                  builder: (_) => CoachDetailDialog(
                    coachNumber: tank.coachNumber,
                    ppPercentage: tank.ppPercentage,
                    nppPercentage: tank.nppPercentage,
                    ppStatus: tank.ppStatus,
                    nppStatus: tank.nppStatus,
                  ),
                );
              },
            );
          },
            );
          },
        ),
      ],
    );
  }
}