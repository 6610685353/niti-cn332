// lib/resident/features/home/widgets/main_content/widgets/active_repair.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../repair_history/models/repair_ticket_model.dart';
import '../../../../repair_tracking/repair_tracking_page.dart';
import '../../../../../core/app_config.dart';

// ── Data class ──────────────────────────────────────────────────────────────
class _RepairsSnapshot {
  final List<RepairTicket> tickets;
  const _RepairsSnapshot(this.tickets);

  // distinct: เปรียบเทียบด้วย id + status ของแต่ละ ticket
  @override
  bool operator ==(Object other) {
    if (other is! _RepairsSnapshot) return false;
    if (other.tickets.length != tickets.length) return false;
    for (int i = 0; i < tickets.length; i++) {
      if (other.tickets[i].id != tickets[i].id ||
          other.tickets[i].status != tickets[i].status ||
          other.tickets[i].assignedToId != tickets[i].assignedToId) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
    tickets.map((t) => Object.hash(t.id, t.status, t.assignedToId)),
  );
}

// ────────────────────────────────────────────────────────────────────────────

class ActiveRepair extends StatefulWidget {
  const ActiveRepair({super.key});

  @override
  State<ActiveRepair> createState() => _ActiveRepairState();
}

class _ActiveRepairState extends State<ActiveRepair> {
  final StreamController<_RepairsSnapshot> _streamController =
      StreamController<_RepairsSnapshot>.broadcast();

  Timer? _pollTimer;
  _RepairsSnapshot? _lastEmitted;

  // Cache ชื่อ technician
  final Map<String, String> _techNameCache = {};

  @override
  void initState() {
    super.initState();
    _fetchAndEmit();
    // Polling ทุก 3 วินาที
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchAndEmit(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _streamController.close();
    super.dispose();
  }

  Future<void> _fetchAndEmit() async {
    if (_streamController.isClosed) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _emit(_RepairsSnapshot([]));
        return;
      }

      final uri = Uri.parse(
        '${AppConfig.baseUrl}/tickets/',
      ).replace(queryParameters: {'req_user_id': uid});

      final res = await http.get(uri);
      if (_streamController.isClosed) return;
      if (res.statusCode != 200) return;

      final tickets =
          (jsonDecode(res.body) as List)
              .map((e) => RepairTicket.fromJson(e))
              .where((t) => t.isActive)
              .toList()
            ..sort((a, b) {
              final d = a.targetDate.compareTo(b.targetDate);
              return d != 0 ? d : a.startTime.compareTo(b.startTime);
            });

      _emit(_RepairsSnapshot(tickets));
    } catch (_) {
      // ไม่ emit ถ้า error เพื่อไม่ล้างหน้าจอ
    }
  }

  void _emit(_RepairsSnapshot next) {
    if (_streamController.isClosed) return;
    // distinct — กัน rebuild ถ้าข้อมูลไม่เปลี่ยน
    if (next != _lastEmitted) {
      _lastEmitted = next;
      _streamController.add(next);
    }
  }

  Future<String?> _fetchTechName(String techId) async {
    if (_techNameCache.containsKey(techId)) return _techNameCache[techId];
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/users/$techId'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final name = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'
            .trim();
        _techNameCache[techId] = name;
        return name;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_RepairsSnapshot>(
      stream: _streamController.stream,
      builder: (context, snap) {
        // ── Loading skeleton (ครั้งแรก) ───────────────────────────────
        if (!snap.hasData) {
          return snap.connectionState == ConnectionState.waiting
              ? _buildSkeletonList()
              : const SizedBox.shrink();
        }

        final tickets = snap.data!.tickets;

        // ── Empty state ───────────────────────────────────────────────
        if (tickets.isEmpty) return _buildEmpty();

        // ── List ──────────────────────────────────────────────────────
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _RepairCard(
            key: ValueKey(tickets[i].id),
            ticket: tickets[i],
            fetchTechName: _fetchTechName,
          ),
        );
      },
    );
  }

  // ── Skeleton ────────────────────────────────────────────────────────────
  Widget _buildSkeletonList() => Column(
    children: List.generate(
      2,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _shimmerCard(),
      ),
    ),
  );

  Widget _shimmerCard() => Container(
    height: 112,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _s(44, 44, r: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_s(120, 14), const SizedBox(height: 6), _s(80, 11)],
              ),
            ),
            _s(64, 24, r: 20),
          ],
        ),
        const SizedBox(height: 12),
        _s(double.infinity, 1),
        const SizedBox(height: 10),
        Row(
          children: [
            _s(26, 26, r: 13),
            const SizedBox(width: 8),
            _s(80, 11),
            const Spacer(),
            _s(100, 11),
          ],
        ),
      ],
    ),
  );

  Widget _s(double w, double h, {double r = 6}) => Container(
    width: w == double.infinity ? double.infinity : w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(r),
    ),
  );

  // ── Empty state ────────────────────────────────────────────────────────
  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.build_outlined,
              color: Color(0xFFCBD5E1),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ไม่มีงานที่กำลังดำเนินการ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ทุกงานซ่อมเสร็จสิ้นแล้ว 🎉',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    ),
  );
}

// ── Repair Card ─────────────────────────────────────────────────────────────
class _RepairCard extends StatefulWidget {
  final RepairTicket ticket;
  final Future<String?> Function(String) fetchTechName;

  const _RepairCard({
    super.key,
    required this.ticket,
    required this.fetchTechName,
  });

  @override
  State<_RepairCard> createState() => _RepairCardState();
}

class _RepairCardState extends State<_RepairCard> {
  String? _techName;
  bool _techLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTech();
  }

  @override
  void didUpdateWidget(_RepairCard old) {
    super.didUpdateWidget(old);
    if (old.ticket.assignedToId != widget.ticket.assignedToId) {
      _techLoaded = false;
      _loadTech();
    }
  }

  Future<void> _loadTech() async {
    final id = widget.ticket.assignedToId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _techLoaded = true);
      return;
    }
    final name = await widget.fetchTechName(id);
    if (mounted)
      setState(() {
        _techName = name;
        _techLoaded = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RepairTrackingPage(ticketId: t.id)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Top ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _iconBg(t.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconData(t.category),
                        color: _iconFg(t.category),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  t.inUnitLocation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: t.status),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // ── Bottom ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: const Icon(
                        Icons.person,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.assignedToId == null
                            ? 'Pending'
                            : (_techLoaded
                                  ? (_techName ?? 'Technician')
                                  : '...'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: t.assignedToId == null
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatAppt(t),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAppt(RepairTicket t) {
    try {
      final parts = t.targetDate.split('-');
      if (parts.length != 3) return t.formattedTimeSlot;
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final slot = t.formattedTimeSlot;
      if (dt == today) return 'Today · $slot';
      if (dt == today.add(const Duration(days: 1))) return 'Tomorrow · $slot';
      const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const mo = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${wd[dt.weekday - 1]}, ${dt.day} ${mo[dt.month - 1]} · $slot';
    } catch (_) {
      return t.formattedTimeSlot;
    }
  }

  IconData _iconData(String c) {
    switch (c) {
      case 'plumbing':
        return Icons.water_drop;
      case 'electric':
        return Icons.bolt;
      case 'hvac':
        return Icons.ac_unit;
      default:
        return Icons.more_horiz;
    }
  }

  Color _iconBg(String c) {
    switch (c) {
      case 'plumbing':
        return const Color(0xFFDBEAFE);
      case 'electric':
        return const Color(0xFFFEF3C7);
      case 'hvac':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF43F5E).withValues(alpha: 0.1);
    }
  }

  Color _iconFg(String c) {
    switch (c) {
      case 'plumbing':
        return const Color(0xFF2563EB);
      case 'electric':
        return const Color(0xFFD97706);
      case 'hvac':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFFF43F5E);
    }
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    final String label;
    switch (status) {
      case TicketStatus.inProgress:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF97316);
        label = 'Repairing';
        break;
      case TicketStatus.assigned:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        label = 'On Way';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = 'Submitted';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
