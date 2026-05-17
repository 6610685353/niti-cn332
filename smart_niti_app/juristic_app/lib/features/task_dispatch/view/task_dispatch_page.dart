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
  List<Map<String, dynamic>> _technicians = [];
  bool _loading = true;
  String? _error;
  int? _selectedTicketId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedTicketId = null;
    });
    try {
      final results = await Future.wait([
        _facade.getTickets(),
        _facade.getTechnicians(),
      ]);
      setState(() {
        _tickets = results[0] as List<TicketModel>;
        _technicians = results[1] as List<Map<String, dynamic>>;
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

  // ─── actions ──────────────────────────────────────────────────

  Future<void> _assignTicket(int ticketId, String technicianId) async {
    try {
      await _facade.assignTicket(ticketId, technicianId);
      setState(() => _selectedTicketId = null);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('มอบหมายงานสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _unassignTicket(int ticketId) async {
    try {
      await _facade.unassignTicket(ticketId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกการมอบหมายสำเร็จ'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
            if (_selectedTicketId != null) {
              setState(() => _selectedTicketId = null);
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
                            _buildAssignedTickets(),
                            const SizedBox(height: 24),
                            _buildTechnicianAvailability(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _buildUnassignedTickets(),
                                  const SizedBox(height: 24),
                                  _buildAssignedTickets(),
                                ],
                              ),
                            ),
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
      cardWidth = ((maxWidth - 64 - 48) / 4).floorToDouble();
    }

    return SizedBox(
      width: cardWidth,
      child: MiniStatCard(
        title: title,
        value: value,
        subValue: subValue,
        icon: icon,
        iconColor: color,
      ),
    );
  }

  // ── Unassigned Tickets ───────────────────────────────────────

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
              GestureDetector(
                onTap: _loadData,
                child: Icon(
                  Icons.refresh,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedTicketId == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "กดเลือก Ticket เพื่อมอบหมายให้ช่าง",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
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
                    assignedTo:
                        ticket.assignedToId?.toString() ??
                        '-', // 👈 แปลงป้องกัน Error
                    isSelected: _selectedTicketId == ticket.id,
                    onTap: () {
                      setState(() {
                        _selectedTicketId = _selectedTicketId == ticket.id
                            ? null
                            : ticket.id;
                      });
                    },
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  // ── Assigned Tickets (มีปุ่ม Unassign) ──────────────────────

  Widget _buildAssignedTickets() {
    if (_assigned.isEmpty) return const SizedBox.shrink();

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
                      color: AppColors.warningOrange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.assignment_ind,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Assigned Tickets (${_assigned.length})",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                "กด Unassign ที่การ์ดเพื่อยกเลิก", // แก้ไขคำใบ้นิดหน่อย
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _assigned.length,
          itemBuilder: (context, i) {
            final ticket = _assigned[i];

            final ticketTechId = ticket.assignedToId?.toString();
            final techMap = _technicians.where(
              (t) => t['uid']?.toString() == ticketTechId,
            );

            final techName = techMap.isNotEmpty
                ? '${techMap.first['first_name'] ?? ''} ${techMap.first['last_name'] ?? ''}'
                      .trim()
                : ticketTechId ?? '-';

            // 🌟 ไม่ต้องใช้ Stack แล้ว เรียกใช้งาน TicketCard ตัวเดียวจบเลย!
            return TicketCard(
              location: ticket.inUnitLocation,
              roomType: ticket.inUnitLocation,
              tag: ticket.categoryLabel,
              tagColor: ticket.categoryTagColor,
              tagBgColor: ticket.categoryTagBgColor,
              title: ticket.title,
              description: ticket.detailDesc ?? '-',
              timeAgo: ticket.timeAgo,
              assignedTo: techName,
              isSelected: false,
              onTap: null,
              onUnassign: () =>
                  _unassignTicket(ticket.id), // 👈 โยนคำสั่งเข้าไปตรงนี้
            );
          },
        ),
      ],
    );
  }

  // ── Technician Availability ──────────────────────────────────

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
                    "Technician Availability",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                _selectedTicketId != null
                    ? "เลือกช่างเพื่อ Assign"
                    : "Active members",
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedTicketId != null
                      ? AppColors.primaryBlue
                      : Colors.grey.shade400,
                  fontWeight: _selectedTicketId != null
                      ? FontWeight.bold
                      : FontWeight.normal,
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
              const SizedBox(width: 90),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Divider(height: 1),
          ),

          if (_technicians.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "ไม่พบข้อมูลช่าง",
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ...(_technicians.map((tech) {
              // 👈 ใช้ ?.toString() แทน as String เพื่อป้องกันแอปพังถ้า UID มาเป็นตัวเลข
              final techId = tech['uid']?.toString() ?? '';
              final name =
                  '${tech['first_name'] ?? ''} ${tech['last_name'] ?? ''}'
                      .trim();
              final role = (tech['role']?.toString() ?? 'technician');

              // 👈 นับ workload ให้ถูกต้อง โดยแปลงค่าเป็น String ก่อนเทียบ
              final workload = _assigned
                  .where((t) => t.assignedToId?.toString() == techId)
                  .length;

              Color roleColor;
              switch (role) {
                case 'technician':
                  roleColor = AppColors.primaryBlue;
                  break;
                default:
                  roleColor = Colors.grey;
              }

              return Column(
                children: [
                  TechnicianRow(
                    name: name,
                    role: role,
                    currentTasks: workload, // ส่ง Workload ไปโชว์ให้ถูกต้อง
                    roleColor: roleColor,
                    isAssignEnabled: _selectedTicketId != null,
                    onAssign: _selectedTicketId != null
                        ? () => _assignTicket(_selectedTicketId!, techId)
                        : null,
                  ),
                  const Divider(height: 1, thickness: 0.5),
                ],
              );
            })),
        ],
      ),
    );
  }
}
