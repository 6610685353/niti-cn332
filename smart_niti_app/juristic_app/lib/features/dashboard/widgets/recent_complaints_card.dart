import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/core/services/api_service.dart';
import 'package:juristic_app/features/home/models/ticket_model.dart';

class RecentComplaintsCard extends StatefulWidget {
  final List<TicketModel> tickets;
  final VoidCallback onViewAllTap;

  const RecentComplaintsCard({
    super.key,
    required this.tickets,
    required this.onViewAllTap,
  });

  @override
  State<RecentComplaintsCard> createState() => _RecentComplaintsCardState();
}

class _RecentComplaintsCardState extends State<RecentComplaintsCard> {
  final _api = ApiService();
  final Map<String, String> _nameCache = {};
  bool _loadingNames = false;

  @override
  void initState() {
    super.initState();
    _fetchNames();
  }

  @override
  void didUpdateWidget(RecentComplaintsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchNames();
  }

  Future<void> _fetchNames() async {
    // จำกัดการดึงชื่อเฉพาะ 5 รายการแรกที่นำมาโชว์
    final targetTickets = widget.tickets.take(5).toList();

    final missingUids = targetTickets
        .map((t) => t.reqUserId)
        .toSet()
        .where((uid) => !_nameCache.containsKey(uid))
        .toList();

    if (missingUids.isEmpty) {
      if (_loadingNames && mounted) {
        setState(() => _loadingNames = false);
      }
      return;
    }

    if (!mounted) return;
    setState(() => _loadingNames = true);

    await Future.wait(
      missingUids.map((uid) async {
        try {
          final user = await _api.getUser(uid);
          final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
              .trim();
          _nameCache[uid] = name.isEmpty ? uid : name;
        } catch (_) {
          _nameCache[uid] = uid;
        }
      }),
    );

    if (!mounted) return;
    setState(() => _loadingNames = false);
  }

  @override
  Widget build(BuildContext context) {
    final displayTickets = widget.tickets.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Complaints",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (widget.tickets.length > 5)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Latest 5 of ${widget.tickets.length}",
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (displayTickets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  "No ticket",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ),

          ...displayTickets.map((t) => _buildComplaintItem(t)),

          if (widget.tickets.length > 5)
            Padding(
              padding: const EdgeInsetsGeometry.all(8.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: widget.onViewAllTap,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primaryBlue,
                  ),
                  label: const Text(
                    "View All Complaint Tickets",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintItem(TicketModel t) {
    final displayName = _loadingNames && !_nameCache.containsKey(t.reqUserId)
        ? '...'
        : (_nameCache[t.reqUserId] ?? t.reqUserId);

    return Column(
      key: ValueKey('ticket_${t.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${t.inUnitLocation} • ${t.categoryLabel}",
              style: const TextStyle(
                color: Color(0xFF0052CC),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              t.timeAgo,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          t.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF172B4D),
          ),
        ),
        Text(
          t.detailDesc ?? '-',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, size: 14, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t.status.label,
                style: TextStyle(
                  color: t.status.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 12),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
