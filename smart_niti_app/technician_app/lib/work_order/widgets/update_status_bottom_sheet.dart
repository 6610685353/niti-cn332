import 'package:flutter/material.dart';
import 'package:technician_app/core/constants/app_color.dart';
import '../../core/services/ticket_service.dart';

class UpdateStatusBottomSheet extends StatefulWidget {
  final int ticketId;
  final VoidCallback? onStatusChanged;

  const UpdateStatusBottomSheet({
    super.key,
    required this.ticketId,
    this.onStatusChanged,
  });

  @override
  State<UpdateStatusBottomSheet> createState() =>
      _UpdateStatusBottomSheetState();
}

class _UpdateStatusBottomSheetState extends State<UpdateStatusBottomSheet> {
  bool _loading = false;

  Future<void> _updateStatus(String backendStatus) async {
    // Confirmation dialog
    final isDone = backendStatus == 'done';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isDone
                  ? Icons.check_circle_outline_rounded
                  : Icons.update_rounded,
              color: isDone ? const Color(0xFF10B981) : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Text(isDone ? 'Finish Job?' : 'Update Progress?'),
          ],
        ),
        content: Text(
          isDone
              ? 'Mark this work order as completed? This action cannot be undone.'
              : 'Update the status to In Progress and notify the resident?',
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
              backgroundColor: isDone
                  ? const Color(0xFF10B981)
                  : AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isDone ? 'Finish' : 'Update',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await TicketService.updateStatus(widget.ticketId, backendStatus);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onStatusChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.update_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isDone
                    ? 'Job completed successfully!'
                    : 'Status updated to In Progress',
              ),
            ],
          ),
          backgroundColor: isDone ? const Color(0xFF10B981) : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Update Status',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the progress of this work order',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),

          // Option 1: Save and Update (in_progress)
          _buildOptionCard(
            icon: Icons.sync_rounded,
            title: 'Save and Update',
            subtitle:
                'Transition to the next stage and notify the resident of progress.',
            backgroundColor: AppColors.primary,
            titleColor: Colors.white,
            subtitleColor: Colors.white.withOpacity(0.8),
            borderColor: Colors.transparent,
            onTap: _loading ? null : () => _updateStatus('in_progress'),
          ),
          const SizedBox(height: 14),

          // Option 2: Finish & Close Job (done)
          _buildOptionCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Finish & Close Job',
            subtitle:
                'Submit final evidence, completion report and close work order.',
            backgroundColor: Colors.white,
            titleColor: const Color(0xFF0F172A),
            subtitleColor: Colors.grey.shade500,
            borderColor: Colors.grey.shade200,
            onTap: _loading ? null : () => _updateStatus('done'),
          ),

          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: titleColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: titleColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
