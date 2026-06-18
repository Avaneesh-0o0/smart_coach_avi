import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/color_constants.dart';
import '../data/models/bc_pressure_model.dart';

class BCPressureCard extends StatelessWidget {
  final BCPressureModel coach;
  final VoidCallback? onEyeIconTap;

  const BCPressureCard({
    super.key,
    required this.coach,
    this.onEyeIconTap,
  });

  static Color _getBCStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return ColorConstants.statusWarning;
      case 'critical':
        return ColorConstants.statusCritical;
      default:
        return ColorConstants.iconGrey;
    }
  }

  Widget _buildStatusIcon(String status) {
    String iconPath;
    switch (status.toLowerCase()) {
      case 'good':
        iconPath = AppIcons.bcGreenIndicate;
        break;
      case 'warning':
        iconPath = AppIcons.bcRedIndicate;
        break;
      case 'critical':
        iconPath = AppIcons.bcYellowIndicate;
        break;
      default:
        iconPath = AppIcons.bcGreenIndicate;
    }
    return SvgPicture.asset(iconPath, width: 28, height: 28);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getBCStatusColor(coach.status);
    final isGood = coach.status.toLowerCase() == 'good';
    final bgColor = isGood
        ? ColorConstants.cardBackground
        : statusColor.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isGood
            ? null
            : Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Coach number + Eye icon ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  coach.coachNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: ColorConstants.primary,
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
          const SizedBox(height: 8),

          // ── Row 2: Status icon + Status badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusIcon(coach.status),
              _buildStatusBadge(coach.status, statusColor, isGood),
            ],
          ),
          const SizedBox(height: 8),

          // ── Info rows ──
          _buildInfoRow('Pressure:', '${coach.pressure} Kg/cm\u00B2'),
          const SizedBox(height: 2),
          _buildInfoRow('BA:', coach.brakeApplied),
          const SizedBox(height: 2),

          // Brake Released or warning message
          if (coach.warningMessage != null)
            Text(
              coach.warningMessage!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: statusColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            _buildInfoRow('BR:', coach.brakeReleased),

          const SizedBox(height: 8),

          // ── Updated time ──
          Text(
            coach.getFormattedLastUpdated(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF898989),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, bool isGood) {
    // All statuses get a tinted pill background
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '\u2022 $status',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColorConstants.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textSecondary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
