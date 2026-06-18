import 'package:flutter/material.dart';

import '../utils/app_dimensions.dart';
import '../utils/app_text_styles.dart';
import '../utils/color_constants.dart';


class PeriodFilter extends StatelessWidget {
  final String selected;
  final List<String> periods;
  final ValueChanged<String> onChanged;

  const PeriodFilter({
    super.key,
    required this.selected,
    required this.periods,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = selected == period;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < periods.length - 1 ? 6 : 0),
              child: GestureDetector(
                onTap: () => onChanged(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorConstants.primary
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium - 2),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? ColorConstants.white
                          : ColorConstants.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
