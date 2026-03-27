import 'package:flutter/material.dart';

class Complaint {
  final String unit;
  final String category;
  final String title;
  final String description;
  final String timeAgo;
  final String userName;
  final String status; // Urgent, Normal, Low
  final Color statusColor;

  Complaint({
    required this.unit,
    required this.category,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.userName,
    required this.status,
    required this.statusColor,
  });
}
