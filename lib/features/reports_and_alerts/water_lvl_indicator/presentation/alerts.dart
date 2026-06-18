import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../data/models/water_tank_model.dart';

class AlertsView extends StatelessWidget {
  final List<WaterTankModel> coaches;

  const AlertsView({super.key, required this.coaches});

  @override
  Widget build(BuildContext context) {
    final criticalAlerts = coaches.where((c) => c.status == 'Critical').toList();
    final warningAlerts = coaches.where((c) => c.status == 'Warning').toList();

    if (criticalAlerts.isEmpty && warningAlerts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Alerts', style: AppTextStyles.header2),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('No active alerts', style: AppTextStyles.bodyMedium),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Alerts', style: AppTextStyles.header2),
            Row(
              children: [
                if (criticalAlerts.isNotEmpty)
                  _badge('${criticalAlerts.length} Critical', ColorConstants.statusCritical),
                if (warningAlerts.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _badge('${warningAlerts.length} Warning', ColorConstants.statusWarning),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...criticalAlerts.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertCard(
            icon: Icons.error_outline,
            iconBgColor: const Color(0xFFFFEBEB),
            iconColor: ColorConstants.statusCritical,
            title: 'Critical: Low Water Level',
            titleColor: ColorConstants.statusCritical,
            subtitle: '${c.location.coachName} (${c.coachNumber}) - ${c.averagePercent.toStringAsFixed(0)}% - ${_formatTime(c.timestamp)}',
          ),
        )),
        ...warningAlerts.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertCard(
            icon: Icons.warning_amber_rounded,
            iconBgColor: const Color(0xFFFFF8E1),
            iconColor: ColorConstants.statusWarning,
            title: 'Warning: Low Water Level',
            titleColor: ColorConstants.statusWarning,
            subtitle: '${c.location.coachName} (${c.coachNumber}) - ${c.averagePercent.toStringAsFixed(0)}% - ${_formatTime(c.timestamp)}',
          ),
        )),
      ],
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
