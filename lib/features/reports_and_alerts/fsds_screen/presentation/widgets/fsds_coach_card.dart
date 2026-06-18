import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/fsds_model.dart';
import 'fsds_modal.dart';

class FsdsCoachCard extends StatelessWidget {
  final FsdsAssetModel coach;
  final VoidCallback? onEyeIconTap;

  const FsdsCoachCard({super.key, required this.coach, this.onEyeIconTap});

  @override
  Widget build(BuildContext context) {
    final bool isBypassOn = coach.isBypassOn;
    final bool isAlert = coach.isAlertActive;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => FsdsModal(coach: coach),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAlert ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: isAlert ? Colors.red.withValues(alpha: 0.1) : ColorConstants.divider.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    coach.deviceName.isNotEmpty ? coach.deviceName : coach.coachDisplayId,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBypassOn ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Device: ${coach.deviceId}',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: ColorConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Loc: ${coach.location}',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: ColorConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Train: ${coach.trainNo} - ${coach.trainName}',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: ColorConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric("Bypass", coach.bypassStatusText, isBypassOn ? Colors.orange : Colors.green),
                _buildMetric("Alert", coach.alertStatusText, isAlert ? Colors.red : Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textTertiary)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
