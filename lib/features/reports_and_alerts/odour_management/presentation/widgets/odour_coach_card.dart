import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';
import 'odour_modal.dart';

class OdourCoachCard extends StatelessWidget {
  final OdourCoachModel coach;

  const OdourCoachCard({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final double score = coach.hygieneScore;
    final String status = score >= 70 ? 'Good' : score >= 50 ? 'Warning' : 'Critical';
    final Color statusColor = status == 'Good' ? Colors.green : status == 'Warning' ? ColorConstants.statusWarning : ColorConstants.statusCritical;
    final bool isOpen = coach.doorStatus.toLowerCase() == 'open';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => OdourModal(coach: coach),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1 & 2: Hygiene Score & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.toiletPosition,
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${score.toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor)),
                          const SizedBox(width: 4),
                          Text(status, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (coach.hasAlert)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: ColorConstants.statusCritical, shape: BoxShape.circle),
                    child: const Icon(Icons.priority_high, color: Colors.white, size: 12),
                  )
              ],
            ),
            const Spacer(),
            // 3: Door Status & Last Activity
            Row(
              children: [
                Icon(isOpen ? Icons.door_front_door : Icons.door_front_door_outlined, size: 14, color: isOpen ? ColorConstants.statusWarning : ColorConstants.iconGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Door ${coach.doorStatus}',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: ColorConstants.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Last: ${isOpen ? coach.lastOpenedTime : coach.lastClosedTime}',
              style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 4: Current Odour Reading (VOC)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: ColorConstants.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
              child: Text(
                'VOC: ${coach.voc.toStringAsFixed(2)} ppb',
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: ColorConstants.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
