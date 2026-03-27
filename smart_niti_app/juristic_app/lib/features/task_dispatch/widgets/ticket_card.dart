import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class TicketCard extends StatelessWidget {
  final String location, roomType, tag, title, description, timeAgo, assignedTo;
  final Color tagColor, tagBgColor;

  // 🌟 เพิ่ม 2 ตัวนี้เข้ามาเพื่อให้กดเลือกได้
  final bool isSelected;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.location,
    required this.roomType,
    required this.tag,
    required this.tagColor,
    required this.tagBgColor,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.assignedTo,
    this.isSelected = false, // ค่าเริ่มต้นคือไม่ได้ถูกเลือก
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isUnassigned = assignedTo == "-";

    // 🌟 ใช้ GestureDetector หรือ InkWell ครอบเพื่อให้กดได้
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ถ้าถูกเลือก ให้พื้นหลังเป็นสีฟ้าอ่อนๆ และขอบเป็นสีน้ำเงินหนา 2px
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.greystroke,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      roomType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.build, size: 10, color: tagColor),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.darkGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Assigned Technician: ",
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnassigned
                            ? AppColors.errorRed
                            : AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      assignedTo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUnassigned
                            ? AppColors.errorRed
                            : AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    // 🌟 กดปุ่มรูปภาพเพื่อดูรายละเอียดเพิ่มเติม (เช่น รูปภาพของปัญหา)
                  },
                  icon: const Icon(
                    Icons.image,
                    color: Colors.black87,
                    size: 30,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
