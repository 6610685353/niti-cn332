import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/features/juristic/juristic_facade.dart';
import 'package:juristic_app/features/home/models/ticket_model.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final JuristicFacade _facade = JuristicFacade();

  List<TicketModel> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // โหลดงานที่เสร็จแล้ว และกรองอันที่เคยกดเคลียร์ทิ้งไป
  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final allTickets = await _facade.getTickets();
      final prefs = await SharedPreferences.getInstance();
      final clearedIds = prefs.getStringList('cleared_notifications') ?? [];

      // กรองเอาเฉพาะ TicketStatus.done และยังไม่เคยถูก Clear
      final doneTickets = allTickets.where((t) {
        return t.status == TicketStatus.done &&
            !clearedIds.contains(t.id.toString());
      }).toList();

      if (mounted) {
        setState(() {
          _notifications = doneTickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันเคลียร์การแจ้งเตือนทั้งหมด
  Future<void> _clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final clearedIds = prefs.getStringList('cleared_notifications') ?? [];

    // เอา ID ของโนติปัจจุบัน ไปรวมกับที่เคยเคลียร์ไว้แล้ว
    final newClearedIds = _notifications.map((t) => t.id.toString()).toList();
    clearedIds.addAll(newClearedIds);

    await prefs.setStringList('cleared_notifications', clearedIds);

    setState(() {
      _notifications.clear();
    });
  }

  // เปิด Popup รายการแจ้งเตือน
  void _showNotificationPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent, // ไม่ต้องทำพื้นหลังมืด
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 24),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 350,
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                  ), // ล็อกความสูงเพื่อทำ Scroll
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header & Clear Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Notifications",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_notifications.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  _clearAllNotifications();
                                  Navigator.of(
                                    context,
                                  ).pop(); // ปิด Popup หลังกดเคลียร์
                                },
                                child: const Text(
                                  "Clear All",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Scrollable List
                      Flexible(
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _notifications.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications_off_outlined,
                                        size: 40,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "No new notifications",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _notifications.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final ticket = _notifications[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.successGreen
                                          .withOpacity(0.1),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: AppColors.successGreen,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      "งานซ่อม ${ticket.inUnitLocation} เสร็จสิ้น",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      ticket.title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return IconButton(
      // 🌟 1. เติมคำว่า async เข้าไปตรงนี้
      onPressed: () async {
        // 🌟 2. ใส่ await เพื่อบังคับให้รอโหลดข้อมูลจากหลังบ้านให้เสร็จก่อน
        await _loadNotifications();

        // 🌟 3. โหลดเสร็จเรียบร้อย ค่อยสั่งให้ Popup เด้งขึ้นมา (จะไม่หมุนค้างแล้ว!)
        if (mounted) {
          _showNotificationPanel(context);
        }
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 24,
            color: AppColors.darkGrey,
          ),
          if (_notifications.isNotEmpty)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.errorRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_notifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
