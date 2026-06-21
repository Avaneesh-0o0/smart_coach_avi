import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';
import '../odour_coach_washrooms_screen.dart';

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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OdourCoachWashroomsScreen(group: group),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: group.alertToilets > 0 ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: group.alertToilets > 0 ? Colors.red.withOpacity(0.15) : ColorConstants.divider,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: wc.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.air, color: wc, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach ${group.coachNumber}',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
                    Text('${group.trainNumber} - ${group.trainName}',
                      style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${group.totalToilets} Washrooms',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: ColorConstants.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Peak: ${displayReading.toStringAsFixed(0)} ppm',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: wc)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: ColorConstants.textSecondary, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
