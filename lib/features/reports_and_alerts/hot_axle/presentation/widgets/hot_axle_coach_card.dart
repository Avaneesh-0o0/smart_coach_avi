import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';


class HotAxleCoachCard extends StatelessWidget {
  final HotAxleCoachModel coach;
  final VoidCallback? onEyeIconTap;

  const HotAxleCoachCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return ColorConstants.statusCritical;
      case 'critical':
        return ColorConstants.statusWarning;
      default:
        return ColorConstants.iconGrey;
    }
  }

  static Color _getCardBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return ColorConstants.cardBackground;
      case 'warning':
        return const Color(0xFFFFEBEE);
      case 'critical':
        return const Color(0xFFFFF8E1);
      default:
        return ColorConstants.cardBackground;
    }
  }

  static String _getAxleIcon(String status) {
    switch (status.toLowerCase()) {
      case 'warning':
        return AppIcons.axelRed;
      case 'critical':
        return AppIcons.axelYellow;
      default:
        return AppIcons.axelGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(coach.status);
    final isGood = coach.status.toLowerCase() == 'good';
    final bgColor = _getCardBgColor(coach.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  coach.coachNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isGood ? ColorConstants.primary : statusColor,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 10),

          // Row 2: Axle icon + Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                _getAxleIcon(coach.status),
                width: 24,
                height: 24,
              ),
              _buildStatusBadge(coach.status, statusColor, isGood),
            ],
          ),
          const SizedBox(height: 10),

          // Info rows
          _buildInfoRow('Max Temp:', coach.maxTemp),
          const SizedBox(height: 2),
          _buildInfoRow('Axles monitored:', '${coach.axlesMonitored}'),
          const SizedBox(height: 2),
          _buildInfoRow('Axles Issue:', '${coach.axlesIssue}'),

          const SizedBox(height: 10),

          // Timestamp
          Text(
            'Updated ${coach.updateTime}',
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: ColorConstants.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, bool isGood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF575757),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF575757),
          ),
        ),
      ],
    );
  }
}
