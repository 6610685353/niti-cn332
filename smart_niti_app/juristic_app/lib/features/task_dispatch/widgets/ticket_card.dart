import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class TicketCard extends StatelessWidget {
  final String location, roomType, tag, title, description, timeAgo, assignedTo;
  final Color tagColor, tagBgColor;

  final bool isSelected;
  final VoidCallback? onTap;
  // 🌟 เพิ่มฟังก์ชัน onUnassign สำหรับรับคำสั่งยกเลิกงาน
  final VoidCallback? onUnassign;

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
    this.isSelected = false,
    this.onTap,
    this.onUnassign, // 👈 อย่าลืมรับค่าตรงนี้
  });

  @override
  Widget build(BuildContext context) {
    bool isUnassigned = assignedTo == "-";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
            // 🌟 ปรับปรุงส่วนล่างสุดของ Card ให้รองรับปุ่ม Unassign ได้แบบไม่ซ้อนทับ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
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
                      // 🌟 ถ้ามีการส่งฟังก์ชัน onUnassign มา ให้โชว์ปุ่มนี้ต่อท้ายชื่อช่าง
                      if (onUnassign != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: InkWell(
                            onTap: onUnassign,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.person_remove,
                                    size: 12,
                                    color: AppColors.errorRed,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Unassign",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.errorRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // กดปุ่มรูปภาพเพื่อดูรายละเอียดเพิ่มเติม
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
