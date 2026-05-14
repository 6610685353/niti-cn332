import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';
import '../../work_order/models/work.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeScreen({Key? key, required this.onProfileTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // งานที่ยังไม่ Done และไม่ Cancelled
    final activeTasks = mockWorkOrdersList
        .where((o) => o.status != 'Done' && o.status != 'Cancelled')
        .toList();

    // งานที่ยังไม่ได้ Accept (แสดง Accept Job)
    final pendingAccept = activeTasks
        .where((o) => !(o.isAccepted ?? false))
        .toList();
    // งานที่ Accept แล้ว (แสดง Update Progress)
    final acceptedTasks = activeTasks
        .where((o) => o.isAccepted ?? false)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildWorkSummary(),
              const SizedBox(height: 30),

              // ── ส่วนงานที่ต้อง Accept ──────────────────
              if (pendingAccept.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Assignments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    _buildChip(
                      '${pendingAccept.length} pending',
                      const Color(0xFFFFF3E0),
                      const Color(0xFFFED7AA),
                      const Color(0xFFEA580C),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: pendingAccept
                      .map((order) => TaskCard(workOrder: order))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ── ส่วนงานที่กำลังดำเนินการ ──────────────
              if (acceptedTasks.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    _buildTodayChip(),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: acceptedTasks
                      .map((order) => TaskCard(workOrder: order))
                      .toList(),
                ),
              ],

              // ── ไม่มีงานเลย ────────────────────────────
              if (activeTasks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active tasks today',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.5,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFF8FAFC),
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF475569),
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Technician SNT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Color(0xFF0EA5E9),
                    ),
                  ],
                ),
                Text(
                  'Technician Specialist',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildNotificationBadge(),
      ],
    );
  }

  Widget _buildNotificationBadge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => print("Noti Pressed"),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: Color(0xFF475569),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WORK SUMMARY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textLight,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SummaryCard(
              count: '08',
              label: 'Assigned',
              icon: Icons.assignment_rounded,
              baseColor: const Color(0xFFF43F5E),
            ),
            const SizedBox(width: 12),
            SummaryCard(
              count: '03',
              label: 'Pending',
              icon: Icons.hourglass_top_rounded,
              baseColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 12),
            SummaryCard(
              count: '05',
              label: 'Resolved',
              icon: Icons.check_circle_rounded,
              baseColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayChip() {
    return _buildChip(
      'Today',
      const Color(0xFFEBF5FF),
      const Color(0xFFBFDBFE),
      const Color(0xFF1D4ED8),
    );
  }

  Widget _buildChip(
    String label,
    Color bgColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
