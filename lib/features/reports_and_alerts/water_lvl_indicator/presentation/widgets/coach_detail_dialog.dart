import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/water_lvl_indicator/presentation/fulltank_history.dart';


class CoachDetailDialog extends StatefulWidget {
  final String coachNumber;
  final int ppPercentage;
  final int nppPercentage;
  final String ppStatus;
  final String nppStatus;

  const CoachDetailDialog({
    super.key,
    required this.coachNumber,
    required this.ppPercentage,
    required this.nppPercentage,
    required this.ppStatus,
    required this.nppStatus,
  });

  @override
  State<CoachDetailDialog> createState() => _CoachDetailDialogState();
}

class _CoachDetailDialogState extends State<CoachDetailDialog> {
  bool isPPSelected = true;

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: ColorConstants.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  widget.coachNumber,
                  style: AppTextStyles.header2.copyWith(
                    color: ColorConstants.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTab('PP Tank', isPPSelected, () {
                          setState(() => isPPSelected = true);
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTab('NPP Tank', !isPPSelected, () {
                          setState(() => isPPSelected = false);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Percentage + Status + Progress Bar
                  Row(
                    children: [
                      Text(
                        '$_currentPercentage%',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(_currentStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentStatus,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(_currentStatus),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _currentPercentage / 100,
                            minHeight: 18,
                            backgroundColor: ColorConstants.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(_currentStatus),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Details Table
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorConstants.divider),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Height', '180 cm', showTopBorder: false),
                        _buildDetailRow('Width', '120 cm'),
                        _buildDetailRow('Length', '220 cm'),
                        _buildDetailRow('Capacity', '1000 Litres'),
                        _buildDetailRow('Sensor ID', 'WLI 125678'),
                        _buildDetailRow('HMID', 'ABC1234589'),
                        _buildDetailRow('Last Updated', 'Today, 10:42AM'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: ColorConstants.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullTankHistory(
                                  coachNumber: widget.coachNumber,
                                  ppPercentage: widget.ppPercentage,
                                  nppPercentage: widget.nppPercentage,
                                  ppStatus: widget.ppStatus,
                                  nppStatus: widget.nppStatus,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium),
                            ),
                          ),
                          child: Text(
                            'View Full History',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? ColorConstants.primary : ColorConstants.divider,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool showTopBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: ColorConstants.divider))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
