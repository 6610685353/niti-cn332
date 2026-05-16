import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'package:juristic_app/core/services/api_service.dart';
import 'package:juristic_app/features/home/models/ticket_model.dart';

class RecentComplaintsCard extends StatefulWidget {
  final List<TicketModel> tickets;

  const RecentComplaintsCard({super.key, required this.tickets});

  @override
  State<RecentComplaintsCard> createState() => _RecentComplaintsCardState();
}

class _RecentComplaintsCardState extends State<RecentComplaintsCard> {
  final _api = ApiService();

  final Map<String, String> _nameCache = {};
  bool _loadingNames = false; // เปลี่ยนเป็น false เริ่มต้นไว้ก่อน

  @override
  void initState() {
    super.initState();
    _fetchNames();
  }

  @override
  void didUpdateWidget(RecentComplaintsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ไม่ต้องเช็ค oldWidget != widget แล้ว เพราะ Reference มันเปลี่ยนเสมอ
    // ให้ฟังก์ชัน _fetchNames เป็นตัวเช็คเองว่ามีข้อมูลใหม่ต้องดึงไหม
    _fetchNames();
  }

  Future<void> _fetchNames() async {
    // 1. คัดกรองเฉพาะ UID ที่ยังไม่มีใน Cache
    final missingUids = widget.tickets
        .map((t) => t.reqUserId)
        .toSet()
        .where((uid) => !_nameCache.containsKey(uid))
        .toList();

    // 2. ถ้าข้อมูลมีครบใน Cache แล้ว ไม่ต้องทำอะไรเลย (หยุดวงจร Rebuild รัวๆ)
    if (missingUids.isEmpty) {
      if (_loadingNames && mounted) {
        setState(() => _loadingNames = false);
      }
      return;
    }

    // 3. ถ้ามี UID ใหม่ที่ต้องโหลด ค่อยเซ็ต Loading
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

    // 4. จบการทำงาน คืนค่า Loading เป็น false
    if (!mounted) return;
    setState(() => _loadingNames = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Complaints",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (widget.tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  "No ticket",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ),

          // เปลี่ยนมาใช้ List สร้าง Widget พร้อมโยนข้อมูลให้
          ...widget.tickets.map((t) => _buildComplaintItem(t)),

          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "View All Complaint Tickets",
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w600,
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
        ? '...' // แสดง Loading (...) เฉพาะคนที่ยังไม่มีใน Cache เท่านั้น
        : (_nameCache[t.reqUserId] ?? t.reqUserId);

    return Column(
      // สิ่งสำคัญ!: ใส่ Key ตรงนี้เพื่อให้ Flutter หา Element เจอตอน Reload
      key: ValueKey('ticket_${t.reqUserId}_${t.title}'),
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
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
