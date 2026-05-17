import 'package:flutter/material.dart';
import 'package:technician_app/core/constants/app_color.dart';
import '../../core/services/ticket_service.dart';
import '../models/work.dart';
import '../widgets/status_stepper.dart';
import '../widgets/evidence_card.dart';
import '../widgets/update_status_bottom_sheet.dart';

class RepairingScreen extends StatefulWidget {
  final WorkOrder workOrder;
  final VoidCallback? onStatusChanged;

  const RepairingScreen({
    super.key,
    required this.workOrder,
    this.onStatusChanged,
  });

  @override
  State<RepairingScreen> createState() => _RepairingScreenState();
}

class _RepairingScreenState extends State<RepairingScreen> {
  late WorkOrder _workOrder;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _workOrder = widget.workOrder;
  }

  @override
  void didUpdateWidget(covariant RepairingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // อัปเดตข้อมูล State เสมอหากข้อมูล workOrder จาก Widget ต้นทางเปลี่ยนแปลง
    if (widget.workOrder != oldWidget.workOrder) {
      setState(() {
        _workOrder = widget.workOrder;
      });
    }
  }

  bool get _isDone => _workOrder.status == 'Done';
  bool get _isCancelled => _workOrder.status == 'Cancelled';
  bool get _isPendingNotAccepted =>
      _workOrder.status == 'Pending' &&
      (_workOrder.isAccepted ?? false) == false;

  Future<void> _acceptJob() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A)),
            SizedBox(width: 10),
            Text('Accept Job?'),
          ],
        ),
        content: Text(
          'Accept work order ${_workOrder.id}?\nYou will be responsible for completing this repair.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _accepting = true);
    try {
      final updated = await TicketService.updateStatus(
        _workOrder.backendId,
        'in_progress',
      );
      if (!mounted) return;
      setState(() {
        _workOrder = updated;
      });
      widget.onStatusChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text('Job ${_workOrder.id} accepted'),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  void _showUpdateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateStatusBottomSheet(
        ticketId: _workOrder.backendId,
        onStatusChanged: () async {
          try {
            final updated = await TicketService.getTicket(_workOrder.backendId);
            if (!mounted) return;
            setState(() => _workOrder = updated);
            widget.onStatusChanged?.call();
          } catch (_) {}
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Work Order',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _workOrder.id,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusStepper(currentStatus: _workOrder.status),
                const SizedBox(height: 24),

                // ── Job Details ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _workOrder.category,
                              style: const TextStyle(
                                color: Color(0xFF1D3B6A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_workOrder.isUrgent)
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Urgent',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _workOrder.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _workOrder.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location & Schedule
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _workOrder.location,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scheduled',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey.shade800,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _workOrder.scheduledTime.replaceAll(
                                            ' • ',
                                            '\n',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
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
                    ],
                  ),
                ),

                // ── Job Evidence ────────────────────────────────────────────
                if (!_isCancelled) ...[
                  const SizedBox(height: 28),
                  const Text(
                    'Job Evidence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isDone
                        ? 'Photos submitted for this work order'
                        : 'Upload before & after photos as evidence',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: EvidenceCard(
                          title: 'Before Work',
                          ticketId: _workOrder.backendId,
                          isReadOnly: _isDone,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: EvidenceCard(
                          title: 'After Work',
                          ticketId: _workOrder.backendId,
                          isReadOnly: _isDone,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: (_isDone || _isCancelled) ? 32 : 100),
              ],
            ),
          ),

          // ── Bottom Button ───────────────────────────────────────────────
          if (!_isDone && !_isCancelled)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _isPendingNotAccepted
                  ? ElevatedButton(
                      onPressed: _accepting ? null : _acceptJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _accepting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Accept Job',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    )
                  : ElevatedButton(
                      onPressed: _showUpdateBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1677FF),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.update_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Update Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
