import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final Color color;
  final IconData icon;
  final String? trend;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    required this.color,
    required this.icon,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // กำหนดความสูงขั้นต่ำคงที่ เพื่อให้การ์ดทุกใบสูงเท่ากันและไม่เกิด Error
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ใช้ MainAxisSize.min เพื่อให้ Column ไม่พยายามขยายตัวเกินความจำเป็น
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != null)
                Text(
                  trend!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          // แก้ตรงนี้: เปลี่ยนจาก Spacer() เป็นระยะห่างคงที่
          const SizedBox(height: 24),

          Text(
            title,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subValue != null)
                Text(
                  " $subValue",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
