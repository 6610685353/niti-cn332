import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';
import '../../core/services/ticket_service.dart';
import '../../core/services/user_service.dart';
import '../../profile/models/user_model.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';
import '../../work_order/models/work.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onProfileTap;

  const HomeScreen({super.key, required this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WorkOrder> _activeTickets = [];
  UserModel? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    FirebaseAuth.instance.currentUser?.getIdToken().then((token) {
      print("TOKEN: $token");
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        TicketService.getActiveTickets(),
        UserService.getMyProfile(),
      ]);
      if (!mounted) return;
      setState(() {
        _activeTickets = results[0] as List<WorkOrder>;
        _user = results[1] as UserModel;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    // งานที่ยังไม่ได้ Accept (assigned → Pending, isAccepted: false)
    final pendingAccept = _activeTickets
        .where((o) => !(o.isAccepted ?? false))
        .toList();
    // งานที่ Accept แล้ว (in_progress → Repairing, isAccepted: true)
    final acceptedTasks = _activeTickets
        .where((o) => o.isAccepted ?? false)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
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

                // ── งานที่ต้อง Accept ──────────────────────────────────
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
                        .map(
                          (order) =>
                              TaskCard(workOrder: order, onRefresh: _loadData),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── งานที่กำลังดำเนินการ ───────────────────────────────
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
                      _buildChip(
                        'Today',
                        const Color(0xFFEBF5FF),
                        const Color(0xFFBFDBFE),
                        const Color(0xFF1D4ED8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: acceptedTasks
                        .map(
                          (order) =>
                              TaskCard(workOrder: order, onRefresh: _loadData),
                        )
                        .toList(),
                  ),
                ],

                // ── ไม่มีงาน ────────────────────────────────────────────
                if (_activeTickets.isEmpty)
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
      ),
    );
  }

  Widget _buildHeader() {
    final displayName =
        _user?.fullName ??
        FirebaseAuth.instance.currentUser?.email ??
        'Technician';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: widget.onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF8FAFC),
                  backgroundImage:
                      (_user?.imageUrl != null && _user!.imageUrl!.isNotEmpty)
                      ? NetworkImage(_user!.imageUrl!)
                      : null,
                  child: (_user?.imageUrl == null || _user!.imageUrl!.isEmpty)
                      ? const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF475569),
                          size: 26,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Color(0xFF0EA5E9),
                    ),
                  ],
                ),
                const Text(
                  'Technician',
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
      ],
    );
  }

  Widget _buildWorkSummary() {
    final assignedCount = _activeTickets.length;
    final pendingCount = _activeTickets
        .where((t) => !(t.isAccepted ?? false))
        .length;
    final repairingCount = _activeTickets
        .where((t) => t.isAccepted ?? false)
        .length;

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
              count: '$assignedCount',
              label: 'Assigned',
              icon: Icons.assignment_rounded,
              baseColor: const Color(0xFFF43F5E),
            ),
            const SizedBox(width: 12),
            SummaryCard(
              count: '$pendingCount',
              label: 'Pending',
              icon: Icons.hourglass_top_rounded,
              baseColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 12),
            SummaryCard(
              count: '$repairingCount',
              label: 'In Progress',
              icon: Icons.build_rounded,
              baseColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ],
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
