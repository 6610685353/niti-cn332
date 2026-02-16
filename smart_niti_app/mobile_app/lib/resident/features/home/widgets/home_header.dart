import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  const HomeHeader({
    super.key,
    this.onNotificationTap,
    this.hasNotification = false, // default ไม่แสดง
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 10),
      child: Row(
        children: [
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Smart Niti",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(
                  "Residential Management",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // 🔔 Notification + Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: onNotificationTap,
                  iconSize: 25.5,
                  padding: EdgeInsets.zero,
                ),
              ),

              // 🔴 จุดแดง
              if (hasNotification)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
