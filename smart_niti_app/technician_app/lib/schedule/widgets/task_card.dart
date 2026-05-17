import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String location;
  final String startTime;
  final String duration;
  final bool isActive;

  const TaskCard({
    super.key,
    required this.title,
    required this.location,
    required this.startTime,
    required this.duration,
    this.isActive = false,
  });

  String _getEndTime() {
    try {
      final parts = startTime.split(':');
      final durationVal = int.parse(duration.split(' ')[0]);
      final start = DateTime(
        2026,
        1,
        1,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final end = start.add(Duration(minutes: durationVal));
      return "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "--:--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2B468B).withOpacity(0.3)
              : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF2B468B)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$startTime - ${_getEndTime()}",
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                duration,
                style: TextStyle(
                  color: isActive ? const Color(0xFF2B468B) : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isActive ? const Color(0xFF1A2E4C) : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 14,
                color: isActive ? const Color(0xFF2B468B) : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF5B6E95)
                      : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (isActive) ...[const SizedBox(height: 12), _buildActiveBadge()],
        ],
      ),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            "IN PROGRESS",
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
