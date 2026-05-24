import 'package:intl/intl.dart';

class WorkOrder {
  final int backendId; // ID จริงจาก backend (int) ใช้สำหรับ API calls
  final String id; // Display ID เช่น '#TK-42'
  final String status; // 'Pending' | 'Repairing' | 'Done' | 'Cancelled'
  final String category;
  final bool isUrgent;
  final String title;
  final String description;
  final String location;
  final String scheduledTime;
  final bool? isAccepted;
  final String? assigneeName;
  final String? assigneeRole;
  final int? rating;
  final String? residentName;
  final String? reqUserId;

  WorkOrder({
    required this.backendId,
    required this.id,
    required this.status,
    required this.category,
    required this.isUrgent,
    required this.title,
    required this.description,
    required this.location,
    required this.scheduledTime,
    this.isAccepted = false,
    this.assigneeName,
    this.assigneeRole,
    this.rating,
    this.residentName,
    this.reqUserId,
  });

  // ─── Status mapping ──────────────────────────────────────────────────────
  // Backend          │ Frontend status │ isAccepted │ UI Button
  // ─────────────────┼─────────────────┼────────────┼────────────────────
  // submitted        │ Submitted       │ false      │ (ไม่ควรเจอใน tech app)
  // assigned         │ Pending         │ false      │ Accept Job
  // in_progress      │ Repairing       │ true       │ Update Progress
  // done             │ Done            │ true       │ (read-only)
  // cancelled        │ Cancelled       │ false      │ (read-only)

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    final backendStatus = json['status'] as String;
    final frontendStatus = _mapStatus(backendStatus);
    final isAccepted =
        backendStatus == 'in_progress' || backendStatus == 'done';

    // Format scheduled time: "17 May 2025 • 09:00 - 10:00"
    final targetDate = json['target_date'] as String? ?? '';
    final startTime = _trimSeconds(json['start_time'] as String? ?? '');
    final endTime = _trimSeconds(json['end_time'] as String? ?? '');
    String scheduledTime = targetDate;
    if (startTime.isNotEmpty) {
      scheduledTime = _formatDate(targetDate);
      scheduledTime += ' • $startTime';
      if (endTime.isNotEmpty) scheduledTime += ' - $endTime';
    }

    return WorkOrder(
      backendId: json['id'] as int,
      id: '#TK-${json['id']}',
      status: frontendStatus,
      category: (json['category'] as String).toUpperCase(),
      isUrgent: false, // backend ไม่มี field นี้ ใช้ default
      title: json['title'] as String? ?? '',
      description: json['detail_desc'] as String? ?? '',
      location: json['in_unit_location'] as String? ?? '',
      scheduledTime: scheduledTime,
      isAccepted: isAccepted,
      reqUserId: json['req_user_id'] as String?,
    );
  }

  static String _mapStatus(String s) {
    switch (s) {
      case 'assigned':
        return 'Pending';
      case 'in_progress':
        return 'Repairing';
      case 'done':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Submitted';
    }
  }

  /// แปลง backendStatus กลับ เช่น 'Repairing' → 'in_progress'
  static String toBackendStatus(String frontendStatus) {
    switch (frontendStatus) {
      case 'Pending':
        return 'assigned';
      case 'Repairing':
        return 'in_progress';
      case 'Done':
        return 'done';
      case 'Cancelled':
        return 'cancelled';
      default:
        return 'submitted';
    }
  }

  static String _trimSeconds(String t) {
    // "09:00:00" → "09:00"
    if (t.length >= 5) return t.substring(0, 5);
    return t;
  }

  static String _formatDate(String isoDate) {
    try {
      final d = DateTime.parse(isoDate);
      return DateFormat('d MMM yyyy').format(d);
    } catch (_) {
      return isoDate;
    }
  }
}
