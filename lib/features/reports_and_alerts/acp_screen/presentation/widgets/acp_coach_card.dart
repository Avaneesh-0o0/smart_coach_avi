import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_dimensions.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/utils/color_constants.dart';
import '../../data/models/acp_model.dart';

class AcpCoachCard extends StatelessWidget {
  final AcpCoachModel coach;
  final VoidCallback? onEyeIconTap;

  const AcpCoachCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  String _formatDateTime(String? timestamp) {
    if (timestamp == null || timestamp == 'N/A' || timestamp.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('dd-MM-yyyy HH:mm:ss').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecent = coach.isRecent;
    final isOn = coach.isOn;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: !isRecent ? ColorConstants.cardBackground : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: !isRecent
            ? null
            : Border.all(color: Colors.red.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${coach.coachNumber} ${coach.sensorId}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !isRecent ? ColorConstants.primary : const Color(0xFFD32F2F),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEyeIconTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    AppIcons.eye,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.iconGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Text(
            'Device ID: ${coach.deviceId}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorConstants.primary,
            ),
          ),
          
          if (coach.trainNo != 'N/A')
            Text(
              'Train: ${coach.trainNo}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: ColorConstants.textSecondary,
              ),
            ),

          if (coach.location != 'N/A')
            Text(
              'Location: ${coach.location}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: ColorConstants.textSecondary,
              ),
            ),
          
          const Divider(height: 16, thickness: 0.5),

          // COUNT / TOTAL Grid
          Row(
            children: [
              _buildValueCell('COUNT', '${coach.status} nos'),
              const SizedBox(width: 12),
              _buildValueCell('TOTAL', '${coach.totalCount} nos'),
            ],
          ),
          
          const SizedBox(height: 8),

          // PULLED & RECENT Indicators (Vertical Stack)
          _buildStatusIndicator(
            'STATUS', 
            coach.isChainPulled ? 'PULLED' : 'NOT PULLED', 
            !coach.isChainPulled,
          ),
          const SizedBox(height: 4),
          _buildStatusIndicator(
            'RECENT', 
            isRecent ? 'RECENTLY TRIGGERED' : 'NOT RECENTLY TRIGGERED', 
            !isRecent,
          ),
          
          const SizedBox(height: 12),

          // Bottom: Toggle + Formatted Time (Removed the Status Chip)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildToggleSwitch(isOn),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    _formatDateTime(coach.updateTime),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ColorConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, String status, bool isOk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.check_circle, 
              size: 12, 
              color: isOk ? Colors.green : const Color(0xFFD32F2F),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: GoogleFonts.poppins(fontSize: 8, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSwitch(bool isOn) {
    return Container(
      width: 32,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isOn ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: isOn ? 18 : 2,
            top: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
