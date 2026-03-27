import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import '../widgets/mini_stat_card.dart';
import '../widgets/ticket_card.dart';
import '../widgets/technician_row.dart';

class TaskDispatchPage extends StatefulWidget {
  const TaskDispatchPage({super.key});

  @override
  State<TaskDispatchPage> createState() => _TaskDispatchPageState();
}

class _TaskDispatchPageState extends State<TaskDispatchPage> {
  int _selectedTicketIndex = -1;

  @override
  Widget build(BuildContext context) {
    // 🌟 1. ครอบด้วย GestureDetector เพื่อดักจับการคลิกพื้นที่ว่าง
    return GestureDetector(
      onTap: () {
        if (_selectedTicketIndex != -1) {
          setState(() {
            _selectedTicketIndex = -1; // เคลียร์เป็นค่าว่าง
          });
        }
      },
      behavior: HitTestBehavior.opaque, // สำคัญ: ทำให้กดพื้นหลังได้

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Task Assignment & Dispatch",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- 1. Top Mini Stat Cards ---
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: MiniStatCard(
                      title: "Total Pending Request",
                      value: "2",
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.warningOrange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MiniStatCard(
                      title: "Total Pending Approval",
                      value: "2",
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.warningOrange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MiniStatCard(
                      title: "In progress",
                      value: "4",
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.warningOrange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MiniStatCard(
                      title: "Complete",
                      value: "10",
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.warningOrange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MiniStatCard(
                      title: "Technician Active",
                      value: "5",
                      subValue: "/ 15",
                      icon: Icons.people_alt,
                      iconColor: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 2. Main Content ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ฝั่งซ้าย: Unassigned Tickets
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.priority_high,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Unassigned Tickets (8)",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.filter_list,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ลิสต์การ์ดงาน
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          TicketCard(
                            location: "Building A - Room 512",
                            roomType: "Bathroom",
                            tag: "Plumbing",
                            tagColor: const Color(0xFF0052CC),
                            tagBgColor: const Color(0xFFE6F0FF),
                            title: "Sink pipe leak",
                            description:
                                "Major water leak reported in master bathroom. Flooding neighbor below.",
                            timeAgo: "12 mins ago",
                            assignedTo: "-",
                            isSelected: _selectedTicketIndex == 0,
                            onTap: () {
                              setState(() {
                                // 🌟 2. กดซ้ำเพื่อยกเลิกการเลือก
                                _selectedTicketIndex = _selectedTicketIndex == 0
                                    ? -1
                                    : 0;
                              });
                            },
                          ),
                          TicketCard(
                            location: "Building C - Room 112",
                            roomType: "Bathroom",
                            tag: "Plumbing",
                            tagColor: const Color(0xFF0052CC),
                            tagBgColor: const Color(0xFFE6F0FF),
                            title: "Water Heater Leak",
                            description:
                                "Water heater leaking in bathroom. Water pooling on floor.",
                            timeAgo: "34 mins ago",
                            assignedTo: "Jane Doe",
                            isSelected: _selectedTicketIndex == 1,
                            onTap: () {
                              setState(() {
                                _selectedTicketIndex = _selectedTicketIndex == 1
                                    ? -1
                                    : 1;
                              });
                            },
                          ),
                          TicketCard(
                            location: "Building B - Room 378",
                            roomType: "Living Room",
                            tag: "Electric",
                            tagColor: const Color(0xFFFFAB00),
                            tagBgColor: const Color(0xFFFFF0D4),
                            title: "Power Outlet Not Working",
                            description:
                                "Multiple power outlets not functioning in living room.",
                            timeAgo: "1 hour ago",
                            assignedTo: "-",
                            isSelected: _selectedTicketIndex == 2,
                            onTap: () {
                              setState(() {
                                _selectedTicketIndex = _selectedTicketIndex == 2
                                    ? -1
                                    : 2;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // ฝั่งขวา: Technician Availability & Workload
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF36B37E),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.engineering,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Technician Availability & Workload",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Showing active members only",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Staff Member",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Current Workload",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 90), // พื้นที่ปุ่ม
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 4),
                          child: Divider(height: 1),
                        ),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            TechnicianRow(
                              name: "Jane Doe",
                              role: "Plumbing Technician",
                              currentTasks: 3,
                              roleColor: Color(0xFF36B37E),
                            ),
                            Divider(height: 1, thickness: 0.5),
                            TechnicianRow(
                              name: "Sarah Smith",
                              role: "Electrical Technician",
                              currentTasks: 1,
                              roleColor: Color(0xFF0052CC),
                            ),
                            Divider(height: 1, thickness: 0.5),
                            TechnicianRow(
                              name: "Mike Ross",
                              role: "HVAC Technician",
                              currentTasks: 4,
                              roleColor: Color(0xFFFFAB00),
                            ),
                            Divider(height: 1, thickness: 0.5),
                            TechnicianRow(
                              name: "Dave Miller",
                              role: "HVAC Technician",
                              currentTasks: 0,
                              roleColor: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
