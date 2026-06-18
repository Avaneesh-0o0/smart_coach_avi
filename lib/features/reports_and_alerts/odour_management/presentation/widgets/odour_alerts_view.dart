import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';

class OdourAlertsView extends StatelessWidget {
  final List<OdourCoachModel> records;
  const OdourAlertsView({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final alerts = records.where((r) => r.hasAlert).toList();
    final warnings = records.where((r) => r.isActive && !r.hasAlert && r.reading > 50).toList();

    if (alerts.isEmpty && warnings.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Alerts", style: AppTextStyles.header2),
          const SizedBox(height: 16),
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('No active alerts', style: TextStyle(color: Colors.grey)),
          )),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Alerts", style: AppTextStyles.header2),
            Row(children: [
              if (alerts.isNotEmpty) _badge('${alerts.length} High', const Color(0xFFD32F2F)),
              if (warnings.isNotEmpty) ...[const SizedBox(width: 6), _badge('${warnings.length} Warning', const Color(0xFFBE8B22))],
            ]),
          ],
        ),
        const SizedBox(height: 16),
        ...alerts.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(a, Icons.warning_amber_rounded, const Color(0xFFFFEBEE), const Color(0xFFD32F2F),
            'High Odour: Coach ${a.coachNumber} (${a.toiletPosition})',
            'Reading: ${a.reading} ppm | ${_fmt(a.timestamp)}'),
        )),
        ...warnings.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(w, Icons.info_outline, const Color(0xFFFFF8E1), const Color(0xFFBE8B22),
            'Moderate: Coach ${w.coachNumber} (${w.toiletPosition})',
            'Reading: ${w.reading} ppm | ${_fmt(w.timestamp)}'),
        )),
      ],
    );
  }

  String _fmt(String ts) {
    try { return DateFormat('dd MMM, HH:mm').format(DateTime.parse(ts)); }
    catch (_) { return ts; }
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );

  Widget _buildCard(OdourCoachModel r, IconData icon, Color bg, Color iconColor, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: iconColor)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: iconColor.withOpacity(0.8))),
          ])),
        ],
      ),
    );
  }
}
