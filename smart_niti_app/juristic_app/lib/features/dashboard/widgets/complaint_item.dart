import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class ComplaintItem extends StatelessWidget {
  final String unit;
  final String category;
  final String title;
  final String description;
  final String timeAgo; // ระยะเวลา เช่น "2 mins ago"
  final String userName;
  final String status;
  final Color statusColor;

  const ComplaintItem({
    super.key,
    required this.unit,
    required this.category,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.userName,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- บรรทัดบนสุด: Unit & Category (ชิดซ้าย) และ Time Ago (ชิดขวา) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$unit • $category",
              style: const TextStyle(
                color: Color(0xFF0052CC), // สีน้ำเงินตามรูป
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              timeAgo, // ตำแหน่ง "2 mins ago" ตามในรูป Figma
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // --- หัวข้อปัญหา (ตัวหนา) ---
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF172B4D),
          ),
        ),

        // --- รายละเอียดปัญหา (ตัวบาง) ---
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 12),

        // --- บรรทัดล่าง: รูป Profile + ชื่อ (ชิดซ้าย) และ Status Tag (ชิดขวา) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, size: 14, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Status Tag เช่น Urgent, Normal, Low
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // เส้นคั่นระหว่างรายการ
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
