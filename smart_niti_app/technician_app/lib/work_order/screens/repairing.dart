import 'package:flutter/material.dart';
import 'package:technician_app/core/constants/app_color.dart';
import '../models/work.dart';
import '../widgets/status_stepper.dart';
import '../widgets/evidence_card.dart';
import '../widgets/update_status_bottom_sheet.dart';

class RepairingScreen extends StatelessWidget {
  final WorkOrder workOrder;

  const RepairingScreen({Key? key, required this.workOrder}) : super(key: key);

  void _showUpdateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UpdateStatusBottomSheet(),
    );
  }

  bool get _isDone => workOrder.status == 'Done';
  bool get _isCancelled => workOrder.status == 'Cancelled';
  bool get _isPendingNotAccepted =>
      workOrder.status == 'Pending' && workOrder.isAccepted == false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () {
            Navigator.pop(context);
          },
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
              workOrder.id,
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
                StatusStepper(currentStatus: workOrder.status),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags row
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
                              workOrder.category,
                              style: const TextStyle(
                                color: Color(0xFF1D3B6A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (workOrder.isUrgent)
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
                        workOrder.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        workOrder.description,
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
                                      Text(
                                        workOrder.location,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
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
                                          workOrder.scheduledTime.replaceAll(
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

                // Job Evidence — แสดงเฉพาะงานที่ไม่ใช่ Cancelled
                if (!_isCancelled) ...[
                  const SizedBox(height: 28),
                  const Text(
                    'Job Evidence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: EvidenceCard(
                          title: 'Before Work',
                          isReadOnly: _isDone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: EvidenceCard(
                          title: 'After Work',
                          isReadOnly: _isDone,
                        ),
                      ),
                    ],
                  ),
                ],

                // padding ด้านล่างสำหรับปุ่ม
                SizedBox(height: (_isDone || _isCancelled) ? 32 : 100),
              ],
            ),
          ),

          // Bottom button — ตาม status
          if (!_isDone && !_isCancelled)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _isPendingNotAccepted
                  ? ElevatedButton(
                      onPressed: () {
                        // TODO: handle accept job
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white),
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
                      onPressed: () => _showUpdateBottomSheet(context),
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
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Update or finish job',
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
