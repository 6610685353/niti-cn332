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
            content: Text('The task has been assigned'),
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
            content: Text('Task unassigned'),
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
                  // ── Main Content ─────────────────────────────────
                  isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUnassignedTickets(),
                            const SizedBox(height: 24),
                            _buildAssignedTickets(),
                            const SizedBox(height: 24),
                            // 🌟 วางกล่อง Completed ตรงนี้ (สำหรับจอเล็ก)
                            _buildCompletedTickets(),
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
                                  const SizedBox(height: 24),
                                  _buildCompletedTickets(),
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
    return _buildExpandableSection(
      title: "Unassigned Tickets",
      count: _unassigned.length,
      icon: Icons.priority_high,
      color: AppColors.primaryBlue,
      hintText: _selectedTicketId == null ? "" : "",
      initiallyExpanded: true, // 🌟 กางออกเสมอ เพราะเป็นงานด่วนที่ต้องจัดการ
      content: _unassigned.isEmpty
          ? _buildEmptyState("ไม่มีงานใหม่ที่รอการมอบหมาย")
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _unassigned.length,
              itemBuilder: (context, i) {
                final ticket = _unassigned[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TicketCard(
                    location: ticket.inUnitLocation,
                    roomType: ticket.inUnitLocation,
                    tag: ticket.categoryLabel,
                    tagColor: ticket.categoryTagColor,
                    tagBgColor: ticket.categoryTagBgColor,
                    title: ticket.title,
                    description: ticket.detailDesc ?? '-',
                    timeAgo: ticket.timeAgo,
                    assignedTo: ticket.assignedToId?.toString() ?? '-',
                    isSelected: _selectedTicketId == ticket.id,
                    onTap: () {
                      setState(() {
                        _selectedTicketId = _selectedTicketId == ticket.id
                            ? null
                            : ticket.id;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  // ── Assigned Tickets (มีปุ่ม Unassign) ──────────────────────

  Widget _buildAssignedTickets() {
    return _buildExpandableSection(
      title: "Assigned Tickets",
      count: _assigned.length,
      icon: Icons.assignment_ind,
      color: AppColors.warningOrange,
      hintText: "",
      initiallyExpanded:
          false, // 🌟 ยุบปิดไว้เป็นค่าเริ่มต้น เพื่อประหยัดพื้นที่
      content: _assigned.isEmpty
          ? _buildEmptyState("ยังไม่มีงานที่ถูกมอบหมาย")
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TicketCard(
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
                    onUnassign: () => _unassignTicket(ticket.id),
                  ),
                );
              },
            ),
    );
  }

  // ── Completed Tickets ───────────────────────────────────────

  Widget _buildCompletedTickets() {
    return _buildExpandableSection(
      title: "Completed Tickets",
      count: _done.length,
      icon: Icons.check_circle_outline,
      color: AppColors.successGreen, // ใช้สีเขียวบ่งบอกความสำเร็จ
      hintText: "",
      initiallyExpanded: false, // 🌟 ยุบปิดไว้เพื่อไม่ให้เกะกะงานที่ต้องทำ
      content: _done.isEmpty
          ? _buildEmptyState("")
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _done.length,
              itemBuilder: (context, i) {
                final ticket = _done[i];

                final ticketTechId = ticket.assignedToId?.toString();
                final techMap = _technicians.where(
                  (t) => t['uid']?.toString() == ticketTechId,
                );

                final techName = techMap.isNotEmpty
                    ? '${techMap.first['first_name'] ?? ''} ${techMap.first['last_name'] ?? ''}'
                          .trim()
                    : ticketTechId ?? '-';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TicketCard(
                    location: ticket.inUnitLocation,
                    roomType: ticket.inUnitLocation,
                    tag: ticket.categoryLabel,
                    tagColor: ticket.categoryTagColor,
                    tagBgColor: ticket.categoryTagBgColor,
                    title: ticket.title,
                    description: ticket.detailDesc ?? '-',
                    timeAgo: ticket.timeAgo,
                    assignedTo: techName, // โชว์ชื่อช่างที่ปิดงานนี้
                    isSelected: false,
                    onTap: null,
                    // งานที่เสร็จแล้ว ไม่ต้องมีปุ่ม Unassign แล้ว
                  ),
                );
              },
            ),
    );
  }

  // ── UI Helper: สร้างกล่องยุบขยายได้ (Accordion) ───────────────

  Widget _buildExpandableSection({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String hintText,
    required bool initiallyExpanded,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        // ลบเส้นขอบของ ExpansionTile ที่ชอบโผล่มาตอนกางออก
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                "$title ($count)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          subtitle: hintText.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    hintText,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                )
              : null,
          children: [
            const Divider(height: 1, thickness: 1),
            // 🌟 จุดสำคัญ: ล็อกความสูงตอนกางออกไม่ให้เกิน 450px ถ้าล้นให้เลื่อน Scroll เอา
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  // ── UI Helper: หน้าต่างตอนไม่มีข้อมูล ──────────────────────────

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
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
                    ? "Click to Assign"
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
