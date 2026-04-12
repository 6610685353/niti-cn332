enum RepairStatus { completed, cancelled }

class RepairHistoryItem {
  final String category;
  final String title;
  final String date;
  final String time;
  final String technicianName;
  final String technicianRole;
  final RepairStatus status;
  final double rating;

  RepairHistoryItem({
    required this.category,
    required this.title,
    required this.date,
    required this.time,
    required this.technicianName,
    required this.technicianRole,
    required this.status,
    this.rating = 0,
  });
}
