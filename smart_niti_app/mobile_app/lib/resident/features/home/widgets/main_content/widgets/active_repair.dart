import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../repair_history/models/repair_ticket_model.dart';
import '../../../../repair_tracking/repair_tracking_page.dart';
import '../../../../../core/app_config.dart';

class ActiveRepair extends StatefulWidget {
  const ActiveRepair({super.key});

  @override
  State<ActiveRepair> createState() => _ActiveRepairState();
}

class _ActiveRepairState extends State<ActiveRepair> {
  final StreamController<RepairTicket?> _streamController =
      StreamController.broadcast();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchAndEmit();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
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
        _streamController.add(null);
        return;
      }

      final uri = Uri.parse(
        '${AppConfig.baseUrl}/tickets/',
      ).replace(queryParameters: {'req_user_id': uid});
      final res = await http.get(uri);
      if (_streamController.isClosed) return;

      if (res.statusCode != 200) {
        _streamController.add(null);
        return;
      }

      final tickets = (jsonDecode(res.body) as List)
          .map((e) => RepairTicket.fromJson(e))
          .where((t) => !t.isDone && !t.isCancelled)
          .toList();

      // เรียงตาม target_date จากน้อย→มาก แล้วเอาอันแรก (ใกล้สุด)
      tickets.sort((a, b) => a.targetDate.compareTo(b.targetDate));

      _streamController.add(tickets.isEmpty ? null : tickets.first);
    } catch (_) {
      if (!_streamController.isClosed) _streamController.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RepairTicket?>(
      stream: _streamController.stream,
      builder: (context, snap) {
        // ยังไม่มีข้อมูลครั้งแรก
        if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
          return _buildShell(child: _buildLoading());
        }
        final ticket = snap.data;
        return _buildShell(
          onTap: ticket != null
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RepairTrackingPage(ticketId: ticket.id),
                  ),
                )
              : null,
          child: ticket == null ? _buildEmpty() : _buildTicket(ticket),
        );
      },
    );
  }

  // ── Shell card ─────────────────────────────────────────────────────────────
  Widget _buildShell({Widget? child, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmer(40, 40, radius: 10),
        const SizedBox(height: 10),
        _shimmer(100, 14),
        const SizedBox(height: 6),
        _shimmer(140, 11),
        const Spacer(),
        _shimmer(double.infinity, 28, radius: 8),
      ],
    );
  }

  Widget _shimmer(double w, double h, {double radius = 6}) {
    return Container(
      width: w == double.infinity ? double.infinity : w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.build_outlined,
            color: Color(0xFFCBD5E1),
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Active Repairs',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        const Text(
          'ไม่มีงานที่กำลังดำเนินการ',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ทุกงานเสร็จสิ้นแล้ว 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Ticket card ────────────────────────────────────────────────────────────
  Widget _buildTicket(RepairTicket ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: icon + Live dot
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _categoryIcon(ticket.category),
                color: const Color(0xFFD97706),
                size: 22,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          ticket.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),

        // Location
        Text(
          ticket.inUnitLocation,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF4C739A),
            fontWeight: FontWeight.w400,
          ),
        ),

        const Spacer(),

        // Bottom row: status badge + scheduled date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusBadge(ticket.status),
            Text(
              ticket.formattedDate,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Status badge ───────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    final Color bg, fg;
    final String label;

    switch (status) {
      case TicketStatus.assigned:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF137FEC);
        label = 'Assigned';
        break;
      case TicketStatus.inProgress:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF97316);
        label = 'In Progress';
        break;
      default: // submitted
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = 'Submitted';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  // ── Category icon ──────────────────────────────────────────────────────────
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'plumbing':
        return Icons.water_drop_outlined;
      case 'electric':
        return Icons.bolt_outlined;
      case 'hvac':
        return Icons.ac_unit_outlined;
      default:
        return Icons.build_outlined;
    }
  }
}
