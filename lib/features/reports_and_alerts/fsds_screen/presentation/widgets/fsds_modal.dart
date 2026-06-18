import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/data/models/fsds_model.dart';

class FsdsModal extends StatelessWidget {
  final FsdsAssetModel coach;
  const FsdsModal({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final isBypassOn = coach.isBypassOn;
    final isAlert = coach.isAlertActive;
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isAlert ? const Color(0xFFFFEBEB) : const Color(0xFFE8F5E9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  isAlert ? 'FSDS Bypass Alert' : 'FSDS Bypass Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Device header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isAlert ? const Color(0xFFFFF0F0) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                            child: Icon(
                              isAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: isAlert ? const Color(0xFFEF5350) : const Color(0xFF2E7D32),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coach.deviceName.isNotEmpty ? coach.deviceName : coach.coachDisplayId,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.primary,
                                  ),
                                ),
                                if (coach.coachNumber.isNotEmpty)
                                  Text(
                                    'Coach: ${coach.coachNumber}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: ColorConstants.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAlert ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '\u2022 ${isBypassOn ? "BYPASS" : "NORMAL"}',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Details Grid
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorConstants.divider),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Device ID', coach.deviceId, showTopBorder: false),
                            _buildDetailRow('Device Name', coach.deviceName),
                            _buildDetailRow('Coach ID', coach.coachUniqueId),
                            _buildDetailRow('Coach Number', coach.coachDisplayId.isNotEmpty ? coach.coachDisplayId : coach.coachNumber),
                            _buildDetailRow('Train No', coach.trainNo),
                            _buildDetailRow('Train Name', coach.trainName),
                            _buildDetailRow('Location', coach.location),
                            _buildDetailRow(
                              'FSDS Bypass', 
                              coach.bypassStatusText,
                              valueColor: isBypassOn ? Colors.orange : Colors.green,
                            ),
                            _buildDetailRow(
                              'Alert Status', 
                              coach.alertStatusText,
                              valueColor: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                            ),
                            _buildDetailRow('Sensor ID', coach.sensorId.isNotEmpty ? coach.sensorId : 'N/A'),
                            _buildDetailRow('Timestamp', coach.timestamp),
                            if (coach.remarks.isNotEmpty)
                              _buildDetailRow('Remarks', coach.remarks),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: ColorConstants.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                          ),
                          child: Text('Close', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showTopBorder = true, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showTopBorder ? const Border(top: BorderSide(color: ColorConstants.divider)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
