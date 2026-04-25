import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';

import '../acp_screen/data/models/acp_model.dart';


class FsdsHistoryScreen extends StatefulWidget {
  final AcpCoachModel coach;

  const FsdsHistoryScreen({super.key, required this.coach});

  @override
  State<FsdsHistoryScreen> createState() => _FsdsHistoryScreenState();
}

class _FsdsHistoryScreenState extends State<FsdsHistoryScreen> {
  String selectedPeriod = '7 Days';

  final List<Map<String, String>> historyEntries = const [
    {
      'sensorId': 'FSDS-B5-04',
      'lastPull': 'Yesterday| 10:42 AM',
      'reset': 'Done',
      'trainSpeed': '62 km/h',
      'location': 'Noida',
    },
    {
      'sensorId': 'FSDS-B5-04',
      'lastPull': '04 Feb, 2026| 10:42 AM',
      'reset': 'Done',
      'trainSpeed': '73 km/h',
      'location': 'Ratlam',
    },
  ];

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
        title: Text(AppStrings.fsdsMonitoring, style: AppTextStyles.header1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrainInfoCard(),
              const SizedBox(height: 16),
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.coach.coachNumber} (${AppStrings.fsdsHistory})',
                      style: AppTextStyles.header2,
                    ),
                    const SizedBox(height: 16),
                    PeriodFilter(
                      selected: selectedPeriod,
                      periods: const ['7 Days', '30 Days', 'Custom'],
                      onChanged: (value) =>
                          setState(() => selectedPeriod = value),
                    ),
                    const SizedBox(height: 16),
                    ...historyEntries.map((entry) => _buildHistoryCard(entry)),
                  ],
                ),
              ),
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

  Widget _buildTrainInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.train,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  ColorConstants.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '12615/6 Grand Trunk Express',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Last Updated: 10:46 AM',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, String> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        children: [
          _buildRow('Sensor ID', entry['sensorId']!),
          const Divider(color: ColorConstants.divider),
          _buildRow('Last pull', entry['lastPull']!),
          const Divider(color: ColorConstants.divider),
          _buildRow('Reset', entry['reset']!),
          const Divider(color: ColorConstants.divider),
          _buildRow('Train Speed', entry['trainSpeed']!),
          const Divider(color: ColorConstants.divider),
          _buildRow('Location', entry['location']!),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
