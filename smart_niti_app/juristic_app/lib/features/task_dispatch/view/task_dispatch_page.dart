import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/features/home/models/ticket_model.dart';
import 'package:juristic_app/features/juristic/juristic_facade.dart';
import '../widgets/mini_stat_card.dart';
import '../widgets/ticket_card.dart';
import '../widgets/technician_row.dart';

class TaskDispatchPage extends StatefulWidget {
  const TaskDispatchPage({super.key});

  @override
  State<TaskDispatchPage> createState() => _TaskDispatchPageState();
}

class _TaskDispatchPageState extends State<TaskDispatchPage> {
  final _facade = JuristicFacade();

  List<TicketModel> _tickets = [];
  bool _loading = true;
  String? _error;
  int _selectedTicketIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedTicketIndex = -1;
    });
    try {
      final tickets = await _facade.getTickets();
      setState(() {
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ─── filtered lists ────────────────────────────────────────────

  List<TicketModel> get _unassigned =>
      _tickets.where((t) => t.status == TicketStatus.submitted).toList();

  List<TicketModel> get _assigned =>
      _tickets.where((t) => t.status == TicketStatus.assigned).toList();

  List<TicketModel> get _inProgress =>
      _tickets.where((t) => t.status == TicketStatus.inProgress).toList();

  List<TicketModel> get _done =>
      _tickets.where((t) => t.status == TicketStatus.done).toList();

  // ─── build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 1100;

        return GestureDetector(
          onTap: () {
            if (_selectedTicketIndex != -1) {
              setState(() => _selectedTicketIndex = -1);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Task Assignment & Dispatch",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ── Mini Stat Cards ──────────────────────────────
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // เอา Expanded ที่คลุมตรงนี้ออกไปแล้ว
                      _buildStatCard(
                        "Total Pending Request",
                        "${_unassigned.length}",
                        Icons.assignment_outlined,
                        AppColors.errorRed,
                        constraints.maxWidth,
                      ),
                      _buildStatCard(
                        "Pending Approval",
                        "${_assigned.length}",
                        Icons.assignment_outlined,
                        AppColors.warningOrange,
                        constraints.maxWidth,
                      ),
                      _buildStatCard(
                        "In Progress",
                        "${_inProgress.length}",
                        Icons.assignment_outlined,
                        AppColors.primaryBlue,
                        constraints.maxWidth,
                      ),
                      _buildStatCard(
                        "Complete",
                        "${_done.length}",
                        Icons.check_circle_outline,
                        AppColors.successGreen,
                        constraints.maxWidth,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Main Content ─────────────────────────────────
                  isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUnassignedTickets(),
                            const SizedBox(height: 24),
                            _buildTechnicianAvailability(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildUnassignedTickets()),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 5,
                              child: _buildTechnicianAvailability(),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double maxWidth, {
    String? subValue,
  }) {
    double cardWidth;
    if (maxWidth < 600) {
      cardWidth = maxWidth - 64;
    } else if (maxWidth < 900) {
      cardWidth = ((maxWidth - 64 - 16) / 2).floorToDouble();
    } else if (maxWidth < 1200) {
      cardWidth = ((maxWidth - 64 - 32) / 3).floorToDouble();
    } else {
      // ใช้ .floorToDouble() ปัดเศษลงเพื่อป้องกันปัญหาเบราว์เซอร์คำนวณจุดทศนิยมเกินจนกล่องตกบรรทัด
      cardWidth = ((maxWidth - 64 - 48) / 4).floorToDouble();
    }

    return SizedBox(
      width: cardWidth,
      // สิ่งสำคัญ!: ห้ามมีบรรทัด height: 100, เด็ดขาด เพื่อแก้บั๊กล้น 7 pixels
      child: MiniStatCard(
        title: title,
        value: value,
        subValue: subValue,
        icon: icon,
        iconColor: color,
      ),
    );
  }

  Widget _buildUnassignedTickets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(
                    "Unassigned Tickets (${_unassigned.length})",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Icon(Icons.refresh, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_unassigned.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                "No ticket",
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _unassigned.length,
            itemBuilder: (context, i) {
              final ticket = _unassigned[i];
              return TicketCard(
                location: ticket.inUnitLocation,
                roomType: ticket.inUnitLocation,
                tag: ticket.categoryLabel,
                tagColor: ticket.categoryTagColor,
                tagBgColor: ticket.categoryTagBgColor,
                title: ticket.title,
                description: ticket.detailDesc ?? '-',
                timeAgo: ticket.timeAgo,
                assignedTo: ticket.assignedToId ?? '-',
                isSelected: _selectedTicketIndex == i,
                onTap: () {
                  setState(() {
                    _selectedTicketIndex = _selectedTicketIndex == i ? -1 : i;
                  });
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildTechnicianAvailability() {
    return Container(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                "Showing active members only",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
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
              const SizedBox(width: 90),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Divider(height: 1),
          ),

          // ── NOTE: ถ้า backend มี endpoint /users?role=technician ให้ fetch เพิ่ม ──
          // ตอนนี้ยังใช้ข้อมูล static เพราะ backend ยังไม่มี list technicians endpoint
          const TechnicianRow(
            name: "Jane Doe",
            role: "Plumbing Technician",
            currentTasks: 3,
            roleColor: Color(0xFF36B37E),
          ),
          const Divider(height: 1, thickness: 0.5),
          const TechnicianRow(
            name: "Sarah Smith",
            role: "Electrical Technician",
            currentTasks: 1,
            roleColor: Color(0xFF0052CC),
          ),
          const Divider(height: 1, thickness: 0.5),
          const TechnicianRow(
            name: "Mike Ross",
            role: "HVAC Technician",
            currentTasks: 4,
            roleColor: Color(0xFFFFAB00),
          ),
          const Divider(height: 1, thickness: 0.5),
          const TechnicianRow(
            name: "Dave Miller",
            role: "HVAC Technician",
            currentTasks: 0,
            roleColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
