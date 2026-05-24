import 'package:flutter/material.dart';

enum TicketStatus {
  submitted,
  assigned,
  inProgress,
  done,
  cancelled;

  static TicketStatus fromString(String s) {
    switch (s) {
      case 'assigned':
        return TicketStatus.assigned;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'done':
        return TicketStatus.done;
      case 'cancelled':
        return TicketStatus.cancelled;
      default:
        return TicketStatus.submitted;
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.submitted:
        return 'Pending Request';
      case TicketStatus.assigned:
        return 'Pending Approval';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.done:
        return 'Completed';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.submitted:
        return const Color(0xFFE5534B); // red
      case TicketStatus.assigned:
        return const Color(0xFFFFAB00); // orange
      case TicketStatus.inProgress:
        return const Color(0xFF0052CC); // blue
      case TicketStatus.done:
        return const Color(0xFF36B37E); // green
      case TicketStatus.cancelled:
        return Colors.grey;
    }
  }
}

class TicketModel {
  final int id;
  final String reqUserId;
  final String? assignedToId;
  final String? assignedById;
  final String category;
  final String title;
  final String? detailDesc;
  final String inUnitLocation;
  final String targetDate;
  final String startTime;
  final String endTime;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  // 🌟 1. เพิ่มฟิลด์สำหรับเก็บรูปภาพ
  final List<String>? imageUrls;
  final List<String> imageFilenames;

  TicketModel({
    required this.id,
    required this.reqUserId,
    this.assignedToId,
    this.assignedById,
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
    this.imageUrls,
    this.imageFilenames = const [], // 🌟 2. รับค่าเข้ามาใน Constructor
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    // 🌟 3. ดึงข้อมูลรูปรองรับทั้งแบบ List ธรรมดาและ List of Objects
    List<String> parsedImages = [];
    if (json['images'] != null) {
      for (var img in json['images']) {
        if (img is String) {
          parsedImages.add(img);
        } else if (img is Map && img['image_url'] != null) {
          parsedImages.add(img['image_url'].toString());
        }
      }
    }

    return TicketModel(
      id: json['id'] as int,
      reqUserId: json['req_user_id'] as String,
      assignedToId: json['assigned_to_id'] as String?,
      assignedById: json['assigned_by_id'] as String?,
      category: json['category'] as String,
      title: json['title'] as String,
      detailDesc: json['detail_desc'] as String?,
      inUnitLocation: json['in_unit_location'] as String,
      targetDate: json['target_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: TicketStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      imageUrls: parsedImages,
      imageFilenames: (json['images'] as List<dynamic>? ?? [])
          .map((img) => (img['image_url'] as String).split('/').last)
          .toList(), // 🌟 4. ใส่ข้อมูลรูปเข้าไป
    );
  }

  /// แปลง category เป็น label แสดงผล
  String get categoryLabel {
    switch (category) {
      case 'plumbing':
        return 'Plumbing';
      case 'electric':
        return 'Electric';
      case 'hvac':
        return 'HVAC';
      default:
        return 'Other';
    }
  }

  /// สีของ category tag
  Color get categoryTagColor {
    switch (category) {
      case 'plumbing':
        return const Color(0xFF0052CC);
      case 'electric':
        return const Color(0xFFFFAB00);
      case 'hvac':
        return const Color(0xFF36B37E);
      default:
        return Colors.grey;
    }
  }

  Color get categoryTagBgColor => categoryTagColor.withOpacity(0.12);

  /// เวลา "X mins ago" จาก createdAt
  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
