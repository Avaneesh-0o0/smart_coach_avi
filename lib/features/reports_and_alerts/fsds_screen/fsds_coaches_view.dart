import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/presentation/widgets/fsds_coach_card.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/presentation/widgets/fsds_modal.dart';

class FsdsCoachesView extends StatelessWidget {
  final List<AcpCoachModel> coaches;
  const FsdsCoachesView({super.key, required this.coaches});

  void _showDetails(BuildContext context, AcpCoachModel coach) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => FsdsModal(coach: coach),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (coaches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.train, size: 64, color: ColorConstants.textTertiary),
              const SizedBox(height: 16),
              Text(
                'No coaches found matching filters',
                style: GoogleFonts.poppins(color: ColorConstants.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: coaches.map((coach) => SizedBox(
            width: width,
            child: FsdsCoachCard(
              coach: coach,
              onEyeIconTap: () => _showDetails(context, coach),
            ),
          )).toList(),
        );
      },
    );
  }
}
