import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';

class OdourCoachesView extends StatelessWidget {
  final List<OdourCoachModel> coaches;
  final List<CoachToiletGroup> grouped;

  const OdourCoachesView({
    super.key,
    required this.coaches,
    required this.grouped,
  });

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No coaches found matching filters"),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${grouped.length} Coaches', style: AppTextStyles.header3),
        const SizedBox(height: 16),
        ...grouped.map((group) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _CoachGroupCard(group: group),
        )),
      ],
    );
  }
}

class _CoachGroupCard extends StatelessWidget {
  final CoachToiletGroup group;
  const _CoachGroupCard({required this.group});

  Color _statusColor(String status) {
    if (status == 'Alert') return const Color(0xFFD32F2F);
    if (status == 'Inactive') return const Color(0xFFBE8B22);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final wc = _statusColor(group.worstStatus);
    final displayReading = group.toilets.isNotEmpty
        ? group.toilets.map((t) => t.reading).reduce((a, b) => a > b ? a : b)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: group.alertToilets > 0 ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: group.alertToilets > 0 ? Colors.red.withOpacity(0.15) : ColorConstants.divider,
        ),
      ),
      child: Column(
        children: [
          // Coach header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: wc.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.air, color: wc, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coach ${group.coachNumber}',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
                      Text('${group.trainNumber} - ${group.trainName}',
                        style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${group.totalToilets} Toilets',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
                    const SizedBox(height: 2),
                    Text('Peak: $displayReading ppm',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: wc)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorConstants.divider),
          // Individual toilet rows
          ...group.toilets.map((toilet) => _ToiletRow(toilet: toilet)),
        ],
      ),
    );
  }
}

class _ToiletRow extends StatelessWidget {
  final OdourCoachModel toilet;
  const _ToiletRow({required this.toilet});

  @override
  Widget build(BuildContext context) {
    final isAlert = toilet.hasAlert;
    final isActive = toilet.isActive;
    final readingColor = isAlert ? const Color(0xFFD32F2F) : (isActive ? const Color(0xFF2E7D32) : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            isAlert ? Icons.warning_amber_rounded : (isActive ? Icons.check_circle : Icons.cancel),
            size: 16,
            color: readingColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(toilet.toiletPosition,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: ColorConstants.textPrimary)),
          ),
          Expanded(
            flex: 2,
            child: Text('${toilet.reading} ppm',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: readingColor)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isActive ? const Color(0xFF2E7D32) : Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(toilet.status.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF2E7D32) : Colors.grey)),
          ),
        ],
      ),
    );
  }
}
