// lib/resident/features/repair_history/models/repair_ticket_model.dart

class TicketStatus {
  static const String submitted = 'submitted';
  static const String assigned = 'assigned';
  static const String inProgress = 'in_progress';
  static const String done = 'done';
  static const String cancelled = 'cancelled';
}

class TicketCategory {
  static const String plumbing = 'plumbing';
  static const String electric = 'electric';
  static const String hvac = 'hvac';
  static const String other = 'other';

  static String toDisplay(String category) {
    switch (category) {
      case plumbing:
        return 'PLUMBING';
      case electric:
        return 'ELECTRICAL';
      case hvac:
        return 'HVAC';
      default:
        return 'GENERAL';
    }
  }
}

class RepairTicket {
  final int id;
  final String reqUserId;
  final String? assignedToId;
  final String category;
  final String title;
  final String? detailDesc;
  final String inUnitLocation;
  final String targetDate;
  final String startTime;
  final String endTime;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? closedAt;

  RepairTicket({
    required this.id,
    required this.reqUserId,
    this.assignedToId,
    required this.category,
    required this.title,
    this.detailDesc,
    required this.inUnitLocation,
    required this.targetDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  factory RepairTicket.fromJson(Map<String, dynamic> json) {
    return RepairTicket(
      id: json['id'],
      reqUserId: json['req_user_id'] ?? '',
      assignedToId: json['assigned_to_id'],
      category: json['category'] ?? 'other',
      title: json['title'] ?? '',
      detailDesc: json['detail_desc'],
      inUnitLocation: json['in_unit_location'] ?? '',
      targetDate: json['target_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? TicketStatus.submitted,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      closedAt: json['closed_at'],
    );
  }

  /// แปลงสถานะ backend → index สำหรับ UI tracking steps
  /// Steps: 0=On Way, 1=Arrived, 2=Repairing, 3=Done
  int get trackingStepIndex {
    switch (status) {
      case TicketStatus.submitted:
        return 0;
      case TicketStatus.assigned:
        return 1;
      case TicketStatus.inProgress:
        return 2;
      case TicketStatus.done:
        return 3;
      default:
        return 0;
    }
  }

  bool get isCancelled => status == TicketStatus.cancelled;
  bool get isDone => status == TicketStatus.done;
  bool get isActive =>
      status != TicketStatus.done && status != TicketStatus.cancelled;

  String get displayCategory => TicketCategory.toDisplay(category);

  /// แปลง target_date เป็น format แสดงผล เช่น "Oct 26, 2023"
  String get formattedDate {
    try {
      final parts = targetDate.split('-');
      if (parts.length != 3) return targetDate;
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[int.parse(parts[1]) - 1];
      return '$month ${parts[2]}, ${parts[0]}';
    } catch (_) {
      return targetDate;
    }
  }

  /// แปลง created_at เป็น format แสดงผล เช่น "May 12, 2023"
  String get formattedCreatedDate {
    try {
      final dt = DateTime.parse(createdAt);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  /// แปลง created_at เป็น time เช่น "10:30 AM"
  String get formattedCreatedTime {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  /// แปลง time slots เช่น "10:00:00" → "10:00"
  String get formattedTimeSlot {
    final s = startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
    final e = endTime.length >= 5 ? endTime.substring(0, 5) : endTime;
    return '$s - $e';
  }
}
