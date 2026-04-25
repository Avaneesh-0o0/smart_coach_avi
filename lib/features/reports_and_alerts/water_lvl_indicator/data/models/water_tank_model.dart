class WaterTankModel {
  final String coachNumber;
  final int ppPercentage;
  final int nppPercentage;
  final String ppStatus;
  final String nppStatus;
  final DateTime lastUpdated;

  WaterTankModel({
    required this.coachNumber,
    required this.ppPercentage,
    required this.nppPercentage,
    required this.ppStatus,
    required this.nppStatus,
    required this.lastUpdated,
  });

  String getFormattedLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours} hr ago';
    } else {
      return 'Updated ${difference.inDays} day ago';
    }
  }
}
