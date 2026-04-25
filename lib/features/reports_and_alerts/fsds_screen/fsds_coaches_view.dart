import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/presentation/widgets/fire_detected_modal.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/presentation/widgets/fsds_coach_card.dart';
import '../acp_screen/data/models/acp_model.dart';

class FsdsCoachesView extends StatelessWidget {
  final List<AcpCoachModel> coaches;

  const FsdsCoachesView({super.key, required this.coaches});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.fsdsMonitoringSection, style: AppTextStyles.header2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstants.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.train,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${coaches.length} Coaches',
                      style: AppTextStyles.badge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dynamic height grid using Wrap
        Builder(
          builder: (context) {
            final double horizontalPadding = AppDimensions.paddingLarge * 2; // Dashboard padding
            final double cardPadding = AppDimensions.paddingLarge * 2; // Section card padding
            final double availableWidth = MediaQuery.of(context).size.width - horizontalPadding - cardPadding;
            
            final double spacing = 12;
            final int crossAxisCount = availableWidth > 600 ? 3 : 2;
            final double itemWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: coaches.map((coach) {
                return SizedBox(
                  width: itemWidth,
                  child: FsdsCoachCard(
                    coach: coach,
                    onEyeIconTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => FireDetectedModal(coach: coach),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
