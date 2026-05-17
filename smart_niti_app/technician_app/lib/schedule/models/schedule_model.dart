import '../../../work_order/models/work.dart';

enum ScheduleItemType { task, breakTime }

class ScheduleModel {
  final int backendId;
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String startTime; // "HH:MM"
  final String duration;
  final bool isActive;
  final ScheduleItemType type;

  ScheduleModel({
    this.backendId = 0,
    required this.id,
    this.title = '',
    this.location = '',
    required this.date,
    required this.startTime,
    this.duration = '',
    this.isActive = false,
    this.type = ScheduleItemType.task,
  });

  factory ScheduleModel.fromWorkOrder(WorkOrder order) {
    // scheduledTime format: "17 May 2025 • 09:00 - 10:00"
    // หรือ "2025-05-17 • 09:00 - 10:00" ขึ้นอยู่กับ backend
    String startTime = '';
    String duration = '';
    DateTime date = DateTime.now();

    try {
      final parts = order.scheduledTime.split('•');
      final datePart = parts[0].trim();
      date = _parseDate(datePart);

      if (parts.length > 1) {
        final timePart = parts[1].trim(); // "09:00 - 10:00"
        final timeParts = timePart.split('-');
        startTime = timeParts[0].trim();
        if (timeParts.length > 1) {
          final endTime = timeParts[1].trim();
          duration = '${_minutesBetween(startTime, endTime)} min';
        }
      }
    } catch (_) {}

    return ScheduleModel(
      backendId: order.backendId,
      id: order.id,
      title: order.title,
      location: order.location,
      date: date,
      startTime: startTime,
      duration: duration,
      isActive: order.status == 'Repairing',
    );
  }

  static DateTime _parseDate(String s) {
    // รองรับ "2025-05-17" และ "17 May 2025"
    try {
      return DateTime.parse(s);
    } catch (_) {
      // แปลง "17 May 2025"
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final parts = s.split(' ');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = months[parts[1]] ?? 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;
        return DateTime(year, month, day);
      }
      return DateTime.now();
    }
  }

  static int _minutesBetween(String start, String end) {
    try {
      final s = start.split(':');
      final e = end.split(':');
      final startMin = int.parse(s[0]) * 60 + int.parse(s[1]);
      final endMin = int.parse(e[0]) * 60 + int.parse(e[1]);
      return (endMin - startMin).abs();
    } catch (_) {
      return 60;
    }
  }
}
