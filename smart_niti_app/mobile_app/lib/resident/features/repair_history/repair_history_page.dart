// lib/resident/features/repair_history/repair_history_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'models/repair_ticket_model.dart';
import '../repair_tracking/repair_tracking_page.dart';
import '../../core/app_config.dart';

class RepairHistoryPage extends StatefulWidget {
  const RepairHistoryPage({super.key});

  @override
  State<RepairHistoryPage> createState() => _RepairHistoryPageState();
}

class _RepairHistoryPageState extends State<RepairHistoryPage> {
  String _selectedFilter = 'All';

  // ── Stream (real-time polling) ────────────────────────────────────────────
  final StreamController<_HistorySnapshot> _streamController =
      StreamController.broadcast();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchAndEmit();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
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
      if (uid == null) return;

      final uri = Uri.parse(
        '${AppConfig.baseUrl}/tickets/',
      ).replace(queryParameters: {'req_user_id': uid});
      final ticketRes = await http.get(uri);
      if (ticketRes.statusCode != 200) return;

      final tickets = (jsonDecode(ticketRes.body) as List)
          .map((e) => RepairTicket.fromJson(e))
          .toList();

      // ดึง rating ของ done tickets ทั้งหมดพร้อมกัน
      final doneTickets = tickets.where((t) => t.isDone).toList();
      final ratingEntries = await Future.wait(
        doneTickets.map((t) async {
          try {
            final res = await http.get(
              Uri.parse('${AppConfig.baseUrl}/tickets/${t.id}/rating'),
            );
            final score = res.statusCode == 200
                ? (jsonDecode(res.body)['score'] as int?)
                : null;
            return MapEntry(t.id, score);
          } catch (_) {
            return MapEntry(t.id, null);
          }
        }),
      );

      if (_streamController.isClosed) return;
      _streamController.add(
        _HistorySnapshot(
          tickets: tickets,
          ratings: Map.fromEntries(ratingEntries),
        ),
      );
    } catch (_) {}
  }

  List<RepairTicket> _filteredTickets(List<RepairTicket> all) {
    switch (_selectedFilter) {
      case 'Active':
        return all.where((t) => t.isActive).toList();
      case 'Completed':
        return all.where((t) => t.isDone).toList();
      case 'Cancelled':
        return all.where((t) => t.isCancelled).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Repair History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<_HistorySnapshot>(
              stream: _streamController.stream,
              builder: (context, snap) => _buildBody(snap),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = ['All', 'Active', 'Completed', 'Cancelled'];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF137FEC)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<_HistorySnapshot> snap) {
    // ยังไม่มีข้อมูลครั้งแรก — แสดง loading
    if (!snap.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF137FEC)),
      );
    }

    final filtered = _filteredTickets(snap.data!.tickets);
    final ratings = snap.data!.ratings;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.handyman_outlined,
              size: 60,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'All'
                  ? 'ยังไม่มีรายการแจ้งซ่อม'
                  : 'ไม่มีรายการในหมวด "$_selectedFilter"',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchAndEmit(),
      color: const Color(0xFF137FEC),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        itemCount: filtered.length,
        itemBuilder: (context, index) =>
            _buildRepairCard(filtered[index], ratings),
      ),
    );
  }

  Widget _buildRepairCard(RepairTicket ticket, Map<int, int?> ratings) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RepairTrackingPage(ticketId: ticket.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.displayCategory,
                  style: const TextStyle(
                    color: Color(0xFF137FEC),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),

            // Date + Time
            Text(
              '${ticket.formattedCreatedDate}  •  ${ticket.formattedCreatedTime}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Technician row / Tracking info
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.assignedToId != null
                            ? 'Technician Assigned'
                            : 'Pending Assignment',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Scheduled: ${ticket.formattedDate}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating / Status indicator
                _buildTrailingWidget(ticket, ratings),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    String label;

    switch (status) {
      case TicketStatus.done:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'Completed';
        break;
      case TicketStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
      case TicketStatus.inProgress:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF97316);
        label = 'In Progress';
        break;
      case TicketStatus.assigned:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF137FEC);
        label = 'Assigned';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = 'Submitted';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildTrailingWidget(RepairTicket ticket, Map<int, int?> ratings) {
    if (ticket.isDone) {
      if (!ratings.containsKey(ticket.id)) {
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFCBD5E1),
          ),
        );
      }

      final score = ratings[ticket.id];

      if (score == null) {
        // ยังไม่ได้ให้คะแนน
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: List.generate(
                5,
                (_) => const Icon(
                  Icons.star_outline_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 13,
                ),
              ),
            ),
            const Text(
              'ยังไม่ให้คะแนน',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
            ),
          ],
        );
      }

      // มีคะแนนแล้ว — แสดงดาวตามจริง
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 13,
              );
            }),
          ),
          Text(
            '$score / 5',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (ticket.isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Cancelled',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const Icon(
        Icons.chevron_right,
        color: Color(0xFF137FEC),
        size: 22,
      );
    }
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _HistorySnapshot {
  final List<RepairTicket> tickets;
  final Map<int, int?> ratings; // ticketId → score (null = ยังไม่ได้ให้คะแนน)

  const _HistorySnapshot({required this.tickets, required this.ratings});
}
