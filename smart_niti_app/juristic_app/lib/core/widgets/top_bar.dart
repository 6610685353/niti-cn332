import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData icon;
  final String title;
  final int? selectedIndex;
  final Function(int)? onMenuTap;

  const TopBar({
    super.key,
    required this.icon,
    required this.title,
    this.selectedIndex,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final List<String> menuItems = [
      'Dashboard',
      'Task Dispatch',
      'Announcement',
      'Parcel',
    ];

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade200, height: 1.0),
      ),
      titleSpacing: 32,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        if (selectedIndex != null) ...[
          Row(
            children: List.generate(menuItems.length, (index) {
              bool isActive = selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: TextButton(
                  onPressed: () {
                    if (isActive) return;
                    if (onMenuTap != null) onMenuTap!(index);
                  },
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    menuItems[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.primaryBlue
                          : AppColors.darkGrey,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 5),

          // 🌟 ปุ่มกระดิ่ง Notification ที่มีกรอบและกดได้
          _buildNotificationButton(),

          const SizedBox(width: 16),

          // 🌟 ปุ่ม Logout ที่มีกรอบพื้นหลังสีเทา
          _buildLogoutButton(context),

          const SizedBox(width: 32),
        ],
      ],
    );
  }

  // แยก Widget ปุ่ม Notification ให้จัดการง่ายๆ
  Widget _buildNotificationButton() {
    return Material(
      color: AppColors.greystroke, // สีพื้นหลังเทาอ่อนตาม Figma
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // TODO: ใส่ Action เปิดหน้าต่าง Notification ตรงนี้
          debugPrint("Notification Clicked!");
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.notifications, color: Colors.black87, size: 20),
        ),
      ),
    );
  }

  // แยก Widget ปุ่ม Logout
  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: AppColors.greystroke, // สีเดียวกับปุ่มกระดิ่ง
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ), // จัด Padding ให้ปุ่มกว้างกำลังดี
          child: Row(
            children: const [
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.logout_rounded, size: 16, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}
