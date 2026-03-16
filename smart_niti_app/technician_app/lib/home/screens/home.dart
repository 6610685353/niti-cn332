import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';
import '../models/task_model.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeScreen({Key? key, required this.onProfileTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 20),
              Column(
                children: homeMockTasks
                    .map(
                      (task) => TaskCard(
                        id: task.id,
                        title: task.title,
                        tag: task.tag,
                        time: task.time,
                        location: task.location,
                        tagColor: task.tagColor,
                      ),
                    )
                    .toList(),
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
            // กดรูปโปรไฟล์
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }
}
