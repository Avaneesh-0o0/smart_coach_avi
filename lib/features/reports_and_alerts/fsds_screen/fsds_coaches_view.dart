import 'package:flutter/material.dart';
import 'data/models/fsds_model.dart';
import 'presentation/widgets/fsds_coach_card.dart';

class FsdsCoachesView extends StatelessWidget {
  final List<FsdsAssetModel> assets;
  const FsdsCoachesView({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No data found matching filters"),
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return FsdsCoachCard(coach: assets[index]);
      },
    );
  }
}
